
Function Initialize-Settings{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Not changed yet')]
    [CmdletBinding()]
    param($ConfigRootPath
         
        )

        new-item "$ConfigRootPath\base" -Type Directory | Out-Null
        new-item "$ConfigRootPath\env" -Type Directory | Out-Null
        new-item "$ConfigRootPath\personal" -Type Directory | Out-Null

        $BaseConfig = join-path $ConfigRootPath (GetBaseConfigPath)
        Write-Verbose "Creating empty base config file $baseConfig"
        "{}"| Out-File $BaseConfig
}