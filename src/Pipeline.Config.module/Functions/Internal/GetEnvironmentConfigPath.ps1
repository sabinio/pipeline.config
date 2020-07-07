Function GetEnvironmentConfigPath {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$environment
        
    )
    
    Join-path "env" "$environment.json"
}