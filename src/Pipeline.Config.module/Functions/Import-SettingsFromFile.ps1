
Function Import-SettingsFromFile {
    [CmdletBinding()]
    param($Settings
        , $file)

    function Merge-Settings($currentSettings, $newSettings) {
        
        Write-Verbose "$($currentSettings | ConvertTo-Json)"

        $NewSettings.PSObject.properties | ForEach-Object {    
            $property = $_
            $Prop = $Property.Name
            Write-Verbose "processing $prop" 
            if ($currentSettings | get-member $prop) {
                # Write-Verbose "Overriding $($property.Name) -Value $($property.Value) type $($currentSettings.$Prop.GetType().Name)"
                if ($null -ne $currentSettings.$Prop -and
                    $currentSettings.$Prop -is [PSObject]) {
                    Write-Verbose "Property $($property.Name) is Object so merging that with property of type $($Property.TypeNameOfValue)"    
                    Merge-Settings -CurrentSettings $settings.$Prop -newSettings $property.Value
                }
                else {
                    $currentSettings.$Prop = $property.Value
                }
            }
            else {
                Write-Verbose "Adding $Prop -Value $($property.Value) "
                $currentSettings | Add-Member -MemberType NoteProperty -Name  $property.Name -Value $property.Value -Force
            }
        }
    
    }
    
    $inputSettings = (Get-Content $file -raw | ConvertFrom-Json)
    Write-Verbose "------ Procesing File $file"
    Write-Verbose  (convertto-json $inputSettings) 
    Merge-Settings -currentSettings $settings -newSettings $inputSettings
    
}