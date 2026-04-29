# Connexion a Exchange Online
Connect-ExchangeOnline

# Ajouter le droits sur la liste de distrib
Add-RecipientPermission -Identity ict@domain.eu -Trustee user.name@domain.eu -AccessRights SendAs

# Verifier les droits sur la liste
Get-RecipientPermission -Identity ict@domain.eu | Select-Object Trustee, AccessControlType, AccessRights