
$hostname = $args[0]                    # HTTPS endpoint hostname
$stored_cert_thumbprint = $args[1]      # Supports pre-installed certificate
$keep_http = ( $args[2] -eq 'KeepHttpEndpoint' )



Enable-PSRemoting -SkipNetworkProfileCheck -Force
winrm quickconfig -q

if($hostname -eq $null) {
    $hostname = $env:ComputerName
}

if($stored_cert_thumbprint -eq $null) {
    $cert = New-SelfsignedCertificateEx -Subject "CN=$hostname" -SAN $hostname `
                -EKU "1.3.6.1.5.5.7.3.1" -StoreLocation "LocalMachine" `
                -KeyLength 2048 -NotAfter $([Datetime]::Now.AddYears(5))

    $stored_cert_thumbprint = $cert.ThumbPrint
}

Write-Host "Configuring HTTPS endpoint for host '$hostname' using certificate thumbprint '$stored_cert_thumbprint'"

Invoke-Expression "winrm delete winrm/config/listener?Transport=HTTPS+Address=*" -ErrorAction SilentlyContinue
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$hostname`";CertificateThumbprint=`"$stored_cert_thumbprint`"}"
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true

Remove-NetFirewallRule -DisplayName 'Windows Remote Management (HTTPS-In)' -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName 'Windows Remote Management (HTTPS-In)' `
    -Name 'Windows Remote Management (HTTPS-In)' `
    -Direction Inbound -Action Allow `
    -Profile Any -LocalPort 5986 -Protocol TCP -RemoteAddress Any

if (-not $keep_http){
    winrm delete winrm/config/Listener?Address=*+Transport=HTTP
}



