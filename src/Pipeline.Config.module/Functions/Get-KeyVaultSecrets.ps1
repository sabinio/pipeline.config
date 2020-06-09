Function Get-KeyVaultSecrets {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Don''t nee ShouldPorcess')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Not changed yet')]
    param(
        [string]$vaultName
    )

    Get-AzureKeyVaultSecret -VaultName $vaultName | Foreach-Object {
      
        $secret = Get-KeyVaultSecret -vaultName $vaultName -secretName $_.Name
        @{"Name" = $_.Name; "Value" = $secret}
    }

    
}