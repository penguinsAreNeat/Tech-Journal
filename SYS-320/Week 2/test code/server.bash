#!/bin/bash

# Storyline: Wiregaurd server creation script

#Check if config file exists
if [test -f "wg0.conf"]
then
	echo "Config file already exists, overwrite? [Y/N]"
 	read response
  	if [[ "${response}" == "N" ]]
   	then
    		exit 0
      	elif [[ "${response}" == "Y" ]]
       	then 
		echo "File overwritten"
  	else
   		echo "Invalid input"
     		exit 1
       fi
fi

#Generate Private Key
privKey="$(wg genkey)"

#Generate Public Key
pubKey="$(echo ${privKey} | wg pubkey)"

#Set Address
IPv4Address="192.168.1.1/24,192.168.4.2/24"

#Set Server Address
ServerIPv4Address="192.168.10.1/24,192.168.10.2/24"

#Set Listening Port
listeningPort="4282"

#Client Config Options
options="# ${IPv4Address} 192.168.100.10:${listeningPort} 8.8.8.8,1.1.1.1 ${pubKey}
