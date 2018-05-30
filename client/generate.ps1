# This script supports Windows 8 / Windows Server 2012 and above
# For lower systems, please use  New-SelfSignedCertificateEx from https://gallery.technet.microsoft.com/scriptcenter/Self-signed-certificate-5920a7c6
$username = $args[0]



$output_path = $(pwd).Path

$cert = New-SelfSignedCertificate -Type Custom `
    -Subject "C=CN,ST=Beijing,L=Dongcheng,O=DevOps,CN=$username" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=$username@localhost") `
    -KeyUsage DigitalSignature,KeyEncipherment `
    -KeyAlgorithm RSA `
    -KeyLength 2048

[System.IO.File]::WriteAllBytes("$output_path\cert.pfx", $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx))

Push-Location
Set-Location $(Split-Path $MyInvocation.MyCommand.Path)

.\openssl\openssl.exe pkcs12 -in "$output_path\cert.pfx" -out "$output_path\cert.pem" -nokeys -password pass:
.\openssl\openssl.exe pkcs12 -in "$output_path\cert.pfx" -out "$output_path\cert.key" -passin "pass:" -passout "pass:123456"
.\openssl\openssl.exe rsa -in "$output_path\cert.key" -out "$output_path\cert.key.pem" -passin "pass:123456"
Remove-Item "$output_path\cert.key"

Pop-Location

