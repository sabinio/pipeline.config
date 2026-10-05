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

    # Every value is dispatched on its own type, so arrays, objects and scalars are handled
    # identically at any nesting depth.
    Function Resolve-Value($value) {
        if ($null -eq $value) {
            return $null
        }
        elseif ($value -is [string]) {
            return Expand-String $value
        }
        elseif ($value -is [System.Collections.IDictionary]) {
            foreach ($key in @($value.Keys)) {
                $value[$key] = Resolve-Value $value[$key]
            }
            return $value
        }
        elseif ($value -is [System.Array]) {
            for ($index = 0; $index -lt $value.Count; $index++) {
                $value[$index] = Resolve-Value $value[$index]
            }
            return , $value
        }
        elseif ($value -is [System.Management.Automation.PSCustomObject]) {
            foreach ($property in @($value.PSObject.Properties)) {
                $property.Value = Resolve-Value $property.Value
            }
            return $value
        }
        else {
            # booleans, numbers, securestrings etc. are left exactly as they are
            return $value
        }
    }

    $thisSettings = Resolve-Value $thisSettings
    Write-Verbose "Settings Done:"
    Write-Verbose "$($thisSettings | ConvertTo-Json -depth 10)"

    $thisSettings
}
