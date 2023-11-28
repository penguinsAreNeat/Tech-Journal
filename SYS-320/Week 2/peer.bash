#!/bin/bash

# Storyline: Create peer VPN configuration file

# List existing users using the find command
echo "Active user profiles: "
find -name "*-wg0.conf" 
echo ""

# What is the user / peer's name
echo -n "What is the peer's name? "
read the_client

# Close statement for testing purposes
if [[ ${the_client}  == "q" ]] 
then
	exit 0

# Code explicitly for removing user files
elif [[ ${the_client} == "WIPE" ]] 
then
	read -p "Are you sure you want to delete all profiles? [y/n]: " confirmDeletion

	# Delete confirmation
	if [[ ${confirmDeletion} == "y" ]] 
	then
		find -type f -name "*wg0.conf" -delete
		exit 0
	fi
fi


# Filename variable
pFile="${the_client}-wg0.conf"

# Check for existing config file / if we want to override
if [[ -f "${pFile}" ]]
then 
	# Prompt if we need to overwrite the file
       	echo "The file ${pFile} already exists."
	echo -n "Do you want to overwrite it? [y|N]"
	read to_overwrite

	# Cancel overwrite
	if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" || "${to_overwrite}" == "n"  ]]
	then
		echo "Exiting..."
		exit 0
	
	# Confirm overwrite
	elif [[ "${to_overwrite}" == "y" ]]
	then
		echo "Creating the wireguard configuration file..."
	
	# If they don't specify y/N then error
	else
		echo "Invalid value"
		exit 1
	fi
fi
# Generate private key
p="$(wg genkey)"

# Generate Public key
clientPub="$(echo ${p} | wg pubkey)"

# Generate preshared key (used for additional security for the client when establishing VPN tunnel)
pre="$(wg genpsk)"

# 10.254.132.0/24,172.16.28.0/24  192.199.97.163:4282 NH9qUERcppInDrMp8aT5Lx3gPdwf6s980Msa7y1x9nE= 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0

# Endpoint
end="$(head -1 wg0.conf | awk ' { print $3 } ')"

# Server Public Key
pub="$(head -1 wg0.conf | awk ' { print $4 } ')"

# DNS Servers
dns="$(head -1 wg0.conf | awk ' { print $5 } ')"

# MTU
mtu="$(head -1 wg0.conf | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 wg0.conf | awk ' { print $7 } ')"

# ListeningPort
lport="$(shuf -n1 -i 40000-50000)"

# Default routes for VPN
routes="$(head -1 wg0.conf | awk ' { print $8 } ')"

# Create Client Configuration File
echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort = ${lport}
MTU = ${mtu}
PrivateKey = ${p}
[Peer]
AllowedIPs = ${routes}
PersistentKeepalive = ${keep}
PresharedKey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFile}

# Add our peer configuration to the server config
echo "
# ${the_client} begin
[Peer]
PublicKey = ${clientPub}
PresharedKey = ${pre}
AllowedIPs = 10.254.132.100/32 
# ${the_client} end
" | tee -a wg0.conf

