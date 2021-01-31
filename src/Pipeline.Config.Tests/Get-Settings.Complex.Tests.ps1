param($ModulePath)
BeforeAll {
	Set-StrictMode -Version 1.0
	if (-not $PSBoundParameters.ContainsKey("ProjectName")) { $ProjectName = (get-item $PSScriptRoot).basename -replace ".tests", "" }
	if (-not $PSBoundParameters.ContainsKey("ModulePath")) { $ModulePath = "$PSScriptRoot\..\$ProjectName.module" }

    get-module Pipeline.Config | Remove-Module -force
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/Internal/*.ps1")) {
        . $function 
    }
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/*.ps1")) {
        . $function
    }
}
Describe "Complex Tests" {
    It "Given a hierarchy, children have expressions expanded" {
        $settings =  Get-Settings -ConfigRootPath "$PSScriptRoot/test-config.Complex" -environment hierarchy 
        
        $settings.ParentWithChildSettings.Setting1| Should -be $settings.settingFrom
        $settings.ParentWithChildSettings.Setting2| Should -be $settings.settingFrom
    }
    It "Given a hierarchy, children that are arrays have expressionsExpanded" {
        $settings =  Get-Settings -ConfigRootPath "$PSScriptRoot/test-config.Complex" -environment hierarchy 
        
        $settings.ParentWithChildSettings.Level1ChildSetting.Level2Array | Should -be @($settings.settingFrom)
    }
    It "Given a hierarchy, children that have childen attributes have expressionsExpanded" {
        $settings =  Get-Settings -ConfigRootPath "$PSScriptRoot/test-config.Complex" -environment hierarchy 
        
        $settings.ParentWithChildSettings.Level1ChildSetting.Level2ChildSetting | Should -be $settings.settingFrom
        
    }
}