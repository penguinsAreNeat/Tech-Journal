#!/bin/bash

#Apache log parser

#Check if Apache log exists
read -p "What is the Apache log file name: " logName

if [ -f $logName ]
then
	echo "File exists"
else
	 echo "File does not exist"
	exit 1
fi

# Get IPv4 addresses, sort out duplicates and put them in a temporary file
awk '{print $1}' $logName | sort -u > uniqueIPs.txt
echo "successful run"

# Discarded code 
#for eachip in $(cat  uniqueIPs.txt)
#do
#	echo "sudo ufw deny from $eachip" > `tty`
#done

# Put each IPv4 address in a IPtables block rule
for eachip in $(cat uniqueIPs.txt)
do
	echo "iptables -a input -s ${eachip} -j drop" | tee -a  badips.iptables
done

echo "Created IPTables firewall drop rules in file \"badips.iptables\""

# Delete tempoary file
rm uniqueIPs.txt
