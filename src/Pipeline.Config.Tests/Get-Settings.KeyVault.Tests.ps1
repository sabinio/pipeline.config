param($ModulePath)

BeforeAll {
	Set-StrictMode -Version 1.0
	if (-not $PSBoundParameters.ContainsKey("ProjectName")) { $ProjectName = (get-item $PSScriptRoot).basename -replace ".tests", "" }
	if (-not $PSBoundParameters.ContainsKey("ModulePath")) { $ModulePath = "$PSScriptRoot\..\$ProjectName.module" }

    get-module Pipeline.Config | Remove-Module -force
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/Internal/*.ps1")) {
        . $function 
    }
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/*.ps1")) {
        . $function
    }
}
Describe 'Get-SettingsFromKeyVault' {

    It "KeyVaultConfigs are loaded from the KV in config" {
        $KeyVaultName = "KV"
        Mock Get-KeyVaultSecrets -ParameterFilter{$vaultName -eq $KeyVaultName} {} -Verifiable
        
        Get-Settings -ConfigRootPath $PSScriptRoot/KeyVaultConfig 
        Assert-VerifiableMock
    }  
    It "KeyVaultConfigs are stored in the settings" {
        function GetSecret{
            param ([securestring] $SecureString)
            $credential = New-Object System.Management.Automation.PSCredential("bob", $SecureString)
            $Credential.GetNetworkCredential().Password
        }
        $secret = "bobby tastic"
        $secure1= ConvertTo-SecureString $secret -Force -AsPlainText
        $Setting1="SecureSetting1"
        Mock Get-KeyVaultSecrets  {[psCustomObject]@{Name=$Setting1;value=$secure1}} -Verifiable
        
        $settings =Get-Settings -ConfigRootPath $PSScriptRoot/KeyVaultConfig 
        Assert-VerifiableMock
        $settings.$Setting1 |Should -not -be $null
        GetSecret  $settings.$Setting1 | Should -Be $secret
    }
}
