# SNMP Enumeration Exercises

> 1. Scan your target network with onesixtyone. Identify any SNMP servers.
> 2. Use snmpwalk and snmp-check to gather information about the discovered targets.

## Scan for SNMP and Common Strings
```bash
# Find targets with nmap
nmap 192.168.0.0/24 -sU --open -p 161 -oG /tmp/snmp.txt

# Create the target IP list
cat /tmp/snmp.txt | grep Status: | cut -d " " -f 2 > /tmp/snmp-targets.txt

# With onesixtyone check for common community strings
onesixtyone -c community -i /tmp/snmp-targets.txt
```

## Usage of snmpwalk & snmp-check
```bash
while read -r line
do
    snmpwalk -c public -v1 $line
    snmp-check $line -c public
done < $/tmp/snmp-targets.txt
```
