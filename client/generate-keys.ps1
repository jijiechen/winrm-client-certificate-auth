
$username = $args[0]
$output_path = $(pwd).Path


.\generate.ps1 $username "$output_path\cert.pfx"

Push-Location
Set-Location $(Split-Path $MyInvocation.MyCommand.Path)

.\openssl\openssl.exe pkcs12 -in "$output_path\cert.pfx" -out "$output_path\cert.pem" -nokeys -password pass:
.\openssl\openssl.exe pkcs12 -in "$output_path\cert.pfx" -out "$output_path\cert.key" -passin "pass:" -passout "pass:123456"
.\openssl\openssl.exe rsa -in "$output_path\cert.key" -out "$output_path\cert.key.pem" -passin "pass:123456"
Remove-Item "$output_path\cert.key"

Pop-Location

