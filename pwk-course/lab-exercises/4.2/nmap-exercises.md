# nmap Exercises

> 1. Use nmap to conduct a ping sweep of your target IP range and save the output to a file, so that you can grep for hosts that are online.
> 2. Scan the IPs you found in exercise 1 for open webserver ports. Use nmap to find the web server and operating system versions.
> 3. Use the NSE scripts to scan the servers in the labs which are running the SMB service.

## Ping Sweep

```bash
nmap -sn 192.168.0.0/24 -oG ping_sweep.txt
grep Up ping-sweep.txt | cut -d " " -f 2
```

## Web Server & OS Scanning
```bash
nmap -O -A -p 80,443 192.168.0.15
```

## SMB Scanning
```bash
# Find relevant scripts at:
ls /usr/share/nmap/scripts/smb*
nmap 192.168.0.0/24 --script "smb*"
nmap 192.168.0.15 --script smb-os-discovery.nse
```
