<#
.SYNOPSIS
  Short description
.DESCRIPTION
  Long description
.EXAMPLE
  PS C:\> <example usage>
  Explanation of what the example does
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes
#>

$Location = 'northeurope'
$RGName = 'terraform-state'
$StorageAccountName = 'mdterraform'
$Tags = @{'Project' = 'terraform'; 'Environment' = 'Demo' }
$ContainerName = 'demo-state'

New-AzResourceGroup -Name $RGName -Location $Location -Tag $tags

$storageParams = @{
  'ResourceGroupName'      = $RGName 
  'Name'                   = $StorageAccountName 
  'SkuName'                = 'Standard_LRS' 
  'EnableHttpsTrafficOnly' = $true 
  'Location'               = $Location 
  'Kind'                   = 'BlobStorage' 
  'AccessTier'             = 'Hot'
  'Tag'                    = $tags
}

New-AzStorageAccount @storageParams

#region storageContext
$key = (Get-AzStorageAccountKey -ResourceGroupName $RGName -Name $StorageAccountName)[0].value

$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key
#endregion storageContext

#region container
New-AzStorageContainer -Name $ContainerName -Permission Off -Context $ctx
#endregion container

$SASToken = New-AzStorageAccountSASToken -Service Blob -Permission rwdl -Context $ctx -Protocol HttpsOnly -ResourceType Service, Container, Object -ExpiryTime (get-date).AddDays(1)

# if using bash, zsh export ARM_SAS_TOKEN=''

New-Item -Path env: -Name ARM_SAS_TOKEN -Value $SASToken