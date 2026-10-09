# Import module Active Directory
Import-Module ActiveDirectory

# Retrieve all unique departments for users
Get-ADUser -Filter "Department -like '*'" -Properties Department |
    Select-Object -ExpandProperty Department |
    Sort-Object -Unique
