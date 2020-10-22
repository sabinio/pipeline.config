param($ModulePath)

if (-not $ModulePath) { $ModulePath = "$PSScriptRoot\..\Pipeline.Config.module" }

get-module Pipeline.Config | Remove-Module -force
$PSModuleAutoloadingPreference = "None"

. "$ModulePath\Functions\Invoke-SettingEvaluation.ps1"
. "$ModulePath\Functions\Expand-String.ps1"

Describe "Test Invoke-SettingEvaluation " {
    It "If personal ignore file exists use that" {

        {Invoke-SettingEvaluation} | Should not throw
    }
}