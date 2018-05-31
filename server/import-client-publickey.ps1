
$cretificate_path = $args[0]        # Client certificate public key path (*.cer, *.pem)
$credential = $args[1]              # Server login credential
$keep_kerberos = ( $args[2] -eq 'KeepPasswordAuthentication' )


# Import public key to Root and TrustedPeople store

$cretificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
$cretificate.Import( $cretificate_path )

$local_machine = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
$store_names = ( [System.Security.Cryptography.X509Certificates.StoreName]::Root, 
                 [System.Security.Cryptography.X509Certificates.StoreName]::TrustedPeople )

$store_names | ForEach-Object {
    $store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $_, $local_machine
    $store.Open("MaxAllowed")
    $store.Add($cretificate)
    $store.Close()
}





# Map to an account

$sanExt = $cretificate.Extensions | Where-Object { $_.Oid.Value -eq "2.5.29.17" }
$sanObj = New-Object -ComObject X509Enrollment.CX509ExtensionAlternativeNames
$sanObj.InitializeDecode( 1, [System.Convert]::ToBase64String( $sanExt.RawData ) )

$san = $sanObj.AlternativeNames[0].strValue


Invoke-Expression "winrm delete winrm/config/service/certmapping?URI=*+Issuer=$($cretificate.Thumbprint)+Subject=$san"  -ErrorAction SilentlyContinue
New-Item -Path WSMan:\localhost\ClientCertificate `
    -Subject $san `
    -URI * `
    -Issuer $cretificate.Thumbprint `
    -Credential $credential `
    -Force


# Disable Kerberos authentication (Username & Pasword)

if ( -not $keep_kerberos ) {
    Set-Item -Path WSMan:\localhost\Service\Auth\Kerberos -Value $false
}




