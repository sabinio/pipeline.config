<#
.SYNOPSIS
    Walks the settings to evaluate them and return an updated settings structure
.DESCRIPTION
    Loops around all the properties in the settings (either hash keys or psobjects) and 
    evaluates the values using Expand-String for strings or calling this function again for lists
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    settings = the global settings used to allow expressions to refer to the settings i.e. databaseName = "{$Settings.environment & "-" & $settings.Project"
    thisSettings = the object to be evaluating the keys of.
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
Function Invoke-SettingEvaluation {
    [CmdletBinding()]
    param($settings
    , $thisSettings)
   
    if ($null -eq $thisSettings ){
        Write-Verbose "Evaluating Settings in order that we found them..."
        $thisSettings=$settings
    }
   
    if ($thisSettings -is [psobject] -or $thisSettings -is [hashtable]) {
        $props = $thisSettings.PSObject.properties
        if ($null -ne $props) {
    
            $thisSettings.PSObject.properties | ForEach-Object {
                $settingName = "$($_.Name)"
                $value = $thisSettings.$settingName
                Write-Verbose "Processing key $settingName with value $value" 
            
                if ($null -eq $value) {
                    $thisSettings.$settingName = $null    
                    Write-Verbose "Setting $settingName to `$null"
                }
                elseif ($value -is [String] ) {   
                    $thisSettings.$settingName = Expand-String $value       
                    Write-Verbose "Setting $settingName to $($thisSettings.$settingName)"
                }
                elseif ($null -ne $value -and $value -is [object[]]) {
            
                    $index = 0
                    Write-Verbose "  Processing Array"
                    foreach ($item in $value) {
            
                        $thisSettings."$settingName"[$index] = Invoke-SettingEvaluation -thisSettings $value[$index] -settings $settings
                        $index++
                    }
                }
                elseif($value -isnot [securestring] ) {
                    foreach ($item in $value.psobject.Properties){
                        $name = $item.Name
                        $thisSettings.$settingName.$name = Invoke-SettingEvaluation -thisSettings $value.$name -settings $settings
                    }
                   
                }
                else{
                    Write-Verbose "   Setting $($thisSettings.GetType().Name) $($value.GetType().Name) $settingName to $value"
                    #      $value | Invoke-Expression
                }
            }     
        }
    }
    else {
        $thisSettings = Expand-String $thisSettings
    }
    Write-Verbose "Settings Done:"
    Write-Verbose "$($thisSettings | ConvertTo-Json -depth 5)"

    $thisSettings
}