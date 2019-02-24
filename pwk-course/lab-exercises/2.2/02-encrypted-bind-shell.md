# 02-encrypted-bind-shell

> Create an encrypted bind shell on your Windows VM. Try to connect to it from
 Kali without encryption. Does it still work?

On the Windows machine run the following:
```bash
ncat -lvp 8080 --ssl -e cmd.exe
```

On the Kali machine run:
```bash
ncat -v <target> 8080
```
# Does it work?
No, it doesn't. The following SSL error is reported by the Windows machine and the connection reset:

```wrong version number```
