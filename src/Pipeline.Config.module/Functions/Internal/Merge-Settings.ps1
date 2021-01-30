function Merge-Settings{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Not changed yet')]
    [CmdletBinding()]
    param($currentSettings, $newSettings)

        Write-Verbose "$($currentSettings | ConvertTo-Json)"
$foo = $bob
        $NewSettings.PSObject.properties | ForEach-Object {    
            $property = $_
            $Prop = $Property.Name
            Write-Verbose "processing $prop" 
            if ($currentSettings | get-member $prop) {
                # Write-Verbose "Overriding $($property.Name) -Value $($property.Value) type $($currentSettings.$Prop.GetType().Name)"
                if ($null -ne $currentSettings.$Prop -and
                    $currentSettings.$Prop -is [PSObject]) {
                    Write-Verbose "Property $($property.Name) is Object so merging that with property of type $($Property.TypeNameOfValue)"    
                    Merge-Settings -CurrentSettings $Settings.$Prop -newSettings $property.Value
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
    