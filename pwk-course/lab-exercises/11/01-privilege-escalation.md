# Privilege Escalation Methods

As well as recording exercises, here we will also note down a range of both Linux and Windows privilege escalation methods.

## Exercises

### Using pyinstaller

This program allows for the compilation of python programs to a particular environment.

```
python pyinstaller.py --onefile ms11-080.py
```

### PhotoDex Producer Escalation

In this example, we detect that the service runs as SYSTEM and has read-write privileges enabled.

We can then replace the executable that runs on startup with one of our own that adds a new user as a system administrator. On reboot a new user is therefore created.

The command to add a new administrator called `john` is:

```
net user /add john [password]
net localgroup administrators john /add
```

## Escalation Techniques

### Passwords

This is the most basic technique. Search using `grep` or `findstr`.
They may also exist in configuration files and the registry.

Password hashes (`/etc/passwd`) can also be reversed.

### Incorrect Permissions

Files, programs and services with incorrect permissions are also ripe for exploitation.

Use `netstat` to look for internal programs listening on ports.

Look for processes running as `root` or `SYSTEM`.

**Scheduled Tasks** can also have incorrect permissions.

Use `schtasks /query /fo LIST /v` to enumerate scheduled tasks.

### Kernel Exploits

Based upon the OS system, search `exploitDB`.

### Honourable Mentions

* SUID and sticky bits
* /tmp
* History
*
