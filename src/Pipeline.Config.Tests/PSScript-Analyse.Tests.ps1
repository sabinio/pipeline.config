param($ModulePath, $ProjectName)
if (-not $ModulePath){ $ModulePath = "$PSScriptRoot\..\$ProjectName.module"}

$Scripts = Get-ChildItem "$ModulePath\" -Filter '*.ps1' -Recurse | Where-Object {$_.name -NotMatch 'Tests.ps1'}
$Modules = Get-ChildItem "$ModulePath\" -Filter '*.psm1' -Recurse


$ExcludeRules = @('PSAvoidTrailingWhitespace','PSAvoidUsingWriteHost' )

$Rules = (Get-ScriptAnalyzerRule  | Where-Object {$ExcludeRules -notcontains $_.ruleName}).RuleName

Describe 'PSAnalyser Testing Modules ' -Tag "PSScriptAnalyzer" {
    foreach ($module in $modules) {
        
        $RuleResults = Invoke-ScriptAnalyzer -Path $module.FullName 
        Context "- $($module.BaseName)" {
            foreach ($rule in $rules) {
                It "Rule $($rule)" {
                    if ($RuleResults.Count -ne 0){
                        ($RuleResults | Where-Object {$_.Rulename -eq $rule}).Message | Should Be $null 
                   
                    }
                }
            }
        }
    }
}
Describe 'PSAnalyser Testing scripts'  -Tag "PSScriptAnalyzer"{
    foreach ($Script in $scripts) {
        $RuleResults = Invoke-ScriptAnalyzer -Path $script.FullName         
        Context "- $($script.BaseName)" {
            foreach ($rule in $rules) {
                It "Rule $($rule)" {
                    if ($RuleResults.Count -ne 0){
                         ($RuleResults | Where-Object {$_.Rulename -eq $rule}).Message | Should Be $null 
                    }
                }
            }
        }
    }
}
