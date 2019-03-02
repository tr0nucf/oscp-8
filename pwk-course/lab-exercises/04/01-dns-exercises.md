# DNS Exercises

> 1. Find the DNS servers for the megacorpone.com domain
> 2. Write a small Bash script to attempt a zone transfer from megacorpone.com
> 3. Use dnsrecon to attempt a zone transfer from megacorpone.com

```bash
host -t ns megacorpone.com
```

```bash
#!/bin/bash
$FILE=/tmp/zone-transfer.txt
> $FILE
host -t ns megacorpone.com | cut -d " " -f4 | tee $FILE

while read -r line
do
    host -l megacorpone.com $line
done < $FILE
```

```bash
dnsrecon -d megacorpone.com -t axfr
```
