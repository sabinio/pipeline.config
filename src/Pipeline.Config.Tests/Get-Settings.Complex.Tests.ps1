param($ModulePath)

    if (-not $ModulePath) { $ModulePath = join-path $PSScriptRoot "../Pipeline.Config.module" }

    get-module Pipeline.Config | Remove-Module -force
    #Import-Module "$ModuleBase\ConfigHelper.psm1"

    foreach ($function in (Get-ChildItem "$ModulePath/Functions/Internal/*.ps1")) {
        . $function 
    }
    foreach ($function in (Get-ChildItem "$ModulePath/Functions/*.ps1")) {
        . $function
    }
Describe "Complex Tests" {
    It "Given a hierarchy, children are overwritten" {
        $settings =  Get-Settings -ConfigRootPath "$PSScriptRoot/test-config.Complex" -environment hierarchy -verbose
        
        $settings.ParentWithChildSettings.Setting1| Should -be $settings.settingFrom
        $settings.ParentWithChildSettings.Setting2| Should -be $settings.settingFrom
    }
}