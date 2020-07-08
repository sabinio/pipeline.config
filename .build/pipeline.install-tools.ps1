[CmdletBinding()]
param($ArtifactsPath)

#import-module "$psscriptroot\..\src\$($settings.ProjectName).module\$($settings.ProjectName).psd1" -force

function Repair-PSModulePath {

    if ($PSVersionTable.PsEdition -eq "Core") {
        $mydocsPath = join-path ([System.Environment]::GetFolderPath("MyDocuments")) "PowerShell/Modules"
    }
    else {
        $mydocsPath = join-path ([System.Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell/Modules"
    }

    If ("$($env:PSModulePath)".Split([IO.Path]::PathSeparator) -notcontains $mydocsPath) {
        Write-Verbose "Adding LocalModule folder to PSModulePath"
        $env:PSModulePath = "$mydocsPath$([IO.Path]::PathSeparator)$($env:PSModulePath)"
    }
}

if (Get-PSRepository PowershellGalleryTest  -ErrorAction SilentlyContinue){Unregister-PSRepository PowershellGalleryTest}

$LatestVersion = (Find-Module Pipeline.Tools -Repository "PSGallery").Version
Write-Host "Getting Pipeline.Tools module $LatestVersion"

Repair-PSModulePath 

if (-not ((get-module Pipeline.Tools -ListAvailable).Version -eq $LatestVersion)) {
    Write-Host "Installing Pipeline.Tools module $LatestVersion"
    get-module Pipeline.Tools |remove-module
    Install-Module Pipeline.Tools -Scope CurrentUser -RequiredVersion $LatestVersion -Force -Repository PSGallery -Verbose:$VerbosePreference -SkipPublisherCheck -AllowClobber -ErrorAction "Stop"
}
if (-not ((get-module Pipeline.Tools -Verbose:$VerbosePreference).Version -eq $LatestVersion)){
    Write-Host "Importing Pipeline.Tools module  $LatestVersion"
    get-module Pipeline.Tools |remove-module
    Import-Module Pipeline.Tools -RequiredVersion $LatestVersion -Verbose:$VerbosePreference -ErrorAction "Stop"
}

#Powershell Get needs to be first otherwise it gets loaded by use of import-module
@{Module="PowerShellGet";Version=2.2.4.1},`
@{Module="Pester";MaxVersion="4.9999.0";},`
@{Module="PSScriptAnalyzer";Latest=$true},`
@{Module="platyps";Latest=$true},`
@{Module="Az.keyVault";} |ForEach-Object{ Install-PsModuleFast @_}

Install-AzDoArtifactsCredProvider

