Function Set-SettingsValue {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Don''t nee ShouldPorcess')]

    param(
        [PSCustomObject] $settings,
        [string] $name,
        [string] $value
    )

    $isJson = Test-JsonCustom $value
    Write-Debug "Setting: $name from parameters - isJson: $isJSon"
    
    if ($isJson) {
        $settings | Add-Member -MemberType NoteProperty -Name  $name -Value ($value | ConvertFrom-Json) -Force            
    }
    else {
        $settings | Add-Member -MemberType NoteProperty -Name  $name -Value $value -Force
    }            
}