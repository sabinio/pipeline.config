Function Get-Settings {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Not changed yet')]
    
    param(
        [parameter(Mandatory=$true)]
        [string]$configRootPath,
        [string]$environment,
        [parameter(ValueFromRemainingArguments = $true)]
        $overrides
    )
 
    $basePath = join-path $configRootPath (GetBaseConfigPath) 
    
    if (-not (Test-Path $basePath) ) {
        throw "Config file not Found: `'$basePath`'"
    } 

    $settings = [PSCustomObject]@{}
    Import-SettingsFromFile $settings $basePath 

    if ($environment){
        $envPath = join-path $configRootPath (GetEnvironmentConfigPath -environment $environment)
        if (Test-Path $envPath) {
            Write-Verbose "Loading config from $environment"    
            Import-SettingsFromFile $settings $envPath 
        } 
        else {
            throw "Environment $environment doesn't exist in $configRootPath"
        }
    }
    
    Import-SettingsFromPersonalFile -ConfigRootPath $configRootPath -Settings $settings -environment $environment
    
    #Loop through environment variables and set values
    $settings | Get-Member -MemberType NoteProperty | ForEach-Object { 
        if (test-path env:$($_.Name)) {
            Write-Verbose "Setting $($_.Name) to $((get-item env:$($_.Name)).value) from an override parameter passed in"
            Set-SettingsValue $settings -name $_.Name -value (Get-Item env:$($_.Name)).value  
        }
    }

    if ($settings.keyVaultConfigs) {
        $settings.keyVaultConfigs | Foreach-Object {
            $keyVault = $_

            (Get-KeyVaultSecrets -vaultName $keyVault) | ForEach-Object {    
                $property = $_

                $settings | Add-Member -MemberType NoteProperty -Name  $property.Name -Value $property.Value -Force
    
                Write-Verbose "Adding $($property.Name) -Value $($property.Value) from keyvault: $keyVault"
            }
        }
    }

    if (-not $null -eq $overrides) {
        Write-Host "Loading settings from overrides"

        #Overrides is an array of the remaining arguments passed through. 
        #if the following had been passed -param1 value -param2 value2
        #then you would have a 4 item array i.e. @("-param1","value","-param2","value2")

        for ($i = 0; $i -lt $overrides.Count; $i++) {
            $name = $overrides[$i].trim('-')
            if ($name[-1] -eq ":"){$name = $name.substring(0,$name.Length -1)}
                
            #Switch parameters are either the last param or the next item is another param and starts with a - 
            if ($i -eq $overrides.count - 1 -or $overrides[$i + 1] -like "-*") {
                $value = $true
            }
            else {
                $value = $overrides[$i + 1]
                $i++
            }
            Write-Verbose "Setting $name to $value from an override parameter passed in"
            Set-SettingsValue $settings -value $value -name $name 
        }
    }


    $settings = Invoke-SettingEvaluation -settings $settings
    $settings
}
