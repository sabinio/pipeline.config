[CmdletBinding()]
param (
    [switch] $Clean,
    [switch] $Install,
    [switch] $Test,
    [Switch] $Build,
    [switch] $Package,
    [switch] $Publish,
    [switch] $Tidy,
    [switch] $noLogo,
    [string] $environment = $env:environment,
    [string] $rootPath = $env:rootpath,
    [string] $artifactsPath = $env:artifactspath,
    [string] $verboseLogging = $env:VerboseLogging, #"Install,Build,Package,DeployInfra,Deploy,Config,Module,*",
    [parameter(ValueFromRemainingArguments = $true)]
    $parameterOverrides
)
$ErrorActionPreference = "Stop"

push-location $PSScriptroot
Set-StrictMode -Version 1.0
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    if ([string]::IsNullOrEmpty($environment)) {
            $environment = 'localdev'
    }
    if ([string]::IsNullOrEmpty($rootPath)) { $rootPath = join-path $PSScriptroot ".." | Resolve-Path };
    if ([string]::IsNullOrEmpty($artifactsPath)) { $artifactsPath = join-path $rootPath "artifacts" };
    [string] $outPath = join-path $rootPath "out";

    Write-Host "Processing with "
    Write-Host "   Root path       = $rootpath"
    Write-Host "   Artifacts path  = $artifactsPath"
    Write-Host "   Out path        = $outPath"
    Write-Host "   PSScriptroot    = $PSScriptroot"

    . ./scripts/logging.ps1

    $ConfigVerbose = (Test-LogAreaEnabled -logging $verboseLogging -area "config")

    
    if ($Install) {  
        ./pipeline.install-tools.ps1  -artifactsPath "$artifactsPath\tools" -verbose:(Test-LogAreaEnabled -logging $verboseLogging -area "install")
    }

    Import-Module ../src/Pipeline.Config.module/Pipeline.Config.psd1 -Force -verbose:$ConfigVerbose #Verbose needs to be passed through as its not taken from the scripts setting
    
    if (-not $noLogo) {
        Write-Banner
    }

    #Load settings from config
    $settings = (Get-ProjectSettings -environment $environment -ConfigRootPath "$PSScriptroot/config/" -verbose:$ConfigVerbose -overrides $parameterOverrides) 

    write-host ("##vso[build.updatebuildnumber] {0}.{1}" -f $settings.ProjectName, $settings.FullVersion)

    Write-Host ($settings | Convertto-json)

    if ($Clean) {
        if (Test-path $artifactsPath) { Remove-Item -Path $artifactsPath -Recurse -Force | Out-Null }
        if (Test-path $outPath) { Remove-Item -Path $outPath -Recurse -Force | Out-Null }
    }

    if (Test-Path "$outPath/test-results/") {
        Write-Verbose "Clearing Test results folder"
        Remove-Item "$outPath/test-results/*" -Recurse -Force 
    }
    else {
        New-Item -ItemType Directory -Force -Path "$outPath/test-results/" | Out-Null 
    }

    if ($Build) {     
        ./pipeline.build.ps1  -settings $settings -rootPath $rootPath -verbose:(Test-LogAreaEnabled -logging $verboseLogging -area "build")
        ./pipeline.createdocs.ps1  -settings $settings -rootPath $rootPath -verbose:(Test-LogAreaEnabled -logging $verboseLogging -area "build")
    }

    if ($Package) {
        ./pipeline.package.ps1  -settings $settings -ArtifactsPath $artifactsPath -verbose:(Test-LogAreaEnabled -logging $verboseLogging -area "package")
    }

    if ($Test) {
        ./pipeline.test.ps1 -ArtifactsPath $artifactsPath -settings $settings -rootpath $rootpath -outPath $outPath -verbose:(Test-LogAreaEnabled -logging $verboseLogging -area "test") 
    }

    if ($Publish) {
        . ./pipeline.update-manifest.ps1 
        Update-Manifest -settings $settings -ArtifactsPath $artifactsPath -verbose:(Test-LogAreaEnabled -logging $verboseLogging -area "publish")
        ./pipeline.publish.ps1  -settings $settings -ArtifactsPath $artifactsPath -verbose:(Test-LogAreaEnabled -logging $verboseLogging -area "publish")
    }

    if ($Tidy) {
        ./pipeline.tidy.ps1 -ArtifactsPath $artifactsPath -settings $settings -outPath $outPath -verbose:(Test-LogAreaEnabled -logging $verboseLogging -area "tidy") 
     
    }
  
}

catch {
    
    $errorRecord = $_
    # This provides the vs code friendly links to the position the error occurs 
    Write-Host -ForegroundColor Red "$ErrorRecord $($ErrorRecord.InvocationInfo.PositionMessage)"

    if ($ErrorRecord.Exception) {
        Write-Host -ForegroundColor Red $ErrorRecord.Exception
    }

    if ($null -ne (Get-Member -InputObject $ErrorRecord -Name ScriptStackTrace)) {
        #PS 3.0 has a stack trace on the ErrorRecord; if we have it, use it & skip the manual stack trace below
        Write-Host -ForegroundColor Red $ErrorRecord.ScriptStackTrace
    }
    else {

        Get-PSCallStack | Select-Object -Skip 1 | ForEach-Object {
            Write-Host -ForegroundColor Yellow -NoNewLine "! "
            Write-Host -ForegroundColor Red $_.Command $_.Location $(if ($_.Arguments.Length -le 80) { $_.Arguments })
        }
    }  

    Throw "An error has occurred"
} 
finally{
    pop-location
}