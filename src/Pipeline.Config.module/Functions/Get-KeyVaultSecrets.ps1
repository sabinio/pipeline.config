Function Get-KeyVaultSecrets {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Don''t nee ShouldPorcess')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Not changed yet')]
    param(
        [string]$vaultName
    )

    $secrets = Get-AzKeyVaultSecret -VaultName $vaultName
    $secrets | Foreach-Object {
      # get-AzKeyVaultSecret doesn't return the secret unless the secretname is passed.
      # We use 
        $secret = Get-KeyVaultSecret -vaultName $vaultName -secretName $_.Name
    [pscustomObject]@{"Name" = $_.Name; "Value" = $secret}
    }

    
}