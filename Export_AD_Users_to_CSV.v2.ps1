# Define script location dynamically
$Path = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Path) { $Path = "." }

# Create variable for the date stamp in log file
$LogDate = Get-Date -f yyyyMMddhhmm

# Define CSV file location variable
$Csvfile = Join-Path -Path $Path -ChildPath "AllADUsers_$logDate.csv"

# Import Active Directory module
Import-Module ActiveDirectory

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

# Required properties to retrieve
$props = @(
    "GivenName", "Surname", "DisplayName", "SamAccountName", "UserPrincipalName",
    "Country", "Title", "Department", "Company", "Manager", "Description",
    "Office", "telephoneNumber", "Mail", "mobile", "Enabled", "lastlogondate"
)

# Collect all users into a pipeline
$AllADUsers = foreach ($DN in $DNs) {
    try {
        Get-ADUser -SearchBase $DN -Filter * -Properties $props -ErrorAction SilentlyContinue
    } catch {
        Write-Warning "Could not search DN: $DN"
    }
}

# Process and export
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
@{Label = "Manager"; Expression = {
    if ($_.Manager) {
        if ($_.Manager -match '^CN=(?<Name>(?:[^,\\]|\\.)+)') { $Matches.Name.Replace('\', '') } else { $_.Manager }
    }
}},
@{Label = "Description"; Expression = { $_.Description } },
@{Label = "Office"; Expression = { $_.Office } },
@{Label = "Telephone number"; Expression = { $_.telephoneNumber } },
@{Label = "E-mail"; Expression = { $_.Mail } },
@{Label = "Mobile"; Expression = { $_.mobile } },
@{Label = "Account status"; Expression = { if ($_.Enabled) { 'Enabled' } else { 'Disabled' } } },
@{Label = "Last logon date"; Expression = { $_.lastlogondate } } |
Export-Csv -Encoding UTF8 -Path $Csvfile -NoTypeInformation

Write-Output "Exported to $Csvfile"
