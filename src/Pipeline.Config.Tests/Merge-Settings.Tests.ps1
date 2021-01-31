param($ModulePath)

BeforeAll {
	Set-StrictMode -Version 1.0
	if (-not $PSBoundParameters.ContainsKey("ProjectName")) { $ProjectName = (get-item $PSScriptRoot).basename -replace ".tests", "" }
	if (-not $PSBoundParameters.ContainsKey("ModulePath")) { $ModulePath = "$PSScriptRoot\..\$ProjectName.module" }

    get-module Pipeline.Config | Remove-Module -force -Verbose:$false
    . $ModulePath\Functions\Internal\Merge-Settings.ps1
}

Describe 'Get-Settings' {
    BeforeAll {
        $env:settingFrom = ""
        $env:parent = ""
    }

    It "Ensure Merge Settings doesn't use" {
        Set-StrictMode -Version 2.0
        $testsettings = Convertfrom-json '{"foo":{"bob":{"smith":"hello"}}}'
        
        {Merge-Settings $testsettings $testsettings} | should -not -Throw "Should -Not throw due to use of variables defined outside the function"
    }
}