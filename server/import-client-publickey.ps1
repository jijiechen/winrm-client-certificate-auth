
$certificate_path = $args[0]        # Client certificate public key path (*.cer, *.pem)
$credential = $args[1]              # Server login credential
$keep_kerberos = ( $args[2] -eq 'KeepPasswordAuthentication' )


# Import public key to Root and TrustedPeople store

$certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
$certificate.Import( $certificate_path )

$local_machine = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
$store_names = ( [System.Security.Cryptography.X509Certificates.StoreName]::Root, 
                 [System.Security.Cryptography.X509Certificates.StoreName]::TrustedPeople )

$store_names | ForEach-Object {
    $store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $_, $local_machine
    $store.Open("MaxAllowed")
    $store.Add($certificate)
    $store.Close()
}





# Map to an account

$sanExt = $certificate.Extensions | Where-Object { $_.Oid.Value -eq "2.5.29.17" }
$sanObj = New-Object -ComObject X509Enrollment.CX509ExtensionAlternativeNames
$sanObj.InitializeDecode( 1, [System.Convert]::ToBase64String( $sanExt.RawData ) )
$san = $($sanObj.AlternativeNames[0] | Select -Property *).strValue


Invoke-Expression "winrm delete winrm/config/service/certmapping?URI=*+Issuer=$($certificate.Thumbprint)+Subject=$san"  -ErrorAction SilentlyContinue
New-Item -Path WSMan:\localhost\ClientCertificate `
    -Subject $san `
    -URI * `
    -Issuer $certificate.Thumbprint `
    -Credential $credential `
    -Force


# Disable Kerberos authentication (Username & Pasword)

if ( -not $keep_kerberos ) {
    Set-Item -Path WSMan:\localhost\Service\Auth\Kerberos -Value $false
}




