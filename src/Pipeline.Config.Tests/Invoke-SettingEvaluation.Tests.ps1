param($ModulePath)

BeforeAll {
	Set-StrictMode -Version 1.0
	if (-not $PSBoundParameters.ContainsKey("ProjectName")) { $ProjectName = (get-item $PSScriptRoot).basename -replace ".tests", "" }
	if (-not $PSBoundParameters.ContainsKey("ModulePath")) { $ModulePath = "$PSScriptRoot\..\$ProjectName.module" }

    get-module Pipeline.Config | Remove-Module -force
    $PSModuleAutoloadingPreference = "None"
    . "$ModulePath\Functions\Invoke-SettingEvaluation.ps1"
    . "$ModulePath\Functions\Expand-String.ps1"
}

Describe "Test Invoke-SettingEvaluation " {
    It "If personal ignore file exists use that" {

        {Invoke-SettingEvaluation} | Should -Not -throw
    }
}