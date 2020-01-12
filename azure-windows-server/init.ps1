# Script that will set up a Windows server 2016 for https WinRM remoting with a user certificate.
# Self signed cert generated on the server used for listener

#region initial setup, get public cert of user
$certPath = 'C:\temp\cert.pem'
New-Item C:\temp -ItemType Directory
$uri = 'https://raw.githubusercontent.com/MatthewJDavis/terraform/master/azure-windows-server/cert.pem'
Invoke-WebRequest -Uri $uri -OutFile $certPath
#endregion

#region Set up WinRM Https listener with self signed cert
$SubjectName = $env:ComputerName
$CertStoreLocation = 'Cert:\LocalMachine\My'

$cert = New-SelfSignedCertificate -DnsName $env:ComputerName -CertStoreLocation $CertStoreLocation 

# Create the hashtables of settings to be used.
$valueset = @{
  Hostname              = $SubjectName
  CertificateThumbprint = $cert.Thumbprint
}

$selectorset = @{
  Transport = "HTTPS"
  Address   = "*"
}

Write-Verbose "Enabling SSL listener."
New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset

# set firewall
$fwRuleName = 'winRM-HTTPS'
New-NetFirewallRule -Name $fwRuleName -DisplayName $fwRuleName -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow -Enabled True -Profile Any

#endregion

#region import user cert

$cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import("$certPath")

$store_name = [System.Security.Cryptography.X509Certificates.StoreName]::Root
$store_location = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
$store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $store_name, $store_location
$store.Open("MaxAllowed")
$store.Add($cert)
$store.Close()


$cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import("$certPath")

$store_name = [System.Security.Cryptography.X509Certificates.StoreName]::TrustedPeople
$store_location = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
$store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $store_name, $store_location
$store.Open("MaxAllowed")
$store.Add($cert)
$store.Close()
#endregion

#region local user
Add-Type -AssemblyName System.Web
$username = "ansible"
$generatedPassword = [System.Web.Security.Membership]::GeneratePassword(20, 0)

$password = ConvertTo-SecureString -String "$generatedPassword" -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password


New-LocalUser -Name $username -AccountNeverExpires -Description 'ansible user' -PasswordNeverExpires -Password $credential.Password
Add-LocalGroupMember -Group Administrators -Member 'ansible'
#endregion

#region certificate for WinRM endpoint
$thumbprint = (Get-ChildItem -Path cert:\LocalMachine\root | Where-Object { $_.Subject -eq "CN=$username" }).Thumbprint

New-Item -Path WSMan:\localhost\ClientCertificate `
  -Subject "$username@localhost" `
  -URI * `
  -Issuer $thumbprint `
  -Credential $credential `
  -Force

Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
#endregion