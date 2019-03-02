# Wireshark Exercises

> 1. Use Wireshark to capture the network activity of Netcat connecting to port 110
(POP3) and attempting a login.
> 2. Read and understand the output. Where is the session three-way handshake? Where is the session closed?
> 3. Follow the TCP stream to read the login attempt.
> 4. Use the display filter to only see the port 110 traffic
> 5. Re-run the capture, this time using the capture filter to only collect port 110

The exercises in this module are GUI-based and therefore instead a set of useful filters are recorded.

```
# DNS Traffic
tcp.port==53
# POP3 Traffic
tcp.port==110

# Follow a stream
tcp.stream eq 1

# ICMP traffic
icmp

# UDP from the network
ip.dst==192.168.0.0/24 and udp
```
