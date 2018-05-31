
# You may source this script into your powershell profile:
#  . .\connect.ps1 <thumbprint>

$private_key_cert_thumbprint = $args[0]

# Enter-PSSession -ComputerName <computer_name> -CertificateThumbprint $private_key_cert_thumbprint -UseSsl -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck)



Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

Function Connect-RemotePS () {
    Param (
            [Parameter(Mandatory=$true, Position=0)]
            [string] $hostname,
            [Parameter(Mandatory=$false, Position=1)]
            [switch] $nocheck
        )

        Function AlreadyTrusted () {
            $request = [System.Net.HttpWebRequest]::Create("https://$($hostname):5986/")
            $request.Timeout = 5000

            try { $request.GetResponse().Dispose() }
            catch [System.Net.WebException]
            {
                if ($_.Exception.Status -eq [System.Net.WebExceptionStatus]::TrustFailure)
                {
                    $key_data = $request.ServicePoint.Certificate.Export( [Security.Cryptography.X509Certificates.X509ContentType]::Cert )

                    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
                    $cert.Import( $key_data )                    

                    $trusted_file = "$home\winrm\trusted-server-thumbprints"
                    $trusted = @()
                    if(Test-Path $trusted_file){
                        $trusted = [System.IO.File]::ReadAllLines( $trusted_file )
                    }
                    
                    if($trusted.IndexOf($cert.Thumbprint) -gt -1){
                        Return $true
                    }

                    Write-Host 'The thumbprint of server certificate is ' -NoNewLine
                    Write-Host $cert.Thumbprint -ForegroundColor Yellow
                    $confirmation = Read-Host 'Do you want to trust this server? (Y/N)'
                    if ( ($confirmation -eq 'Y') -or ($confirmation -eq 'y') ) {
                        [System.IO.Directory]::CreateDirectory("$home\winrm\")
                        Add-Content -Path $trusted_file -Value $cert.Thumbprint -ErrorAction SilentlyContinue
                        Return $true
                    }

                    Return $false
                }
                elseif ($_.Exception.Status -eq [System.Net.WebExceptionStatus]::ProtocolError)
                {
                    # Connection success
                }else{
                    Write-Host "Fail to connect $hostname" -ForegroundColor Red
                    Throw
                }
            }

            Return $false
        }


        if($nocheck -or (AlreadyTrusted)){
            $option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
        }else{
            $option = New-PSSessionOption 
        }

        Enter-PSSession -ComputerName $hostname -CertificateThumbprint $private_key_cert_thumbprint -UseSsl -SessionOption $option        
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



