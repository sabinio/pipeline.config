
Function Set-Setting{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Don''t nee ShouldPorcess')]

    param(
        [string]$ConfigRootPath,
        [string]$Name,
        [string]$environment,
        [switch]$Personal,
        [string]$Value
        )

        $configFile = "$ConfigRootPath\base\config.json"

        $settings = Get-Content $configFile | Convertfrom-json 
        Write-Host "environment is currently ignored $environment"
        Write-Host "Personal is currently not used $Personal"
        
        $settings| Add-Member -MemberType NoteProperty -Name  $Name -Value $Value -Force
        Write-Verbose "Setting $Name to value $Value"
        $settings.$Name = $Value
        Convertto-json $settings | Out-File $configFile
}