##Get the Exchange module
##Skip this line if you already have it
Install-Module ExchangeOnlineManagement

##Connection to Exchange online 
Connect-ExchangeOnline -UserPrincipalName user.name@domain.eu

##Change the mailbox setting
Set-Mailbox test.de@domain.eu -MessageCopyForSentAsEnabled $true