
# Charger le module Active Directory
Import-Module ActiveDirectory

# Extraire tous les départements uniques des utilisateurs
Get-ADUser -Filter * -Properties Department |
    Where-Object { $_.Department -ne $null -and $_.Department -ne "" } |
    Select-Object -ExpandProperty Department |
    Sort-Object -Unique