param($ModulePath, $ProjectName)

if (-not $ProjectName) {$ProjectName= (get-item $PSScriptRoot).basename -replace ".tests","" }
if (-not $ModulePath) { $ModulePath = "$PSScriptRoot\..\$ProjectName.module" }

Describe 'Ensure all functions are being exported ' -Tag "ModuleInstall" {
    Write-Host $ProjectName
    Write-Host $ModulePath

    if (get-module $ProjectName){remove-module $ProjectName -Force}
    import-module "$ModulePath\$ProjectName.psd1" -Force -Verbose

    $module = get-module $ProjectName
    foreach ($functionFile in (Get-ChildItem "$ModulePath\functions" -File)) {
            $function = $functionFile.basename
        it "$Function is exported from module" {
          $module.ExportedCommands.Keys | Should Contain $Function
            #  {get-command "$function"} | should not throw
        }     
    }
}