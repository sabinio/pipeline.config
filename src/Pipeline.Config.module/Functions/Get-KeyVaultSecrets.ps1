Function Get-KeyVaultSecrets {
    param(
        [string]$vaultName
    )

    Get-AzureKeyVaultSecret -VaultName $vaultName | Foreach-Object {
      
        $secret = Get-KeyVaultSecret -vaultName $vaultName -secretName $_.Name
        @{"Name" = $_.Name; "Value" = $secret}
    }

    
}