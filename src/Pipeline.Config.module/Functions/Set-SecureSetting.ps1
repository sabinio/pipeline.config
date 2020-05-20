
Function Set-SecureSetting{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification='Need to handle plain text in')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Don''t nee ShouldPorcess')]
 
    param(
        [string]$ConfigRootPath,
        [string]$Name,
        [string]$Value
        )

        $secureValue  ="{ConvertTo-SecureString $(ConvertTo-SecureString -AsPlainText -Force  $Value |ConvertFrom-SecureString)}"
        Write-Verbose "Name $Name - Secure value to set is $secureValue"
        Set-Setting -ConfigRootpath $ConfigRootPath -Name $Name -Value $secureValue
}