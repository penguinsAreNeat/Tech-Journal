# Storyline: Send email

# Email Body

# Assigns variable value
$mg = "Hello there."
# Assigns variable text color
write-host -BackgroundColor Red -ForegroundColor while $msg

# Email address
$email = "jonathan.stroop@mymail.champlain.edu"

# To address
$toEmail = "deployer@csi-web"

# Send Email
Send-MailMessage -From $email -To $toEmail -Subject "Powershell Email Script Test" -SmtpServer 192.168.6.71

# Variables must start with dollar sign