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
Describe "Invoke-SettingEvaluation nesting" {
    It "evaluates strings inside arrays" {
        $r = Invoke-SettingEvaluation -settings ([pscustomobject]@{ A = @('{ "x" + "y" }', "b") })
        $r.A[0] | Should -Be "xy"
        $r.A[1] | Should -Be "b"
    }
    It "handles arrays nested in arrays and null items" {
        $r = Invoke-SettingEvaluation -settings ([pscustomobject]@{ A = @(, @("q", "r")); N = @($null, "z") })
        $r.A[0][1] | Should -Be "r"
        $r.N[0] | Should -BeNullOrEmpty
        $r.N[1] | Should -Be "z"
    }
    It "handles arrays at every object depth and keeps booleans" {
        $s = [pscustomobject]@{ A = @([pscustomobject]@{ B = @([pscustomobject]@{ C = @([pscustomobject]@{ D = "{ 'x' }"; E = $true }) }) }) }
        $r = Invoke-SettingEvaluation -settings $s
        $r.A[0].B[0].C[0].D | Should -Be "x"
        $r.A[0].B[0].C[0].E | Should -BeOfType [bool]
        $r.A[0].B[0].C[0].E | Should -BeTrue
    }
    It "handles hashtables containing arrays" {
        $r = Invoke-SettingEvaluation -settings @{ A = @(@{ N = "a" }) }
        $r.A[0].N | Should -Be "a"
    }
}
