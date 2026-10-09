[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Username
)

try {
    # Get the AD user object
    $User = Get-ADUser -Identity $Username -Properties WhenChanged -ErrorAction Stop

    $WhenChanged = $User.WhenChanged
    Write-Host "The account '$Username' was last changed (deactivated) on: $WhenChanged"
} catch {
    Write-Host "Account '$Username' not found in Active Directory or an error occurred."
}
