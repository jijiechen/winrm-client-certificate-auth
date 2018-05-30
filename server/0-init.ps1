
$hostname = $args[0]
$username = $args[1]
$password = $args[2]

$pubkey = "$( $(pwd).Path )\user.pub"
# todo: cp public key from .pem file to $pubkey


Invoke-WebRequest -UseBasicParsing -OutFile enable-secure-winrm.ps1 https://raw.githubusercontent.com/jijiechen/winrm-client-certificate-auth/master/server/enable-secure-winrm.ps1
Invoke-WebRequest -UseBasicParsing -OutFile import-client-publickey.ps1 https://raw.githubusercontent.com/jijiechen/winrm-client-certificate-auth/master/server/import-client-publickey.ps1

Set-ExecutionPolicy -ExecutionPolicy ByPass
./enable-secure-winrm.ps1 <hostname>

$credential = New-Object -TypeName PSCredential -ArgumentList $username, $(ConvertTo-SecureString $password -AsPlainText -Force)
./import-client-publickey.ps1 $pubkey $credential



