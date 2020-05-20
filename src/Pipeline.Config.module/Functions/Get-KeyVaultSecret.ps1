Function Get-KeyVaultSecret {
    param(
        [string]$vaultName, 
        [string]$secretName
    )

    (Get-AzureKeyVaultSecret -VaultName $vaultName -Name $secretName).SecretValueText
}
