﻿param($ModulePath)

    if (-not $ModulePath) { $ModulePath = join-path $PSScriptRoot "../Pipeline.Config.module" }

    get-module Pipeline.Config | Remove-Module -force
    #Import-Module "$ModuleBase\ConfigHelper.psm1"

    foreach ($function in (Get-ChildItem "$ModulePath/Functions/Internal/*.ps1")) {
        . $function 
    }
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/*.ps1")) {
        . $function
    }

Describe "Secure tests" {
    It "Given a setting that isn't a secure string Get-SecureSetting fails" {
        { Get-SecureSetting  -settingName "SimpleSetting" -ConfigRootPath $PSScriptRoot/test-config } | Should throw "this can only be used on secure strings"
    }
    It "Given a setting file without a securesetting, calling Set-SecureString should store the correct value" {
        $configRoot = "TestDrive:\AddSecureSetting"
        Initialize-Settings -ConfigRootPath $configRoot
        $MySettingName = "SecureTestSettingName"
        $MySettingValue = "SecureTestSettingValue"
        Set-SecureSetting -ConfigRootPath $configRoot  -Name $MySettingName -Value $MySettingValue 
        $StoredSetting = Get-Setting -ConfigRootPath $configRoot -settingName $MySettingName 
        Write-Verbose $StoredSetting 
        $StoredSetting.GetType().Name | Should be "SecureString"

        Get-SecureSetting -ConfigRootPath $configRoot -settingName $MySettingName | Should be $MySettingValue
        remove-item $configRoot -Recurse -force 
    }
}
Describe "Overrides should work" {
    IT "Given a value over" {
            
        $SecureStringValue = (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev).SecureValue 
        $SecureStringValue -is [SecureString] | Should  be $true

        $Credentials = New-Object System.Management.Automation.PSCredential("sas", $SecureStringValue )
        $SecureStringValueClear = "$($Credentials.GetNetworkCredential().Password)"
        $SecureStringValueClear | Should  be "non set"
    }
    IT "Given a value over" {
        $ValueToSet = "Some Value"
        $SecureStringValue = (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev -SecureValue (ConvertTo-SecureString $ValueToSet -asplainText -Force) ).SecureValue
    
        $SecureStringValue -is [SecureString] | Should  be $true

        $Credentials = New-Object System.Management.Automation.PSCredential("sas", $SecureStringValue )
        $SecureStringValueClear = "$($Credentials.GetNetworkCredential().Password)"
        $SecureStringValueClear | Should  be $ValueToSet
    }
}