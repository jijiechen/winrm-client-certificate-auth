
WinRM client certificate authentication
==========

Scripts and tools in this repository help you easily setup a secure WinRM endpoint for your windows and connect to it painlessly.

- Folder `client` contains tools for generating client certificates
- Folder `server` contains tools for setting up server
- Folder `ansible` contains an example of connecting to certificate authentication enabled winrm hosts 

Scripts in this repository run on Windows Server 2012 and above systems.

**Warning: scripts in this repository configure Windows Servers to use self-signed certificates (instead of certificates from valid CAs) to secure HTTPS endpoints. A client may take its own risks to connect to these servers. Should you have any concern about security of your server or the connections, you should not use scripts in this repository.**


## Preparation

1. You have a Windows Server with Username and Password authentication enabled (Remote desktop or PSRemoting)
1. You have setup a personal private key (the client certificate) on your local computer. If you haven't done it, here are the steps:
    1. Go to [releases page](https://github.com/jijiechen/winrm-client-certificate-auth/releases) and download `client.zip` from this repo
    1. Extract the archive and execute `.\generate.ps1 <your_name>` to generate a private key in pfx format
    1. Execute this command to import this pfx into your computer: <br />`Import-PfxCertificate -FilePath cert.pfx -CertStoreLocation Cert:\CurrentUser\My`
    1. To obtain your public key, execute this command with the thumbprint value output from the last step: <br /> `. .\connect.ps1 <your_thumbprint>` <br /> `Show-MyPublicKey`


## Enable secure WinRM on your Windows Server

Replace username, password and user public key in following command line to your values and execute it on your server, everthing will work:

```ps1
(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/jijiechen/winrm-client-certificate-auth/master/serve
r/0-init.ps1") | iex ; Init-SecureWinRM "your_username" "your_password" "-----YOUR PUBLIC KEY CERTIFICATE-----"
```

What it does:
- Enable WinRM with an HTTPS endpoint, which was secured by a self-signed certificate
- Disable the defaultly enabled HTTP endpoint in WinRM
- Enable the `Certificate` authentication
- Disable the `Kerberos` authentication (Authenticate by username and password pair)
- Make a firewall exception for the secure WinRM port (5986)
- Import the public key of client certificate onto server and map it to the given credential 

It will also cleanup existing HTTPS endpoint, firewall rule and cert user mapping if there is so that this script is able to be executed and retried.

Tip: the script will print thumbprint of generated server certificate. You can write it down and compare this value on connecting. 


## Connect to a secure WinRM Windows Server

On the client machine, add your server into trusted host list and use the builtin commands to connect: `Enter-PSSession`, `Connect-PSSession`, etc.
e.g.
```ps1
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value <your_server_hostname> -Force -Concatenate
Enter-PSSession -ComputerName <your_server_hostname> -UseSsl -CertificateThumbprint <your_thumbprint> 
```

If you run into errors complaining certificate validation errors, that's normal and proves the server is configured correctly. The error occurs because the server uses self-generated certificates instead of certificates issued from a valid CA. The certificate checking is normally very strict, valiation errors on authority or CN of a certificate indicate multiple types of certificate attacking (e.g. man-in-the-middle).

If your server runs in a trusted network, or if you trust the connection anyway, just ignore the certificate warnings:
```ps1
Enter-PSSession -ComputerName <your_server_hostname> -UseSsl -CertificateThumbprint <your_thumbprint> -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck)
```

This repo also provides a convenient way to connect to remote PowerShell sessions. Just source the `connect.ps1` using dot(.) and execute `Connect-RemotePS` function:
```ps1
. .\connect.ps1 <your_thumbprint>   # Only need to run once. It's suggested to source it from your powershell profile
Connect-RemotePS <your_server_hostname>    # This may throw certificate errors
Connect-RemotePS <your_server_hostname> -NoCheck
```

Again, if you don't know what you are doing, stop using it. So use them at your own risk.
