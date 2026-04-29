# Split path
$Path = Split-Path -Parent "C:\Version\*.*"

# Create variable for the date stamp in log file
$LogDate = Get-Date -f yyyyMMddhhmm

# Define CSV and log file location variables
# They have to be on the same location as the script
$Csvfile = $Path + "\AllADUsers_$logDate.csv"

# Import Active Directory module
Import-Module ActiveDirectory

# Set distinguishedName as searchbase, you can use one OU or multiple OUs
# Or use the root domain like DC=exoip,DC=local
$DNs = @(
    "OU=Users,OU=Benelux,DC=domain,DC=fr",
    "OU=Users,OU=Czechia,DC=domain,DC=fr",
    "OU=Users,OU=France,DC=domain,DC=fr",
    "OU=Users,OU=Germany,DC=domain,DC=fr",
    "OU=Users,OU=Group,DC=domain,DC=fr",
    "OU=Admins,OU=Group,DC=domain,DC=fr",
    "OU=Users,OU=Italy,DC=domain,DC=fr",
    "OU=Users,OU=Poland,DC=domain,DC=fr",
    "OU=Users,OU=Portugal,DC=domain,DC=fr",
    "OU=Users,OU=Romania,DC=domain,DC=fr",
    "OU=Users,OU=Spain,DC=domain,DC=fr",
    "OU=Users,OU=United Kingdom,DC=domain,DC=fr"
)

# Create empty array
$AllADUsers = @()

# Loop through every DN
foreach ($DN in $DNs) {
    $Users = Get-ADUser -SearchBase $DN -Filter * -Properties * 

    # Add users to array
    $AllADUsers += $Users
}

# Create list
$AllADUsers | Sort-Object Name | Select-Object `
@{Label = "First name"; Expression = { $_.GivenName } },
@{Label = "Last name"; Expression = { $_.Surname } },
@{Label = "Display name"; Expression = { $_.DisplayName } },
@{Label = "User logon name"; Expression = { $_.SamAccountName } },
@{Label = "User principal name"; Expression = { $_.UserPrincipalName } },
@{Label = "Country/region"; Expression = { $_.Country } },
@{Label = "Job Title"; Expression = { $_.Title } },
@{Label = "Department"; Expression = { $_.Department } },
@{Label = "Company"; Expression = { $_.Company } },
@{Label = "Manager"; Expression = { % { (Get-AdUser $_.Manager -Properties DisplayName).DisplayName } } },
@{Label = "Description"; Expression = { $_.Description } },
@{Label = "Office"; Expression = { $_.Office } },
@{Label = "Telephone number"; Expression = { $_.telephoneNumber } },
@{Label = "E-mail"; Expression = { $_.Mail } },
@{Label = "Mobile"; Expression = { $_.mobile } },
@{Label = "Account status"; Expression = { if (($_.Enabled -eq 'TRUE') ) { 'Enabled' } Else { 'Disabled' } } },
@{Label = "Last logon date"; Expression = { $_.lastlogondate } }|

# Export report to CSV file
Export-Csv -Encoding UTF8 -Path $Csvfile -NoTypeInformation #-Delimiter ";"