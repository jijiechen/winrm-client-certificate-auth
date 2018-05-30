# This script supports Windows 8 / Windows Server 2012 and above
# For lower systems, please use  New-SelfSignedCertificateEx from https://gallery.technet.microsoft.com/scriptcenter/Self-signed-certificate-5920a7c6
$username = $args[0]
$outfile = $args[1]

if($outfile -eq $null){
    $output_path = $(pwd).Path
    $outfile = "$output_path\cert.pfx"
}




$cert = New-SelfSignedCertificate -Type Custom `
    -Subject "C=CN,ST=Beijing,L=Dongcheng,O=DevOps,CN=$username" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=$username@localhost") `
    -KeyUsage DigitalSignature,KeyEncipherment `
    -KeyAlgorithm RSA `
    -KeyLength 2048

[System.IO.File]::WriteAllBytes($outfile, $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx))
Write-Host "New self signed certificate generated at $outfile"
Write-Host "Thumbprint: $($cert.Thumbprint)"