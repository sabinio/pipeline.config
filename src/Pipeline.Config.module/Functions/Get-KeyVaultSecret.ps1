Function Get-KeyVaultSecret {
    param(
        [string]$vaultName, 
        [string]$secretName
    )
    (Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName).SecretValue
}
