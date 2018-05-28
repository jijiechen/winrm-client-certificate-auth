

Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

$options = New-PSSessionOption -SkipCACheck # -SkipCNCheck

# Todo: 
# 1. Fetch the public key convenient way?
# 2. Store the public key at somewhere?
# 3. So that we can provide to new servers?

# 4. When authenticating, list convenient?

# Enter-PSSession -UseSsl -SessionOption $options
# -ComputerName 47.93.242.24 -CertificateThumbprint 519E6A9055B41E4A9C76DFFB239A9A50E0E591EC 



