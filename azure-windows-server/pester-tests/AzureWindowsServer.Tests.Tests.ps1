$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$ResourceGroupName = 'poshbot'
$Location = 'uksouth'
$VMName = 'poshbot'
$requiredSize = 'Standard_A1_V2'

$rg = Get-AzResourceGroup | Where-Object -Property ResourceGroupName -EQ $ResourceGroupName
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
Describe "Poshbot Server infrastructure" {
  Context "Resource Group" {
    It "Checks that we have a created resource group" {
      $null -eq $rg | Should -Be $false
    }
    It "Resource group is created in the location: $location" {
      $rg.location | Should -Be $Location
    }
  }
  Context "VM" {
    It "Should be in the location: $location" {
        $vm.location | Should -Be $location
    }  
    It "Should be the Size $requiredSize" {
      $vm.HardwareProfile.VmSize | Should -Be $requiredSize
    }
  }
}
