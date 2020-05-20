Function Get-SecureSetting{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$configRootPath,
        [string]$environment,
        [parameter(Mandatory=$true)]
        [string]$settingName,
        [parameter(ValueFromRemainingArguments = $true)]
        $overrides
    )

    $settings = Get-Setting -SettingName $settingName -configRootPath $configRootPath -environment $environment -overrides $overrides  

    Write-Verbose $settings.GetType()
    if ($settings -isnot [SecureString]){
        throw "this can only be used on secure strings"
    }
    $TestCred= New-Object System.Management.Automation.PSCredential("User", $settings )
    $TestCred.GetNetworkCredential().Password    

}
