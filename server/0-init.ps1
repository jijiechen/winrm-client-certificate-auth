
$username = $args[0]
$password = $args[1]
$public_key = $args[2]

$ErrorActionPreference = "Stop";

Push-Location
$time =  (date).ToString("yyMMddHHmmss")
$path = "$env:TEMP\init-$time"
Set-Location $path
Write-Host $public_key > user.pub



Invoke-WebRequest -UseBasicParsing -OutFile enable-secure-winrm.ps1 https://raw.githubusercontent.com/jijiechen/winrm-client-certificate-auth/master/server/enable-secure-winrm.ps1
Invoke-WebRequest -UseBasicParsing -OutFile import-client-publickey.ps1 https://raw.githubusercontent.com/jijiechen/winrm-client-certificate-auth/master/server/import-client-publickey.ps1

# Set-ExecutionPolicy -ExecutionPolicy ByPass
.\enable-secure-winrm.ps1

$credential = New-Object -TypeName PSCredential -ArgumentList $username, $(ConvertTo-SecureString $password -AsPlainText -Force)
.\import-client-publickey.ps1 .\user.pub $credential



Pop-Location
Remove-Item -Recurse -Force $path -ErrorAction SilentlyContinue