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
    It "Given a hierarchy, children have expressions expanded" {
        $settings =  Get-Settings -ConfigRootPath "$PSScriptRoot/test-config.Complex2" -environment hierarchy 
        
        $settings.ParentWithChildSettings.Level1Child1.Name| Should -be "smith"
        $settings.ParentWithChildSettings.Level1Child2.Name| Should -be "bob"
    }
}