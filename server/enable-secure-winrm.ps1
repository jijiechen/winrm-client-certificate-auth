
$hostname = $args[0]
$cert_thumbprint = $args[1]  # Supports pre-installed certificate



Enable-PSRemoting -SkipNetworkProfileCheck -Force
winrm quickconfig


if($cert_thumbprint -eq $null) {
    $cert = New-SelfSignedCertificate -DnsName $hostname -CertStoreLocation cert:\LocalMachine\My
    $cert_thumbprint = $cert.ThumbPrint
}

winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$hostname`";CertificateThumbprint=`"$($cert.ThumbPrint)`"}"
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true

New-NetFirewallRule -DisplayName 'Windows Remote Management (HTTPS-In)' `
    -Name 'Windows Remote Management (HTTPS-In)' `
    -Direction Inbound -Action Allow `
    -Profile Any -LocalPort 5986 -Protocol TCP -RemoteAddress Any

winrm delete winrm/config/Listener?Address=*+Transport=HTTP
