param($ModulePath)

if (-not $ModulePath) { $ModulePath = join-path $PSScriptRoot "../Pipeline.Config.module" }

    get-module Pipeline.Config | Remove-Module -force -Verbose:$false
    #Import-Module "$ModuleBase\ConfigHelper.psm1"

. $ModulePath\Functions\Internal\Merge-Settings.ps1
#InModuleScope ConfigHelper {
Describe 'Get-Settings' {
    BeforeAll {
        $env:settingFrom = ""
        $env:parent = ""
    }
    It "Given no config files, fails" {
        Set-StrictMode -Version 2.0
        $testsettings = Convertfrom-json '{"foo":{"bob":{"smith":"hello"}}}'
        
        Merge-Settings $testsettings $testsettings
    }
}