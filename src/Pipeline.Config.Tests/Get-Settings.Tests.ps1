param($ModulePath)

    BeforeAll {
    if (-not $ModulePath) { $ModulePath = join-path $PSScriptRoot "../Pipeline.Config.module" }
    get-module Pipeline.Config | Remove-Module -force -Verbose:$false
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/Internal/*.ps1")) {
        . $function 
    }
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/*.ps1")) {
        . $function
    }
}

#InModuleScope ConfigHelper {
Describe 'Get-Settings' {
    	BeforeAll {
    $env:settingFrom = ""
    $env:parent = ""

}
	
    It "Given no config files, fails" {
        
        $missingConfigPath = "TestDrive:missing"
        $expectedfilename = join-path (join-path  $missingConfigPath "base") "config.json"
        { Get-Settings -ConfigRootPath $missingConfigPath } | Should  -Throw "Config file not Found: `'$expectedfilename`'"
    }

    It "Given no config files, fails" {
        { Get-Settings -ConfigRootPath ./ -RunSettings dev -RunEnvironment local } | Should  -Throw
    }

    It "Given base is not overwritten, base rules" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment other).settingFrom | Should -Be "base"
    }

    It "Given base is overwritten in environment, environment rules" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev).settingFrom | Should -Be "env-dev"
    }

    It "Given personal overrides environment, personal rules" {
        Mock GetPersonalConfigPath { "personal/person" }
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev ).settingFrom | Should -Be "personal-person"
    }
}
Describe "Override parameters" {
    It "Given override parameters, parameters rules" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev  -settingFrom bertie ).settingFrom | Should -Be "bertie"
    }
}
Describe "Override parameters by splatting works" {
    It "Given override parameters by splatting" {
        $Override = @{settingFrom = "randomValue" }
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev  @Override ).settingFrom | Should -Be $Override.settingFrom
    }
}

Describe "Switch Parameters" {
    It "Given a switch parameter the value Should -Be true" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev  -TurnThisOn).TurnThisOn | Should -Be $true
    }
}
Describe "MyIP Tests" {
    It "GetMyIp Should -Not error" {      
        { Get-MyIp } | Should -Not -Throw
    }   
    It "Given AddMyIp is false, ip address is not included" {  
        Mock Get-MyIp {
            "{'content': '1480.1480.1480.1480'}" | ConvertFrom-Json
        }
        ((Get-ProjectSettings -ConfigRootPath $PSScriptRoot/test-config -environment azure -addMyIp $false).IpAddresses | ConvertTo-Json) | Should -Not -BeLike "*1480.1480.1480.1480*"
    }

    It "Given AddMyIp is true, include ip address" {      
        Mock Get-MyIp {
            "{'content': '1480.1480.1480.1480'}" | ConvertFrom-Json
        }
        ((Get-ProjectSettings -ConfigRootPath $PSScriptRoot/test-config -environment azure -addMyIp $true).IpAddresses | ConvertTo-Json) | Should -BeLike "*1480.1480.1480.1480*"
    }
    It "GetMyIp Should -Not error" {      
        { Get-MyIp } | Should -Not -Throw
    }   
        
}
Describe "Get-MyIp" {
    It "Not connected to internet and request for ip times out an empty string Should -Be returned" {  
        Mock Invoke-WebRequest {
            throw [TimeoutException]
        }
        Get-MyIp | Should -Be ""
    }
}
Describe "Hierarchy Tests" {

    It "Given a hierarchy, children are overwritten" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy).parent[0].childValue | Should -Be "hierarchy"
    }

    It "Given a hierarchy, only overridden values change" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy).ParentWithChildSettings.Setting2 | Should -Be "newvalueforSetting2"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy).ParentWithChildSettings.Setting1 | Should -Be "original value for setting 1"
    }
    It "Given a hierarchy, only new values in an override ensure the values are added" {
    
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy).ParentWithChildSettings.NewSetting | Should -Be "Value for New Setting"
    }

        
    It "Given a hierarchy from parameters, children are overwritten" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy -parent "[{'childValue': 'wowsers'}]").parent[0].childValue | Should -Be "wowsers"
    }

        
    It "Given a deep hierarchy from parameters, children are overwritten" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy -parent "[{'childValue': {an: { other:{ v:'wowsers'}}}}]").parent[0].childValue.an.other.v | Should -Be "wowsers"
    }

    It "Given an environment variable value is overridden" {
        $env:settingFrom = "from env variable"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev).settingFrom | Should -Be "from env variable"
    }

    It "Given an environment variable and an override is specified the override value is used" {
        $env:settingFrom = "from env variable"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev -settingFrom bertie).settingFrom | Should -Be "bertie"
    }

    It "Given a hierarchy from environment, children are overwritten" {
        $env:parent = "[{'childValue': 'wowsers'}]"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy ).parent[0].childValue | Should -Be "wowsers"
    }

        
    It "Given a deep hierarchy from parameters, children are overwritten" {
        $env:parent = "[{'childValue': {an: { other:{ v:'wowsers'}}}}]"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy ).parent[0].childValue.an.other.v | Should -Be "wowsers"
    }
    It "Given an array of strings ensure values are evaluated" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment other ).ArrayOfValues | Should -Be "aValue", "anotherValue"
    }
        
    It "Given an simple expression ensure it is evaulated" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment other).ExpressionValue | Should -Be 2
    }
        
    It "Given an environment that doesn't exist raise an error" {
        $nonexistentEnvironment = "nonexistentenvironment"
        $ConfigPath = Resolve-Path "$PSScriptRoot/test-config"
        { Get-Settings -ConfigRootPath $ConfigPath -environment $nonexistentEnvironment } | Should -Throw "Environment $nonexistentEnvironment doesn't exist in $ConfigPath"
    }

    It "Given a setting with an expression ensure the verbose output returns correctly" {
        $myEnv = "SettingdependentonPersonal"
        $ConfigPath = Resolve-Path "$PSScriptRoot/test-config"
        Mock GetPersonalConfigPath { "personal/$myEnv-Person" }
        (Get-Settings -ConfigRootPath $ConfigPath -environment $MyEnv  ).SettingBasedonComplexSetting | Should -Be "ThePrefixIWant-SomeValue"
    }

    It "Given a setting file without a setting calling should store the correct value" {

        $configRoot = "TestDrive:\AddSetting"
        Test-Path $configRoot | Should -Be $false
        Initialize-Settings -ConfigRootPath $configRoot
        $MySettingName = "TestSettingName"
        $MySettingValue = "TestSettingValue"
        Set-Setting -ConfigRootPath $configRoot  -Name $MySettingName -Value $MySettingValue
        $settings = Get-Settings -ConfigRootPath $configRoot
        $settings.$MySettingName | Should -Be $MySettingValue
        remove-item $configRoot -Recurse -force 
    }
    It "Given a set of settings with no environment, calling get-settings with no environment Should -Not fail " {

        $configRoot = "TestDrive:\NoEnvironment"
        Test-Path $configRoot | Should -Be $false
        Initialize-Settings -ConfigRootPath $configRoot
        Get-Settings -ConfigRootPath $configRoot
        remove-item $configRoot -Recurse -force 
    }
   
    It "Given a setting ensure value returned is when Get-SettingCalled" {
        $SimpleSetting = (Get-Setting -settingName "SimpleSetting" -ConfigRootPath $PSScriptRoot/test-config)
        $SimpleSetting | Should -Be "SimpleSettingValue"
    }
    It "Calling Get-Setting throws error if setting not set" {
        { Get-Setting -settingName "SomeNonsensesetting" -ConfigRootPath $PSScriptRoot/test-config } | Should -Throw "setting SomeNonsensesetting is not set"
    }
    It "Given a setting that isn't a secure string Get-SecureSetting fails" {
        { Get-SecureSetting  -settingName "SimpleSetting" -ConfigRootPath $PSScriptRoot/test-config } | Should -Throw "this can only be used on secure strings"
    }
    It "Given a setting file without a securesetting, calling Set-SecureString should store the correct value" {
        $configRoot = "TestDrive:\AddSecureSetting"
        Initialize-Settings -ConfigRootPath $configRoot
        $MySettingName = "SecureTestSettingName"
        $MySettingValue = "SecureTestSettingValue"
        Set-SecureSetting -ConfigRootPath $configRoot  -Name $MySettingName -Value $MySettingValue 
        $StoredSetting = Get-Setting -ConfigRootPath $configRoot -settingName $MySettingName 
        Write-Verbose $StoredSetting 
        $StoredSetting.GetType().Name | Should -Be "SecureString"

        Get-SecureSetting -ConfigRootPath $configRoot -settingName $MySettingName | Should -Be $MySettingValue
        remove-item $configRoot -Recurse -force 
    }

    It "Given a null setting ensure value returned is null" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/nulls -environment nullValues).nullValue | Should -Be $null     
    }
    It "Given a null setting that is overriden ensure override is returned" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/nulls -environment nullValues).nullvalueToOverride | Should -Be "override null value with value"
      
    }
    It "Given a non null setting that is overriden to null ensure null is returned" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/nulls -environment nullValues).nonNullValue | Should -Be $null   
    }
}
  

Describe "Value formatting tests" {
    it "Given a string with a number one should get a string back" {
        Expand-String "1234" | Should -Be "1234"
    }
    it "Given a string with a string one should get a string back" {
        Expand-String "simon" | Should -Be "simon"
    }
    it "Given a string referencing a local variable the value Should -Be expanded" {
        $localValue = "avalue"
        Expand-String "`$localValue" | Should -Be "avalue" 
    }
    it "Given a string referencing a local variable with properties the value Should -Be expanded" {
        $localValue = @{myproperty = "avalue" }
        Expand-String "{`$localValue.myproperty}" | Should -Be "avalue"
    }
    it "Given a string referencing a multiple local variables with properties the expand Should -Throw" {
        $localValue = @{myproperty = "avalue" }
        { Expand-String "{`$localValue.myproperty `$localValue.myproperty}" } | Should -Throw
    }
    it "Given a string referencing a multiple local variables with properties the expand Should -Throw" {
        $localValue = @{myproperty = "avalue" }
        Expand-String "`$(`$localValue.myproperty) `$(`$localValue.myproperty)" | Should -Be "avalue avalue"
    }
    it "Given a simple string in a script it should error" {
        { Expand-String "{avalue}" } | Should -Throw 
    }
    it "Given a string sentence with spaces the value not error" {
        Expand-String 'a sentence with spaces in a script' | Should -Be "a sentence with spaces in a script"
    }
    it "Given a script with a string sentence with spaces it should error" {
        { Expand-String '{a sentence with spaces in a script}' } | Should -Throw
    }
    it "Given a script with a string sentence with spaces the value not error" {
        function get-value { return "a new value" }
        Expand-String '{(get-date).Date}'  | Should -Be (get-date).Date
    }
    it "Given a script with a reference to a local function it should return the correct value" {
        function get-value { return "a new value" }
        Expand-String '{get-value}'  | Should -Be "a new value"
    }
}
Describe "Overrides should work" {
    IT "Given a value over" {
            
        $SecureStringValue = (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev).SecureValue 
        $SecureStringValue -is [SecureString] | Should -Be $true

        $Credentials = New-Object System.Management.Automation.PSCredential("sas", $SecureStringValue )
        $SecureStringValueClear = "$($Credentials.GetNetworkCredential().Password)"
        $SecureStringValueClear | Should -Be "non set"
    }
    IT "Given a value over" {
        $ValueToSet = "Some Value"
        $SecureStringValue = (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev -SecureValue (ConvertTo-SecureString $ValueToSet -asplainText -Force) ).SecureValue
    
        $SecureStringValue -is [SecureString] | Should -Be $true

        $Credentials = New-Object System.Management.Automation.PSCredential("sas", $SecureStringValue )
        $SecureStringValueClear = "$($Credentials.GetNetworkCredential().Password)"
        $SecureStringValueClear | Should -Be $ValueToSet
    }
}
<#
Describe "Banners work" {
    ("", "Build", "BuildSSIS", "Deploy", "DeployData", "DeploySSIS", "DeployInfra", "Install", "Package", "PackageSSIS", "Test", "TestModules", "TestSSIS", "Tidy") | ForEach-Object {
        it "Write-Banner$_ doesn't error" {
            { &"Write-Banner$_" } | Should -Not throw
        }
    }
}
#>
Describe 'Get-SettingsFromKeyVault' {

    It "KeyVaultConfigs are loaded from the KV in config" {
        $KeyVaultName = "KV"
        Mock Get-KeyVaultSecrets -ParameterFilter { $vaultName -eq $KeyVaultName } {} -Verifiable
        
        Get-Settings -ConfigRootPath $PSScriptRoot/KeyVaultConfig 
        Assert-VerifiableMock
    }  
    BeforeAll {
        function GetSecret {
            param ([securestring] $SecureString)
            $credential = New-Object System.Management.Automation.PSCredential("bob", $SecureString)
            $Credential.GetNetworkCredential().Password
        }
    }
    It "KeyVaultConfigs are stored in the settings" {
        $secret = "bobby tastic"
        $secure1 = ConvertTo-SecureString $secret -Force -AsPlainText
        $Setting1 = "SecureSetting1"
        Mock Get-KeyVaultSecrets { [psCustomObject]@{Name = $Setting1; value = $secure1 } } -Verifiable
        
        $settings = Get-Settings -ConfigRootPath $PSScriptRoot/KeyVaultConfig 
        Assert-VerifiableMock
        $settings.$Setting1 | Should -not -be $null
        GetSecret  $settings.$Setting1 | Should -Be $secret
    }
}
