param($ModulePath)

if (-not $ModulePath) { $ModulePath = join-path $PSScriptRoot "../Pipeline.Config.module" }

    get-module Pipeline.Config | Remove-Module -force -Verbose:$false
    #Import-Module "$ModuleBase\ConfigHelper.psm1"

    foreach ($function in (Get-ChildItem "$ModulePath/Functions/Internal/*.ps1")) {
        . $function 
    }
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/*.ps1")) {
        . $function
    }

#InModuleScope ConfigHelper {
Describe 'Get-Settings' {
    BeforeAll {
        $env:settingFrom = ""
        $env:parent = ""
    }
    It "Given no config files, fails" {
        
        $missingConfigPath = "TestDrive:missing"
        $expectedfilename =join-path (join-path  $missingConfigPath "base") "config.json"
        { Get-Settings -ConfigRootPath $missingConfigPath } | Should  -Throw "Config file not Found: `'$expectedfilename`'"
    }

    It "Given no config files, fails" {
        { Get-Settings -ConfigRootPath ./ -RunSettings dev -RunEnvironment local } | Should  -Throw
    }

    It "Given base is not overwritten, base rules" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment other).settingFrom | Should be "base"
    }

    It "Given base is overwritten in environment, environment rules" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev).settingFrom | Should be "env-dev"
    }

    It "Given personal overrides environment, personal rules" {
        Mock GetPersonalConfigPath { "personal/person" }
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev ).settingFrom | Should be "personal-person"
    }
}
Describe "Override parameters" {
    It "Given override parameters, parameters rules" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev  -settingFrom bertie ).settingFrom | Should be "bertie"
    }
}
Describe "Override parameters by splatting works" {
    It "Given override parameters by splatting" {
        $Override= @{settingFrom="randomValue"}
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev  @Override ).settingFrom | Should be $Override.settingFrom
    }
}

Describe "Switch Parameters" {
    It "Given a switch parameter the value should be true" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev  -TurnThisOn).TurnThisOn | Should be $true
    }
}
Describe "MyIP Tests" {
    It "GetMyIp should not error" {      
        { Get-MyIp } | Should not Throw
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
    It "GetMyIp should not error" {      
        { Get-MyIp } | Should not Throw
    }   
        
}
Describe "Get-MyIp" {
    It "Not connected to internet and request for ip times out an empty string should be returned" {  
        Mock Invoke-WebRequest {
            throw [TimeoutException]
        }
        Get-MyIp | Should be ""
    }
}
Describe "Hierarchy Tests" {
    It "Given a hierarchy, children are overwritten" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy).parent[0].childValue | Should be "hierarchy"
    }

    It "Given a hierarchy, only overridden values change" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy).ParentWithChildSettings.Setting2 | Should be "newvalueforSetting2"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy).ParentWithChildSettings.Setting1 | Should be "original value for setting 1"
    }
    It "Given a hierarchy, only new values in an override ensure the values are added" {
    
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy).ParentWithChildSettings.NewSetting | Should be "Value for New Setting"
    }

        
    It "Given a hierarchy from parameters, children are overwritten" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy -parent "[{'childValue': 'wowsers'}]").parent[0].childValue | Should be "wowsers"
    }

        
    It "Given a deep hierarchy from parameters, children are overwritten" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy -parent "[{'childValue': {an: { other:{ v:'wowsers'}}}}]").parent[0].childValue.an.other.v | Should be "wowsers"
    }

    It "Given an environment variable value is overridden" {
        $env:settingFrom = "from env variable"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev).settingFrom | Should be "from env variable"
    }

    It "Given an environment variable and an override is specified the override value is used" {
        $env:settingFrom = "from env variable"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment dev -settingFrom bertie).settingFrom | Should be "bertie"
    }

    It "Given a hierarchy from environment, children are overwritten" {
        $env:parent = "[{'childValue': 'wowsers'}]"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy ).parent[0].childValue | Should be "wowsers"
    }

        
    It "Given a deep hierarchy from parameters, children are overwritten" {
        $env:parent = "[{'childValue': {an: { other:{ v:'wowsers'}}}}]"
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment hierarchy ).parent[0].childValue.an.other.v | Should be "wowsers"
    }
    It "Given an array of strings ensure values are evaluated" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment other ).ArrayOfValues | Should be "aValue", "anotherValue"
    }
        
    It "Given an simple expression ensure it is evaulated" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/test-config -environment other).ExpressionValue | Should be 2
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
        (Get-Settings -ConfigRootPath $ConfigPath -environment $MyEnv  ).SettingBasedonComplexSetting | Should be "ThePrefixIWant-SomeValue"
    }

    It "Given a setting file without a setting calling should store the correct value" {

        $configRoot = "TestDrive:\AddSetting"
        Test-Path $configRoot | should be $false
        Initialize-Settings -ConfigRootPath $configRoot
        $MySettingName = "TestSettingName"
        $MySettingValue = "TestSettingValue"
        Set-Setting -ConfigRootPath $configRoot  -Name $MySettingName -Value $MySettingValue
        $settings = Get-Settings -ConfigRootPath $configRoot
        $settings.$MySettingName | Should be $MySettingValue
        remove-item $configRoot -Recurse -force 
    }
    It "Given a set of settings with no environment, calling get-settings with no environment should not fail " {

        $configRoot = "TestDrive:\NoEnvironment"
        Test-Path $configRoot | should be $false
        Initialize-Settings -ConfigRootPath $configRoot
        Get-Settings -ConfigRootPath $configRoot
        remove-item $configRoot -Recurse -force 
    }
   
    It "Given a setting ensure value returned is when Get-SettingCalled" {
        $SimpleSetting = (Get-Setting -settingName "SimpleSetting" -ConfigRootPath $PSScriptRoot/test-config)
        $SimpleSetting | Should be "SimpleSettingValue"
    }
    It "Calling Get-Setting throws error if setting not set" {
        { Get-Setting -settingName "SomeNonsensesetting" -ConfigRootPath $PSScriptRoot/test-config } | should Throw "setting SomeNonsensesetting is not set"
    }
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

    It "Given a null setting ensure value returned is null" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/nulls -environment nullValues).nullValue | Should be $null     
    }
    It "Given a null setting that is overriden ensure override is returned" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/nulls -environment nullValues).nullvalueToOverride | Should be "override null value with value"
      
    }
    It "Given a non null setting that is overriden to null ensure null is returned" {
        (Get-Settings -ConfigRootPath $PSScriptRoot/nulls -environment nullValues).nonNullValue | Should be $null   
    }
}
  

Describe "Value formatting tests" {
    it "Given a string with a number one should get a string back" {
        Expand-String "1234" | Should be "1234"
    }
    it "Given a string with a string one should get a string back" {
        Expand-String "simon" | Should be "simon"
    }
    it "Given a string referencing a local variable the value should be expanded" {
        $localValue = "avalue"
        Expand-String "`$localValue" | Should be "avalue"
    }
    it "Given a string referencing a local variable with properties the value should be expanded" {
        $localValue = @{myproperty = "avalue" }
        Expand-String "{`$localValue.myproperty}" | Should be "avalue"
    }
    it "Given a string referencing a multiple local variables with properties the expand should throw" {
        $localValue = @{myproperty = "avalue" }
        { Expand-String "{`$localValue.myproperty `$localValue.myproperty}" } | Should throw
    }
    it "Given a string referencing a multiple local variables with properties the expand should throw" {
        $localValue = @{myproperty = "avalue" }
        Expand-String "`$(`$localValue.myproperty) `$(`$localValue.myproperty)" | Should be "avalue avalue"
    }
    it "Given a simple string in a script it should error" {
        { Expand-String "{avalue}" } | Should throw 
    }
    it "Given a string sentence with spaces the value not error" {
        Expand-String 'a sentence with spaces in a script' | Should be "a sentence with spaces in a script"
    }
    it "Given a script with a string sentence with spaces it should error" {
        { Expand-String '{a sentence with spaces in a script}' } | Should throw
    }
    it "Given a script with a string sentence with spaces the value not error" {
        function get-value { return "a new value" }
        Expand-String '{(get-date).Date}'  | Should be (get-date).Date
    }
    it "Given a script with a reference to a local function it should return the correct value" {
        function get-value { return "a new value" }
        Expand-String '{get-value}'  | Should be "a new value"
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
Describe "Banners work" {
    ("", "Build", "BuildSSIS", "Deploy", "DeployData", "DeploySSIS", "DeployInfra", "Install", "Package", "PackageSSIS", "Test", "TestModules", "TestSSIS", "Tidy") | ForEach-Object {
        it "Write-Banner$_ doesn't error" {
            { &"Write-Banner$_" } | Should not throw
        }
    }
}

Describe 'Get-SettingsFromKeyVault' {

    Context "KeyVaultConfigs are loaded from the KV in config" {
        $KeyVaultName = "KV"
        Mock Get-KeyVaultSecrets -ParameterFilter{$vaultName -eq $KeyVaultName} {} -Verifiable
        
        Get-Settings -ConfigRootPath $PSScriptRoot/KeyVaultConfig 
        Assert-VerifiableMock
    }  
    function GetSecret{
        param ([securestring] $SecureString)
        $credential = New-Object System.Management.Automation.PSCredential("bob", $SecureString)
        $Credential.GetNetworkCredential().Password
    }
    Context "KeyVaultConfigs are stored in the settings" {
        $secret = "bobby tastic"
        $secure1= ConvertTo-SecureString $secret -Force -AsPlainText
        $Setting1="SecureSetting1"
        Mock Get-KeyVaultSecrets  {[psCustomObject]@{Name=$Setting1;value=$secure1}} -Verifiable
        
        $settings =Get-Settings -ConfigRootPath $PSScriptRoot/KeyVaultConfig 
        Assert-VerifiableMock
        $settings.$Setting1 |Should -not -be $null
        GetSecret  $settings.$Setting1 | Should be $secret
    }
}
