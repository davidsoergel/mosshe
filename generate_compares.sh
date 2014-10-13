#!/bin/sh

# you have to MANUALLY adapt these and match them with the 
# Compare* calls in MoSShE



mkdir -p CompareFiles

# CheckFileChanges passwd /etc/passwd
cp /etc/passwd CompareFiles/

# CheckFileChanges shadow /etc/shadow
cp /etc/shadow CompareFiles/

# CheckFileChanges resolv.conf /etc/resolv.conf
cp /etc/resolv.conf CompareFiles/

# CheckFileChanges sshauth /root/.ssh/authorized_keys
cp /root/.ssh/authorized_keys CompareFiles/authorized_keys



# CheckConfigChanges routing.txt "netstat -nr"
netstat -nr >  CompareFiles/routing.txt

# CheckConfigChanges listeners.txt "netstat -tulpen"
netstat -tulpen > CompareFiles/listeners.txt



# clean up - make things safe
chmod 600 CompareFiles/*
chmod 0700 CompareFiles
chown root:root CompareFiles
