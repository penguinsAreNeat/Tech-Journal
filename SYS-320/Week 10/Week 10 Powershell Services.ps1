# A menu function to simplify usage
function Show-Menu
{
    param (
        [string]$Title = 'Service Log'
    )
    cls
    # Menu opening screen
    Write-Host “================ $Title ================”
    
    Write-Host “1: Press ‘1’ to display log information.”
    Write-Host “2: Press ‘2’ to filter log output based on start/stop.”
    Write-Host “Q: Enter ‘quit’ to quit.”
}

# Array with user options
$myarray = @("running","stopped","all")

do
{
    #Menu call and choice selection
    Show-Menu
    $input = Read-Host "Select a option"
    switch($input)
       {
            '1'{
                Get-Service
                
            }

            '2'{
                # User prompt and read choice variable
                $userChoice = Read-host -Prompt "What service filter would you like? [running, stopped, all]: "

                # List Running Processes
                if ($userChoice -eq $myarray[0]) {
                    Get-Service | Where-Object {$_.Status -eq "Running"}
                }

                # List Stopped Processes
                elseif ($userChoice -eq $myarray[1]) {
                    Get-Service | Where-Object {$_.Status -eq "Stopped"}
                }

                # List All Processes
                elseif ($userChoice -eq $myarray[2]) {
                    Get-Service
                }
                else { Write-Host "Invalid option, try again" }

            }


            'quit'{ # Option to quit loop, located at the end of the menu loop
            }

            # Invalid option catch
            default {
                 "Please choose a valid option `n"
            }

        }
        pause
}
until ($input -eq 'quit')
