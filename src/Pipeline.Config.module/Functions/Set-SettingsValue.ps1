Function Set-SettingsValue {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Don''t nee ShouldPorcess')]

    param(
        [PSCustomObject] $settings,
        [string] $name,
        [object] $value
    )
    $isJson = Test-JsonCustom $value
    Write-Debug "Setting: $name from parameters - isJson: $isJSon"
    
    if ($isJson) {
        $value = $value | ConvertFrom-Json
    }

    if ($settings | get-member $name) {
        # Write-Verbose "Overriding $($property.Name) -Value $($property.Value) type $($currentSettings.$Prop.GetType().Name)"
        if ($null -ne $settings.$name -and
            $settings.$name -is [PSObject]) {
            Write-Verbose "Property $($name) is Object so merging that with property of type $($value.GetType())"    
            Merge-Settings -CurrentSettings $settings.$name -newSettings $value
        }
        else {
            $settings.$name = $value
        }
    }
    else {
        Write-Verbose "Adding $name -Value $value "
        $settings | Add-Member -MemberType NoteProperty -Name  $name -Value $value -Force
    }

}