# Import module Active Directory
Import-Module ActiveDirectory

# Retrieve all unique departments for users
Get-ADUser -Filter * -Properties Department |
    Where-Object { $_.Department -ne $null -and $_.Department -ne "" } |
    Select-Object -ExpandProperty Department |
    Sort-Object -Unique
