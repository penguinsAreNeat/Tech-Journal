# Create firewall rulesets based of of given web resources

# Threat intel websites
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules','https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

# Rules list
foreach ($i in $drop_urls) {
    
    # Extract files
    $temp = $i.split("/")
    $file_name = $temp[-1]
    # Uses last element in array for filename

# Download files if they do not exist, otherwise ignore
    if (Test-Path $file_name) {
        continue
    }
    else {
        # Download files
        Invoke-WebRequest -Uri $i -Outfile $file_name
    }
}


# Array of filenames
$input_paths = @('.\compromised-ips.txt','.\emerging-botcc.rules')

# Extract IP addresses
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Place extracted ip addresses in "ips-bad.tmp"
select-string -Path $input_paths -Pattern $regex_drop | `
ForEach-Object { $_.Matches } | `
ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"

# Function to show file creation
function Firewall-Created {

    param ($firewallType, $firewallName)

    
    Write-Host "`n$firewallType firewall was created as '$firewallName' in current directory"
}

# Firewall menu
Write-Host ' ======= IP Ruleset Generator ======= '
Write-Host 'Press "I" for a IPTables ruleset'
Write-Host 'Press "W" for a Windows ruleset'
Write-Host 'Press "M" for a Mac ruleset'

$userChoice = Read-Host -p "What type of ruleset would you like? [I/W/M]"
switch ($userChoice) {

	# IPTables firewall ruleset
    'I' {
        # Convert to IPTables syntax
        # iptables -A INPUT -s IP -j DROP
        (Get-Content -Path ".\ips-bad.tmp") | % {$_ -replace "^", "iptables -A INPUT -s " -replace "$", "-j DROP" } | `
        Out-File -FilePath "iptables.bash"
        Firewall-Created -firewallType "IPTables" -firewallName "iptables.bash"
    }

	# Windows netsh firewall ruleset
    'W' {
        ForEach ($i in Get-Content ".\ips-bad.tmp") {
           Write-Output "netsh advfirewall firewall add rule name=`"BLOCK IP ADDRESS - $i`" dir=in action=block remoteip=$i" | ` 
           Out-File -FilePath "iptables.netsh" -Append
        }
        Firewall-Created -firewallType "Windows" -firewallName "iptables.netsh"        
    }

       # Mac firewall ruleset
    'M' {
       # Firewall header that is required in Mac firewalls
        Write-Output '
srcub-anchor "com.apple/*"
nat-anchor "com.apple/*"
rdr-anchor "com.apple/*"
dummynet-anchor "com.apple/*"
anchor "com.apple/*"
load anchor "com.apple" from "/etc/pf.anchors/com.apple"

		' | Out-File -FilePath "pf.conf"

        ForEach ($i in Get-Content ".\ips-bad.tmp") {
            Write-Output "block in from $i to any" | ` 
            Out-File -FilePath "pf.conf" -Append
        }

        Firewall-Created -firewallType "Mac" -firewallName "pf.conf"
    }
}
