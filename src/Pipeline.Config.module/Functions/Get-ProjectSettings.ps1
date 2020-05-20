Function Get-ProjectSettings {
    [CmdletBinding()]
    param(
        [string]$configRootPath,
        [string]$environment,
        [parameter(ValueFromRemainingArguments = $true)]
        $overrides
    )
    Write-Host "Get-Settings"
    $settings = (Get-Settings -environment $environment -configRootPath $configRootPath @overrides)

    if ($settings.AddMyIP -eq $true) {
        Write-Host "Get MyIP for configuration in ARM deployment"
        $MyIp = Get-MyIp
        write-Host ($settings.IpAddresses.startIpAddress).GetType()
        Write-Host 
        if ($myIp -and -not  $settings.IpAddresses.startIpAddress.Contains($myIp.Content)) {
            $settings.IpAddresses += (@{name = "myIp"; startIpAddress = $myIp.Content; endIpAddress = $myIp.Content} | ConvertTo-Json | ConvertFrom-Json)
        }
    }

    Write-Verbose "($envSettings | ConvertTo-Json)"
    
    return $settings
}