Function Get-ProjectSettings {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Not changed yet')]
    param(
        [string]$configRootPath,
        [string]$environment,
        [parameter(ValueFromRemainingArguments = $true)]
        $overrides
    )

    $settings = (Get-Settings -environment $environment -configRootPath $configRootPath @overrides)

    if ($settings.AddMyIP -eq $true) {
        Write-Host "Get MyIP for configuration in ARM deployment"
        $MyIp = Get-MyIp
        
        if ($myIp) {
            $NewIp = @{name = "myIp"; startIpAddress = $myIp.Content; endIpAddress = $myIp.Content }
            if ( -not $settings.IpAddresses) {
                $settings.IpAddresses = @($NewIp)
            }
            elseif ( -not  $settings.IpAddresses.startIpAddress.Contains($myIp.Content)) {
                $settings.IpAddresses += ($NewIp)
            }
        }
    }

    Write-Verbose "($envSettings | ConvertTo-Json)"
    
    return $settings
}