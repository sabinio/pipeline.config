Function GetBaseConfigPath {
    [CmdletBinding()]
    param(
    )
    
    join-path "base" "config.json"
}