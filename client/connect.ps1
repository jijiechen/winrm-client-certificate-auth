
# You may source this script into your powershell profile:
#  . .\connect.ps1 <thumbprint>

$private_key_cert_thumbprint = $args[0]




Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Enter-PSSession -ComputerName <computer_name> -CertificateThumbprint $private_key_cert_thumbprint -UseSsl -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck)


Function Connect-RemotePS ($hostname) {
    Enter-PSSession -ComputerName $hostname -CertificateThumbprint $private_key_cert_thumbprint -UseSsl -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck)
}


Function Show-MyPublicKey () {
    $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $private_key_cert_thumbprint }

    if( -not ($cert -eq $null) ){
        $public_key_bytes = $cert.Export( [System.Security.Cryptography.X509Certificates.X509ContentType]::Cert )
        $public_key = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
        $public_key.Import([byte[]]$public_key_bytes)

        Write-Host "-----BEGIN CERTIFICATE-----"
        Write-Host $(( [System.Convert]::ToBase64String($public_key.RawData) -Replace ".{64}", "$&`n" ).Trim())
        Write-Host "-----END CERTIFICATE-----"
    }
}



