# This code uses powershell commands to obtain data, save it to .csv files, and zip them together with a file hash

# Create folder for export files
# Note: This outputs files to where the script is being executed from, not in the same folder as the script
    $localPath=(Get-Location).toString()
    New-Item -Path "$localPath\Forensic_Output_Files" -ItemType Directory



# Creating user menu
function Show-Menu
{
    param (
        [string]$Title = 'Forensic Tookit v0.9'
    )
    cls
    # Menu opening screen
    Write-Host “================ $Title ================”
    
    Write-Host “1: Press ‘1’ to get all supported forensic files.”
    Write-Host “2: Press ‘2’ to choose a specific forensic option.”
    Write-Host "3: Press '3' to change the file export location."
    Write-Host "4: Press '4' to create file hashes and zip all files."
    Write-Host “Q: Enter ‘q’ to quit.”
}



# Setting up array for menu
    $arrCom = @("Test")

# 1 Get Running Processes and Path
    $arrCom += {Get-Process | Export-Csv .\Forensic_Output_Files\Running_Processes.csv -NoTypeInformation}

# 2 Get all registered services and path
    $arrCom += {Get-WmiObject -Namespace ROOT\CIMV2 -Class Win32_Service | Export-Csv .\Forensic_Output_Files\Registered_Services.csv -NoTypeInformation}

# 3 Get all TCP network sockets
    $arrCom += {Get-NetTCPConnection | Export-Csv .\Forensic_Output_Files\TCP_Connections.csv -NoTypeInformation}

# 4 Get all user account information
    $arrCom += {get-WMIObject Win32_UserAccount | Export-Csv .\Forensic_Output_Files\User_Accounts.csv -NoTypeInformation}

# 5 Get all Network Adapter Configuration info
    $arrCom += {Get-WmiObject Win32_NetworkAdapterConfiguration | Export-Csv .\Forensic_Output_Files\Network_Adapter_Config.csv -NoTypeInformation}

# 6 Get last 1000 Event Logs
    # This was chosen as event logs can be very important in tracking down malware (only the last 1000 are saved for the sake of demonstration)
    $arrCom += {Get-EventLog -list | %{ Get-EventLog $_.Log -Newest 1000 } | Export-Csv .\Forensic_Output_Files\Event_Logs.csv -NoTypeInformation}

# 7 Get all "on startup" processes
    # This was chosen as some types of malware will attempt to use the "on startup" to run without the user's knowledge
    $arrCom += {Get-CimInstance win32_service -Filter "startmode = 'auto'" | Export-Csv .\Forensic_Output_Files\Startup_Processes.csv -NoTypeInformation}

# 8 Get all Hotfixes applied to the computer
    # This was chosen as while it can be easy to get the OS version, it can take more time to check all applied hotfixes, ob
    $arrCom += {Get-Hotfix | Export-Csv .\Forensic_Output_Files\Applied_Hotfixes.csv -NoTypeInformation}

# 9 Get all scheduled tasks
    # This was chosen as malware may shedule itself to run at certain points
    $arrCom += {Get-ScheduledTask | Export-Csv .\Forensic_Output_Files\Scheduled_Tasks.csv -NoTypeInformation}



# 10 Export hash of all files to new document
$saveLocation = ".\Forensic_Output.zip"
function hash_files($saveLocation) {
    # Delete past hash file
    if (Test-Path ".\Forensic_Output_Files\File_Hashes.txt") {Remove-Item ".\Forensic_Output_Files\File_Hashes.txt" -Verbose}

    $files = Get-ChildItem ".\Forensic_Output_Files"
    foreach ($i in $files){
        Get-FileHash $i.FullName | Format-List * | Out-File .\Forensic_Output_Files\File_Hashes.txt -Append
    }
        
    # Create zip file
    Compress-Archive -Path .\Forensic_Output_Files\* -DestinationPath $saveLocation -Verbose
    $addHash = Read-Host "Would you like to add a hash of the zipped file? [y/n]"
    # This is bad coding practice but it works
    if ($addHash -match 'y') { Get-FileHash $saveLocation | Format-List * | Out-File -FilePath ($saveLocation + "_hash.txt")
    }
}
 
 
    
# Initalize menu
do
{
    #Menu call and choice selection
    Show-Menu
    $input = Read-Host "Select a option"
    switch($input)
       {
            '1'{
                foreach ($element in $arrCom) {
                #Write-Host $element
                Invoke-Command $element
                }
            }

            '2'{
                Write-Host “`n================ Forensic files ================”
    
                Write-Host “1: Press ‘1’ to get Running Processes and Path.”
                Write-Host “2: Press ‘2’ to choose a specific forensic option.”
                Write-Host "3: Press '3' to change the file export location."
                Write-Host "4: Press '4' to create file hashes and zip all files."
                Write-Host "5: Press '5' to get all registered services and path"
                Write-Host "6: Press '6' to get last 1000 Event Logs"
                Write-Host "7: Press '7' to get all 'on startup' processes"
                Write-Host "8: Press '8' to get all hotfixes applied to the computer"
                Write-Host "9: Press '9' to get all scheduled tasks"

                $fileChoice = Read-Host "Enter the number of the forensic file that you want to get"
                
                if ($fileChoice -match '[0-9]') {
                    #Write-Host $arrCom[$fileChoice]
                    Invoke-Command $arrCom[$fileChoice]
                }
            }

            '3' {
                Write-Host "By default, the zip will be saved to '$saveLocation'"
                $changeLocation = Read-Host "Would you like to change it? [y/n]"
                if ($changeLocation -match "y") {
                    $saveLocation = Read-Host "Enter the new save location, including file name and .zip"
                }
            }

            '4'{
                hash_files($saveLocation)
            }

            'q'{ # Option to quit loop, located at the end of the menu loop
            }

            # Invalid option catch
            default {
                 "Please choose a valid option `n"
            }

        }
        pause
}
until ($input -eq 'q')
