param($ModulePath)

if (-not $ModulePath){ $ModulePath = "$PSScriptRoot\..\Pipeline.Config.module"}

get-module Pipeline.Config | Remove-Module -force
#Import-Module "$ModuleBase\ConfigHelper.psm1"

foreach ($function in (Get-ChildItem "$ModulePath\Functions\Get-KeyVaultSecret*.ps1"))
{
	. $function 
}
function GetSecret{
    param ([securestring] $SecureString)
    $credential = New-Object System.Management.Automation.PSCredential("bob", $SecureString)
    $Credential.GetNetworkCredential().Password
}
Describe 'Get-KeyVaultSecret' {
    
    It "KeyVaultSecret returns secure string" {
        $vault = "Vault"
        $SecretName = "secret" 
        $expectedvalue = "ExpectedValue" 
        Mock Get-AzKeyVaultSecret -Verifiable -ParameterFilter {$vaultName -eq $vault -and  $secretName -eq $secretName }  {
            return @{SecretValue=ConvertTo-SecureString $expectedvalue -asplainText -Force }
        }
        $secretValue =  Get-KeyVaultSecret -vaultname $vault -SecretName $SecretName 
        Assert-VerifiableMock 
        $secretValue | Should beoftype [securestring]
        GetSecret $secretValue | Should be $expectedvalue
    }
}
Describe 'Get-KeyVaultSecrets' {
    It "KeyVaultSecrets returns return secrets" {
        $vault = "Vault"
        $expectedvalue = "ExpectedValue" 
        $SecretName = "secret"
        $SecretName2 = "secret" 
        Mock Get-AzKeyVaultSecret  -Verifiable -ParameterFilter {$vaultName -eq $vault }  {return @{Name=$SecretName },@{Name=$secretName2}}
        Mock Get-KeyVaultSecret -Verifiable  {return ConvertTo-SecureString $expectedvalue -asplainText -Force }
        $secretValues =  Get-KeyVaultSecrets -vaultname $vault 
        Assert-MockCalled Get-KeyVaultSecret -times 2 
        $secretValues.Count | Should be 2
        $secretValues[0].Name | Should be $secretName
        GetSecret $secretValues[1].Value | Should be $expectedvalue
        
    }
}

Describe 'Get-KeyVaultSecrets' {
    It "KeyVaultSecrets returns return secrets" {
        $vault = "Vault"
        $expectedvalue = "ExpectedValue" 
        $SecretName = "secret"
        Mock Get-AzKeyVaultSecret  -Verifiable -ParameterFilter {$vaultName -eq $vault }  {return @{Name=$SecretName }}
        Mock Get-KeyVaultSecret -Verifiable  {return ConvertTo-SecureString $expectedvalue -asplainText -Force}
        $secretValues =  Get-KeyVaultSecrets -vaultname $vault 
        Assert-MockCalled Get-KeyVaultSecret -times 1
        $secretValues.Name | Should be $secretName
        GetSecret $secretValues.Value| Should be $expectedvalue
        
    }
}
