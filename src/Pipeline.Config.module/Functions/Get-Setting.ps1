Function Get-Setting{
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

    $settings = Get-Settings -configRootPath $configRootPath -environment $environment -overrides $overrides  

    Write-Verbose "Checking Setting value ($($settings.$settingName)_"

    if (-not $settings.$settingName)
    {
        Write-Verbose "Setting doesn't exist ($SettingName)"
        throw "setting $settingName is not set"
    }
    $settings.$settingName
}
