# Kioptrix Level 3

### Contents

Our target network is `10.0.2.0/24`.

# Footprinting
Find the IP address of the target host via:

```bash
netdiscover -r 10.0.2.0/24
```

For the purpose of this guide we will assume our target is at IP address **10.0.2.9**.

# Reconnaisance

We perform an initial scan as follows:

```bash
nmap 10.0.2.9
```

```
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
MAC Address: 08:00:27:50:6F:FB (Oracle VirtualBox virtual NIC)
```

Let's check for UDP ports:

```bash
nmap -sU 10.0.2.9
```

Let's do version detection:
```bash
nmap -O 10.0.2.9
```

```
Device type: general purpose
Running: Linux 2.6.X
OS CPE: cpe:/o:linux:linux_kernel:2.6
OS details: Linux 2.6.9 - 2.6.33
```

Now we proceed by examining each of the services on the machine.
Starting with the most interesting.

# HTTP
Run Nikto we find a **phpmyadmin** page.
