param($ModulePath,$SourcePath, $ProjectName)
if (-not $ModulePath){ $ModulePath = "$PSScriptRoot\..\$ProjectName.module"}
if (-not $SourcePath){ $SourcePath = "$ModulePath"}


Describe 'PSAnalyser Testing Modules ' -Tag "PSScriptAnalyzer" {
    $ModulePath = resolve-path $ModulePath
    $SourcePath = Resolve-path $SourcePath
    $script:Modules = Get-ChildItem $ModulePath -Filter '*.psm1' -Recurse
        
    $ExcludeRules = @('PSAvoidTrailingWhitespace','PSAvoidUsingWriteHost' )
    
    $script:Rules = (Get-ScriptAnalyzerRule  | Where-Object {$ExcludeRules -notcontains $_.ruleName}).RuleName
  
    foreach ($module in $script:modules) {
        
        $RuleResults = Invoke-ScriptAnalyzer -Path $module.FullName 
        Context "- $($module.BaseName)" {
            foreach ($rule in $script:rules) {
                It "Rule $($rule)" {
                    if ($RuleResults.Count -ne 0){
                        ($RuleResults | Where-Object {$_.Rulename -eq $rule}).Message | Should Be $null Message "sdfsd"
                   
                    }
                }
            }
        }
    }
}
Describe 'PSAnalyser Testing scripts'  -Tag "PSScriptAnalyzer"{
    $ModulePath = resolve-path $ModulePath
    $SourcePath = Resolve-path $SourcePath

    $script:Scripts = Get-ChildItem $ModulePath -Filter '*.ps1' -Recurse | Where-Object {$_.name -NotMatch 'Tests.ps1'}
    $ExcludeRules = @('PSAvoidTrailingWhitespace','PSAvoidUsingWriteHost' )
    $script:Rules = (Get-ScriptAnalyzerRule  | Where-Object {$ExcludeRules -notcontains $_.ruleName}).RuleName
  
    foreach ($Script in $scripts) {
        $RuleResults = Invoke-ScriptAnalyzer -Path $script.FullName   
        $sourceFile = $script.FullName.replace($ModulePath, $sourcePath )

        Context "- $($script.BaseName) $sourceFile" {
            foreach ($rule in $rules) {
                It "Rule $($rule) " {
                    if ($RuleResults.Count -ne 0){
                         ($RuleResults | Where-Object {$_.Rulename -eq $rule}).Message | Should Be $null 
                    }
                }
            }
        }
    }
}
