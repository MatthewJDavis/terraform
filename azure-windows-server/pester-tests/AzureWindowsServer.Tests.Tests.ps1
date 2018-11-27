$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$ResourceGroupName = 'myResourceGroup'
$Location = 'uksouth'

$rg = Get-AzResourceGroup | Where-Object -Property ResourceGroupName -EQ $ResourceGroupName
Describe "AzureWindowsServer.Tests" {
    It "Checks that we have a created resource group" {
        $null -eq $rg | Should -Be $false
    }
    It "Resource group is created in the location: $uksouth" {
        $rg.location | Should -Be $Location
    }

}
