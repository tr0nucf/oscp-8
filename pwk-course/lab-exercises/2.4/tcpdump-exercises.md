# tcmpdump Exercises

> 1. Use tcpdump to recreate the wireshark exercise of capturing traffic on port 110.
2. Use the -X flag to view the content of the packet. If data is truncated, investigate
how the -s flag might help.

```bash
# Capture traffic on port 110
tcmpdump -i 2 port 110

# Using the -X flag to print the data of the packet, but truncating it to a shorter length (-s) and only getting one
tcpdump -i 2 port 53 -X -s 128

# The above prints the first 128 bytes of all DNS traffic
```
