$certPath = 'C:\temp\cert.pem'

New-Item C:\temp -ItemType Directory
$uri = 'https://raw.githubusercontent.com/MatthewJDavis/terraform/master/azure-windows-server/cert.pem'
Invoke-WebRequest -Uri $uri -OutFile $certPath

#region Set up WinRM Https listener with self signed cert

$SubjectName = $env:ComputerName
$CertValiditDays = 1095
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

netsh advfirewall firewall add rule name="WinRM-HTTPS-test" dir=in localport=5986 protocol=TCP action=allow


$fwRuleName = 'winRM-HTTPS'
New-NetFirewallRule -Name $fwRuleName -DisplayName $fwRuleName -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow -Enabled True -Profile Any

#endregion



# import the user cert

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


# create local user
[Reflection.Assembly]::LoadWithPartialName(“System.Web”)
$username = "ansible"
$generatedPassword = [System.Web.Security.Membership]::GeneratePassword(20, 0)

$password = ConvertTo-SecureString -String $generatedPassword -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password


New-LocalUser -Name 'ansible' -AccountNeverExpires -Description 'ansible user' -PasswordNeverExpires -Password $credential.Password
Add-LocalGroupMember -Group Administrators -Member 'ansible'


# Add cert to endpoint for user

# This is the issuer thumbprint which in the case of a self generated cert
# is the public key thumbprint, additional logic may be required for other
# scenarios
$thumbprint = (Get-ChildItem -Path cert:\LocalMachine\root | Where-Object { $_.Subject -eq "CN=$username" }).Thumbprint

New-Item -Path WSMan:\localhost\ClientCertificate `
  -Subject "$username@localhost" `
  -URI * `
  -Issuer $thumbprint `
  -Credential $credential `
  -Force

  Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
