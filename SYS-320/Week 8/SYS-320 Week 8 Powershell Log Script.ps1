# Storyline: Review Security Log

# Save file location
$folder = "C:\Users\jonpe\Downloads\"

# List all event lots
                   #Test Code
Get-EventLog -list #|select Log

# Create prompt to select log view
$readLog = Read-host -Prompt "Please select a log to check from the list"

# Print log
Get-EventLog -LogName $readLog -Newest 40 | export-csv -NoTypeInformation -Path "$folder\securityLog.csv"

# Check if user wants to filter search
$searchBool = Read-host -Prompt "Do you want to filter your search? [Y/N]"

# Filter search
if ($searchBool -eq "Y")
{
    # Get search term and filter logs
    $searchTerm = Read-host -Prompt "What value do you want to filter by"
    Get-EventLog -LogName $readLog -Newest 100 | Where-Object {$_.Message -match "$searchTerm"}

    # Check if user wants to save filtered output
    $printBool = Read-host -Prompt "Save output? [Y/N]"
    if ($printBool -eq "y")
       { Get-EventLog -LogName $readLog -Newest 100 | Where-Object {$_.Message -match "$searchTerm"} | export-csv -Path "$folder\SecurityLogFiltered.csv"}
}
echo "Ending script"
