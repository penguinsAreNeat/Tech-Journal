#Scrapped code during making/testing of the program

#======================================================================================================
# Get-Wmi cmdlet
# Get-WmiObject -Class Win32_Service | select Name, PathName, ProcessId

# Filter Get-Wmi output
# Get-WmiObject -list | where { $_.Name -ilike "Win32_*" } | sort-object

 #Get-WmiObject -Class Win32_account | get-member

 # Get network adapter info using Wmi
 # IP addr, gateway, DNS, DHCP

#$Gateway = Get-wmiObject win32_networkadapterconfiguration | select DefaultIPGateway 

#$IPAddr = Get-wmiObject win32_networkadapterconfiguration | select IPaddress 
#$IPAddr = Get-wmiObject win32_networkadapterconfiguration | Where {$_.IPAddress.length -gt 1}

#$DNSServer = Get-wmiObject win32_networkadapterconfiguration | select DNSServerSearchOrder

#$DHCPServer = Get-wmiObject win32_networkadapterconfiguration | select DHCPServer

#Write-Output $IPAddr
#Write-Output $Gateway
#Write-Output $DNSServer
#Write-Output $DHCPServer
#======================================================================================================











# A menu function to simplify usage
function Show-Menu
{
    param (
        [string]$Title = 'My Menu'
    )
    cls
    # Menu opening screen
    Write-Host “================ $Title ================”
    
    Write-Host “1: Press ‘1’ to display IP, Gateway, DHCP, and DNS information.”
    Write-Host “2: Press ‘2’ to export the list of running processes.”
    Write-Host “3: Press ‘3’ to export the list of running services.”
    Write-Host “4: Press ‘4’ to start the Caculator process.”
    Write-Host “5: Press ‘5’ to stop the Calculator process.”
    Write-Host “Q: Press ‘Q’ to quit.”
}



do
{
    #Menu call and choice selection
    Show-Menu
    $input = Read-Host "Please choose a option"
    switch($input)
       {
            '1'{

                
                # This section of code comes from "https://www.kittell.net/code/powershell-ipv4-machine-ip/"
                # The code for the DHCP Server, the DNS server, and the Gateway was done my myself
                # I have no idea what the "root\CIMV2" does, but it works

                $colItems = Get-WmiObject Win32_NetworkAdapterConfiguration -Namespace "root\CIMV2" | where{$_.IPEnabled -eq "True"}

                clear

                # Output function
                Write-Host "# --------------------------------------"
                Write-Host "# Local IP address information"
                Write-Host "# --------------------------------------"
                foreach($objItem in $colItems) {
                    Write-Host "Adapter:" $objItem.Description 
                    Write-Host " DHCP Server:" $objItem.DHCPServer
                    Write-Host " DNS Domain:" $objItem.DNSDomain
                    Write-Host " DNS Servers:" $objItem.DNSServerSearchOrder
                    Write-Host " Hostname:" $objItem.PSComputerName
                    Write-Host " IPv4 Address:" $objItem.IPAddress[0]
                    Write-Host " IPv6 Address:" $objItem.IPAddress[1]
                    Write-Host " Gateway Address:" $objItem.DefaultIPGateway
                    Write-Host " "
                }


            }'2'{
                 # Export running process list
                 Get-Process | Select-Object ProccessName, Path, ID | Export-csv -Path "E:\Misc\Classwork\SYS-320\Week 9\Running_Processes.csv" -NoTypeInformation
                 Write-Host "Output completed"

            }'3'{
                 # Export running service list
                 Get-Service | Where-Object {$_.Status -eq "Running"} | Get-Member | Export-csv -Path "E:\Misc\Classwork\SYS-320\Week 9\Running_Services.csv" -NoTypeInformation
                 Write-Host "Output completed"

            }'4'{
                 # Start calculator process
                 Start-Process calc.exe
                    
            }'5'{
                 # Stop calculator process
                 # I don't know why "Stop-Process calc.exe" doesn't work, but this way does
                 Stop-Process -Name calculatorapp

            }'q'{ # Option to quit loop, located at the end of the menu loop

            }
        }
        pause
}
until ($input -eq 'q')
