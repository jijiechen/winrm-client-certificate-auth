

# This script supports Windows 8 / Windows Server 2012 and above
# For lower systems, please use  New-SelfSignedCertificateEx from https://gallery.technet.microsoft.com/scriptcenter/Self-signed-certificate-5920a7c6


# set the name of the local user that will have the key mapped
$username = $args[0]
$output_path = `pwd`

# instead of generating a file, the cert will be added to the personal
# LocalComputer folder in the certificate store
$cert = New-SelfSignedCertificate -Type Custom `
    -Subject "/C=CN/ST=Beijing/L=Dongcheng/emailAddress=jijie.chen@outlook.com/organizationName=DevOps/CN=$username" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=$username@localhost") `
    -KeyUsage DigitalSignature,KeyEncipherment `
    -KeyAlgorithm RSA `
    -KeyLength 2048

# export the public key
$pem_output = @()
$pem_output += "-----BEGIN CERTIFICATE-----"
$pem_output += [System.Convert]::ToBase64String($cert.RawData) -replace ".{64}", "$&`n"
$pem_output += "-----END CERTIFICATE-----"
[System.IO.File]::WriteAllLines("$output_path\cert.pem", $pem_output)

# export the private key into a pem
[System.IO.File]::WriteAllBytes("$output_path\cert.key.pem", $cert.Export(X509ContentType.Cert))

# export the private key into a pfx
[System.IO.File]::WriteAllBytes("$output_path\cert.pfx", $cert.Export(X509ContentType.Pfx))


