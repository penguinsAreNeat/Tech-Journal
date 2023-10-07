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

awk '{print $1}' $logName | sort -u > uniqueIPs.txt
echo "successful run"

for eachip in $(cat  uniqueIPs.txt)
do
	echo "sudo ufw deny from $eachip" > `tty`
done

rm uniqueIPs.txt
