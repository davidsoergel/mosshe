#!/bin/sh
TARGETFILE=$1

if [ -z "$TARGETFILE" ]; then
    echo "USAGE:  create_mosshe.sh TARGETFILE ip/mask ip/mask ..."
    exit 0
fi

if [ -f "$TARGETFILE" ]; then
    echo "target file $TARGETFILE already exists. Aborting."
    exit 0
fi




#----------------------------------------------
SCANRESULT=`mktemp`
TMP=`mktemp`

cp create_mosshe.header $TARGETFILE

echo " "
echo "Scanning pingable Hosts in $2 $3 $4 $5 $6 $7 $8 $9 ..."
echo " "
nmap -sP -oG $TMP $2 $3 $4 $5 $6 $7 $8 $9 >/dev/null 2>/dev/null
fgrep -v "# Nmap " < $TMP | fgrep -v " hosts up " > $SCANRESULT

echo " " | tee -a  $TARGETFILE 
echo "#-------------------------------- " | tee -a  $TARGETFILE 
echo "# Pingable hosts " | tee -a  $TARGETFILE 
while read LINE; do
    HOST=`echo $LINE | cut -d "(" -f 2 | cut -d ")" -f 1`
    if [ -z "$HOST" ]; then
    	HOST=`echo $LINE | cut -d " " -f 2`
    fi
    echo "PingPartner $HOST 2 60 250   # IP, NumberOfPings, max% Loss, max. Roundtrips " | tee -a  $TARGETFILE 
done < $SCANRESULT


# Host: 127.0.0.1 (localhost.localdomain) Status: Up
 

echo " "
echo " "
echo " "
echo "Scanning Services in $2 $3 $4 $5 $6 $7 $8 $9 ..."
echo " "
nmap -sT -sV -p- -oG $TMP $2 $3 $4 $5 $6 $7 $8 $9 >/dev/null 2>/dev/null
fgrep -v "# Nmap " < $TMP > $SCANRESULT

while read LINE; do
    HOST=`echo $LINE | cut -d "(" -f 2 | cut -d ")" -f 1`
    if [ -z "$HOST" ]; then
    	HOST=`echo $LINE | cut -d " " -f 2`
    fi
    HOST=`echo $LINE | cut -d "(" -f 2 | cut -d ")" -f 1`
    echo " " | tee -a  $TARGETFILE 
    echo "#-------------------------------- " | tee -a  $TARGETFILE 
    echo "# $HOST " | tee -a  $TARGETFILE 
    PORTLIST=`echo $LINE | cut -d ":" -f 3 | sed -e "s/ //g"`
    
    PORT=`echo $PORTLIST | cut -d "," -f 1`
    while [ "$PORT" ]; do
	PORTLIST=`echo $PORTLIST | cut -d "," -f 2-`
	
	NUMBER=`echo $PORT | cut -d "/" -f 1`
	PROTO=`echo $PORT | cut -d "/" -f 3`
	L7=`echo $PORT | cut -d "/" -f 5`
	
	if [ "$NUMBER$L7" = "21ftp" ]; then
	    echo "FTPcheck $HOST" | tee -a  $TARGETFILE 
	elif [ "$L7" = "ssh" ]; then
	    echo "SSHcheck $HOST $NUMBER" | tee -a  $TARGETFILE 
	elif [ "$NUMBER$L7" = "25smtp" ]; then
	    echo "SMTPcheck $HOST" | tee -a  $TARGETFILE 
	elif [ "$L7" = "http" ]; then
	    echo "HTTPheader http://${HOST}:${NUMBER}/" | tee -a  $TARGETFILE 
	elif [ "$NUMBER$L7" = "110pop3" ]; then
	    echo "POP3check ${HOST}" | tee -a  $TARGETFILE 
	elif [ "$NUMBER$L7" = "143imap" ]; then
	    echo "IMAPcheck ${HOST}" | tee -a  $TARGETFILE 
	elif [ "$L7" = "rpcbind" ]; then
	    echo "rpcbind on $PROTO/$NUMBER ignored"
	elif [ "$PROTO" = "tcp" ]; then
    	    echo "TCPing $HOST $NUMBER	# connect-only = todo: syntax check for protocol $L7" | tee -a  $TARGETFILE 
	else
    	    echo "#	todo: $L7 = $PROTO/$NUMBER" | tee -a  $TARGETFILE 
	fi
	
	PORT=`echo $PORTLIST | cut -d "," -f 1`
	if [ "$PORT" = "$PORTLIST" ]; then PORT=; fi
    done

done < $SCANRESULT


cat create_mosshe.footer >> $TARGETFILE
chmod 700 $TARGETFILE

echo "---------------------------------------------------------------------"
echo "Done. Please adapt $TARGETFILE for your configuration."
