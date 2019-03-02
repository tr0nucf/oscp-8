# SMB Enumeration Exercises

> 1. Use Nmap to make a list of which SMB servers in the lab are running Windows.
> 2. Use NSE scripts to scan these systems for SMB vulnerabilities.

## Identifying SMB Servers

```bash
# Find all hosts with 139 or 145 open
nmap 192.168.0.0/24 -p 139,445 --open

# Perform OS detection
nmap 192.168.0.0/24 --script smb-os-discovery -p 139,445 --open
```

## Identify SMB Vulnerabilities
```bash
ls /usr/share/nmap/scripts/smb* | grep vuln

# Output
/usr/share/nmap/scripts/smb2-vuln-uptime.nse
/usr/share/nmap/scripts/smb-vuln-conficker.nse
/usr/share/nmap/scripts/smb-vuln-cve2009-3103.nse
/usr/share/nmap/scripts/smb-vuln-cve-2017-7494.nse
/usr/share/nmap/scripts/smb-vuln-ms06-025.nse
# and so on...

nmap 192.168.0.0/24 --script smb*vuln*.nse -p 139,445 --open
```
