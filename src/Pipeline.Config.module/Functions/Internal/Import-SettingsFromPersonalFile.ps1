Function Import-SettingsFromPersonalFile {
    [CmdletBinding()]
    param(
        [string]$configRootPath,
        $settings,
        [string]$environment
    )
    $personalFile = (GetPersonalConfigPath  -environment $environment)

    $personalPath =join-path $configRootPath "$personalFile.json"
    $ignorePath  =join-path $configRootPath "$personalFile.ignore.json"

    if (Test-Path $ignorePath) {
        Write-Verbose "Loading config from $ignorePath"  
        Import-SettingsFromFile $settings "$ignorePath"
    }
    elseif (Test-Path $personalPath) {
        Write-Verbose "Loading config from $personalPath"  
        Import-SettingsFromFile $settings $personalPath 
    }
    else {
        Write-Verbose "We have no personal config file: '$($personalPath)'"
    }
}