[CmdletBinding()]
param($ArtifactsPath)

#import-module "$psscriptroot\..\src\$($settings.ProjectName).module\$($settings.ProjectName).psd1" -force

Write-Host "Installing Pipeline.Tools module"



if (Get-PSRepository PowershellGalleryTest  -ErrorAction SilentlyContinue){Unregister-PSRepository PowershellGalleryTest}

if (-not (get-module Pipeline.Tools -ListAvailable )) {
    Install-Module Pipeline.Tools -Scope CurrentUser -Force -Repository PSGallery
}
Import-Module Pipeline.Tools 

Install-Nuget
#Powershell Get needs to be first otherwise it gets loaded by use of import-module
@{Module="PowerShellGet";Version=2.2.4.1},`
@{Module="Pester";Version=4.5},`
@{Module="PSScriptAnalyzer"},`
@{Module="platyps"} |ForEach-Object{ Install-PsModuleFast @_}

Install-AzDoArtifactsCredProvider