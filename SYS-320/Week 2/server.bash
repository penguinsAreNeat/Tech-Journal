
#!/bin/bash

# Storyline: Script to create a wireguard server
echo "Test for class code, Run for student code"
read -p "Enter option: " varname

# Check if file exists, with a choice between example and student method
if [ "$varname" == "Test" ]; then 
  #echo "success"
  #Example method

  if [[ -f "wg0.conf" ]]
  then 
	  # Prompt if we need to overwrite the file
    echo "The file wg0.conf already exists."
	  echo -n "Do you want to overwrite it? [y|N]"
	  read to_overwrite

	  if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" || "${to_overwrite}" == "n"  ]]
	  then
		  echo "Exiting..."
		  exit 0
	  elif [[ "${to_overwrite}" == "y" ]]
	  then
		  echo "Creating the wireguard configuration file..."
	  # If they don't specify y/N then error
	  else
		  echo "Invalid value"
		  exit 1
	  fi
  fi
  
elif [ "$varname" == "Run" ]; then 
  #echo "other success"
  #Student method

  if test -f "wg0.conf"
  then
  read -p "The file wg0.conf aleady exists, do you want to overwrite it? [Y/N]" overwrite_choice
  if [ "$overwrite_choice" == "Y" ]; then 
  else exit 0     
  fi
  
else echo "Typo/other error, please restart"
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

echo "${peerInfo}
[Interface]
Address = ${ServerAddress}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens33 -j MASQUERADE
ListenPort = ${lport}
PrivateKey = ${p}
" > wg0.conf 
