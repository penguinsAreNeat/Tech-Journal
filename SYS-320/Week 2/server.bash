
#!/bin/bash

# Storyline: Script to create a wireguard server

# Check if config file exists
if  test -f wg0.conf; 
then 
	# User input to overwrite existing config file
	echo "Config file already exists, overwrite? [Y/N]"
	read response
	if [[ "${response}" == "N" || "${response}" == "n" ]]
	then
		# Cancel if file exists
		exit 0
	elif [[ "${response}" == "Y" || "${response}" == "y" ]]
	then 
		# Contine with script, message is preemptive
		echo "File overwritten"
	else 
		# Exit with error code
		echo "Invalid input"
		exit 1
	fi
fi
# Create a private key
p="$(wg genkey)"
echo "${p}" > /etc/wireguard/server_private.key

# Create a public key
pub="$(echo ${p} | wg pubkey)"
echo "${pub}" > /etc/wireguard/server_public.key

# Set the addresses
address="10.254.132.0/24"

# Set Server IP Addresses
ServerAddress="10.254.132.1/24"

# Set a listening port
lport="4282"

# Info to be used in client configuration
peerInfo="# ${address} 192.168.241.131:4282 ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"
# 1: #, 2: For obtaining an IP address for each client.
# 3: Server's actual IP address
# 4: clients will need server public key
# 5: dns information
# 6: determines the largest packet size allowed
# 7: keeping connection alive for
# 8: what traffic to be routed through VPN

# Creates configuration infomration to be accessed by peer.bash
echo "${peerInfo}
[Interface]
Address = ${ServerAddress}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens33 -j MASQUERADE
ListenPort = ${lport}
PrivateKey = ${p}
" > wg0.conf 

# As this art piece containts single quotes, using single line echo statements didn't work, so cat is used here instead
cat << "EOF"

  __          ___                                    _    _____
  \ \        / (_)                                  | |  / ____|
   \ \  /\  / / _ _ __ ___  __ _ _   _  __ _ _ __ __| | | (___   ___ _ ____   _____ _ __
    \ \/  \/ / | | '__/ _ \/ _` | | | |/ _` | '__/ _` |  \___ \ / _ \ '__\ \ / / _ \ '__|
     \  /\  /  | | | |  __/ (_| | |_| | (_| | | | (_| |  ____) |  __/ |   \ V /  __/ |
      \/  \/   |_|_|  \___|\__, |\__,_|\__,_|_|  \__,_| |_____/ \___|_|    \_/ \___|_|
                            __/ |
                           |___/

EOF

# Confirmation message
echo 'File successfully created'
