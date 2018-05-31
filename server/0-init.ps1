
Function Init-SecureWinRM(){
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $UserName,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $Password,
         [Parameter(Mandatory=$true, Position=2)]
         [string] $PublicKey
    )

    $ErrorActionPreference = "Stop";

    Push-Location
    $time =  (date).ToString("yyMMddHHmmss")
    $path = "$env:TEMP\init-$time"
    [System.IO.Directory]::CreateDirectory($path)

    Set-Location $path
    Write-Output $PublicKey > user.pub


    Invoke-WebRequest -UseBasicParsing -OutFile New-SelfSignedCertificateEx.ps1 https://raw.githubusercontent.com/jijiechen/winrm-client-certificate-auth/master/server/New-SelfSignedCertificateEx.ps1
    Invoke-WebRequest -UseBasicParsing -OutFile enable-secure-winrm.ps1 https://raw.githubusercontent.com/jijiechen/winrm-client-certificate-auth/master/server/enable-secure-winrm.ps1
    Invoke-WebRequest -UseBasicParsing -OutFile import-client-publickey.ps1 https://raw.githubusercontent.com/jijiechen/winrm-client-certificate-auth/master/server/import-client-publickey.ps1
    

    # Set-ExecutionPolicy -ExecutionPolicy ByPass
    . .\New-SelfSignedCertificateEx.ps1
    .\enable-secure-winrm.ps1

    $credential = New-Object -TypeName PSCredential -ArgumentList $UserName, $(ConvertTo-SecureString $Password -AsPlainText -Force) 
    .\import-client-publickey.ps1 "$path\user.pub" $credential



    Pop-Location
    Remove-Item -Recurse -Force $path -ErrorAction SilentlyContinue
}