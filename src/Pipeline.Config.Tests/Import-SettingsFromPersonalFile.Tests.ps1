param($ModulePath)

if (-not $ModulePath) { $ModulePath = "$PSScriptRoot\..\Pipeline.Config.module" }

get-module Pipeline.Config | Remove-Module -force

. "$ModulePath\Functions\Internal\Import-SettingsFromPersonalFile.ps1"
. "$ModulePath\Functions\Import-SettingsFromFile.ps1"
. "$ModulePath\Functions\Internal\GetPersonalConfigName.ps1"

Describe "Test Import-PersonalSettings" {
    It "If personal ignore file exists use that" {
        $path = "\Personal\Person-dev"
        Mock GetPersonalConfigPath {$path}
        Mock Import-SettingsFromFile
        $Root ="$PSScriptRoot\PersonalConfig"
        $fullpath = resolve-Path "$root\$path.ignore.json" 
        Import-SettingsFromPersonalFile -configRootPath $root
        Assert-MockCalled Import-SettingsFromFile -Times 1 -ParameterFilter {$file -eq $fullpath}
    }
    It "If personal ignore file does not exists use that" {
        $path = "\Personal\noignore-dev"
        Mock GetPersonalConfigPath {$path}
        Mock Import-SettingsFromFile
        $Root ="$PSScriptRoot\PersonalConfig"
        $fullpath = resolve-Path "$root\$path.json" 
        Import-SettingsFromPersonalFile -configRootPath $root
        Assert-MockCalled Import-SettingsFromFile -Times 1 -ParameterFilter {$file -eq $fullpath}
    }

}