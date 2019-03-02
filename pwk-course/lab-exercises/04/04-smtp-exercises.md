# SMTP Enumeration Exercises

> Search your target network range, and see if you can identify any systems that respond to the SMTP VRFY command.

```bash
# Find all hosts with port 25 open
nmap 192.168.0.0/24 -p 25 --open -oG /tmp/smtp.txt

# Get the list of valid targets
cat /tmp/smtp.txt | grep Status: | cut -d " " -f 2 > /tmp/smtp-targets.txt
```

```bash
while read -r line
do
    nmap $line -p 25 --script smtp-enum-users.nse
done < $/tmp/smtp-targets.txt
```
