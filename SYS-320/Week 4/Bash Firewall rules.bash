#!/bin/bash

#Extract IPs from target file and create firewall ruleset
function get_badIPs() {
	
	#Regex IP getter
	wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /tmp/targetedthreats.csv | sort -u > badIPs.txt

	#Create firewall ruleset
	: ' Multi-line comment
	Code from week 4 video
	for eachIP in $(cat badIPs.txt)
	do
		echo "block in from $(eachIP) to any" | tee -a pdf.conf
		echo "iptables -A INPUT -s $(eachIP) j- DROP" | tee -a badIPs.iptables	
	done
	'
}

function eachInbadIPs() {
	for ip in $(cat badIPs.txt)
	do
		echo $1 $ip $2
	done
}

if ! [ test -f badIPs.txt ]; then
	get_badIPs
fi

while :
do
	read -p "Enter a option (I, C, W, M, P)" UserInput
	
	if [[ $UserInput == "I" ]] || [[ $UserInput == "iptables" ]]; then
		#echo $UserInput
		eachInbadIPs "iptables -a input -s" "-j drop" | tee -a badips.iptables

	elif [[ $UserInput == "C" ]] || [[ $UserInput == "Cisco" ]]; then
		#echo $UserInput
		eachInbadIPs "deny ip host" "any" | tee -a badips.cisco	

	elif [[ $UserInput == "W" ]] || [[ $UserInput == "Windows" ]]; then
		#echo $UserInput
		for eachip in $(cat badIPs.txt)
		do
			echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachip}\" dir=in action=block remoteip=${eachip}" | tee -a badips.netsh
		done

	elif [[ $UserInput == "M" ]] || [[ $UserInput == "Mac" ]]; then
		#echo $UserInput
		echo '
		srcub-anchor "com.apple/*"
		nat-anchor "com.apple/*"
		rdr-anchor "com.apple/*"
		dummynet-anchor "com.apple/*"
		anchor "com.apple/*"
		load anchor "com.apple" from "/etc/pf.anchors/com.apple"

		' | tee pf.conf
		eachInbadIPs "block in from" "to any" | tee -a pf.conf

	elif [[ $UserInput == "P" ]] || [[ $UserInput == "ParseCisco" ]]; then
		wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.cs
		awk '/domain/ {print}' temp/targetedthreats.csv | awk -F \" '{print $4}' | sort -u > threat.txt
		echo 'class-map match-any BAD_URLS' | tee ciscothreats.txt
		for eachip in $(cat threats.txt)
			echo "match protocol http host \"${eachip}\"" | tee -a ciscothreats.txt
		done
		rm threat.txt

	elif [[ $UserInput == "q" ]]; then 
		break
	
	else
		echo "Invalid option"
	fi
done
