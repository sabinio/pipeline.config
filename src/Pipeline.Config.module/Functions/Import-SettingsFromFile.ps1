
Function Import-SettingsFromFile {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Not changed yet')]
    param($Settings
        , $file)

    $inputSettings = (Get-Content $file -raw | ConvertFrom-Json)
    Write-Verbose "------ Procesing File $file"
    Write-Verbose  (convertto-json $inputSettings) 
    Merge-Settings -currentSettings $settings -newSettings $inputSettings
    
}