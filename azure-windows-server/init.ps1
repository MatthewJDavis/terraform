$certPath = 'C:\temp\cert.pem'

New-Item C:\temp -ItemType Directory
$uri = 'https://raw.githubusercontent.com/MatthewJDavis/terraform/master/azure-windows-server/cert.pem'
Invoke-WebRequest -Uri $uri -OutFile $certPath

# import the cert

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

Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true

# create local user

$username = "ansible"
$password = ConvertTo-SecureString -String "aRed738£jieYYh2toBeTakenFromVaultinFuture" -AsPlainText -Force
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
