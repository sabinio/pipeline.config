Function Invoke-SettingEvaluation {
    [CmdletBinding()]
    param($settings, $thisSettings)
   
    if ($null -eq $thisSettings ){
        Write-Verbose "Evaluating Settings in order that we found them..."
        $thisSettings=$settings
    }
   
    if ($thisSettings -is [psobject] -or $thisSettings -is [hashtable]) {
        $props = $thisSettings.PSObject.properties
        if ($null -ne $props) {
    
            $thisSettings.PSObject.properties | ForEach-Object {
                $settingName = "$($_.Name)"
                $value = $thisSettings."$($_.Name)"
            
                if ($null -eq $value) {
                    $thisSettings."$($_.Name)" = $null    
                    Write-Verbose "Setting $($_.Name) to `$null"
                }
                elseif ($value -is [String] ) {    
                    $thisSettings."$($_.Name)" = Expand-String $value       
                    Write-Verbose "Setting $($_.Name) to $($thisSettings."$($_.Name)")"
                }
                elseif ($null -ne $value -and $value -is [object[]]) {
            
                    $index = 0
                    Write-Verbose "  Processing Array"
                    foreach ($item in $value) {
            
                        $thisSettings."$settingName"[$index] = Invoke-SettingEvaluation -thisSettings $value[$index] -settings $settings
                        $index++
                    }
                }
                else {
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
    Write-Verbose "$($thisSettings | ConvertTo-Json)"

    $thisSettings
}