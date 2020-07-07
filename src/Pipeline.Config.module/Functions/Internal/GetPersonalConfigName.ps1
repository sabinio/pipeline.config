Function GetPersonalConfigPath {
    [CmdletBinding()]
    param(
        [string]$environment
    )
    
    join-path "personal" "$($env:UserName)-$environment"
}