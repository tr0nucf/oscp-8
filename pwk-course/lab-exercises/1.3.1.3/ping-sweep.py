# Try to do the above exercise with a higher-level scripting language such as
# Python, Perl, or Ruby.

import os
import socket   # For getting the operating system name
import sys  # For executing a shell command

def ping(host):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  #Create a TCP/IP socket
    rep = os.system("ping -c 1 -w 2 " + host + " > /dev/null")
    if rep == 0:
        print(host + " is up")
    else:
        print(host + " is down")

for x in range(1, 10):
    ping("192.168.0." + str(x))
