@{
    CustomRulePath = 'Rules.psm1'
    IncludeDefaultRules = $true
    ExcludeRules =@('PSAvoidTrailingWhitespace','PSAvoidUsingWriteHost','PSAvoidUsingConvertToSecureStringWithPlainText')
} 