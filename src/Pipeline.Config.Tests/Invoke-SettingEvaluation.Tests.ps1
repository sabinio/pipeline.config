param($ModulePath)

if (-not $ModulePath) { $ModulePath = "$PSScriptRoot\..\Pipeline.Config.module" }

get-module Pipeline.Config | Remove-Module -force

. "$ModulePath\Functions\Internal\Import-SettingsFromPersonalFile.ps1"
. "$ModulePath\Functions\Import-SettingsFromFile.ps1"
. "$ModulePath\Functions\Internal\GetPersonalConfigName.ps1"

Describe "Test Import-PersonalSettings" {
    It "If personal ignore file exists use that" {

        Invoke-SettingEvaluation 
Write-Verbose "Processing key $settingName with value $value" 
    }
}