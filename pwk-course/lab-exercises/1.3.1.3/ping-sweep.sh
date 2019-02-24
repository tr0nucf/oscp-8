#!/bin/bash

# Research Bash loops and write a short script to perform a ping sweep of your
# target IP range of 10.11.1.0/24.
# We use a 192 range for our local network and ...10 for brevity.

TARGET=192.168.0.

for i in {1..10}
do
   ping -c 1 192.168.0.$i -w 1
done
