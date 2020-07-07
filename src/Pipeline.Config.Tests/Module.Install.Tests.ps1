param($ModulePath, $ProjectName)

if (-not $ProjectName) {$ProjectName= (get-item $PSScriptRoot).basename -replace ".tests","" }
if (-not $ModulePath) { $ModulePath = "$PSScriptRoot\..\$ProjectName.module" }

Describe 'Ensure all functions are being exported ' -Tag "ModuleInstall" {
    Write-Host $ProjectName
    Write-Host $ModulePath

    if (get-module $ProjectName){remove-module $ProjectName -Force}
    import-module "$ModulePath\$ProjectName.psd1" -Force

    $module = get-module $ProjectName
    foreach ($functionFile in (Get-ChildItem "$ModulePath\functions" -File)) {
            $function = $functionFile.basename
        it "$Function is exported from module" {
          $module.ExportedCommands.Keys | Should Contain $Function
            #  {get-command "$function"} | should not throw
        }     
    }
}
Describe 'Ensure all psd1 matches' -Tag "ModuleInstall" {
    Write-Host $ProjectName
    Write-Host $ModulePath

    if (get-module $ProjectName){remove-module $ProjectName -Force}
    
    $moduleData = import-localizedData -FileName "$ProjectName.psd1" -baseDirectory $ModulePath 

        it "module name matches exactly in psd1 file" {
            $moduleData.RootModule | Should beexactly "$ProjectName.psm1"
        }     
        it "module name matches exactly in psd1 file" {
            (Get-Item (join-path $ModulePath "*.psm1" )).Name| Should beexactly "$ProjectName.psm1"
        }     

        it "Functions folder should match the name 'Functions' exactly" {
            (Get-ChildItem $modulePath -Directory -Filter "Functions" ).BaseName | Should beexactly "Functions"
        }     
        it "Internal folder should match the name 'Internal' exactly" {
            (Get-ChildItem (join-path $modulePath "Functions") -Directory -Filter "Internal" ).BaseName | Should beexactly "Internal"
        }     
    
}