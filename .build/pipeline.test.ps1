[CmdletBinding()]
param($settings
    , $artifactsPath
    , $rootpath
    , $outPath )

    $ProjectName = $settings.ProjectName;

try {
        
    if (-not $noLogo) {
        Write-BannerTest
    }
    
    if (Test-Path "$outPath/test-results/") { $null }
    else {
        New-Item -ItemType Directory -Force -Path "$outPath/test-results/" | Out-Null 
    }
    get-module $ProjectName | remove-module  -force

    $ScriptAnalysis = Invoke-Pester -Script @{Path = "$rootpath/src/$ProjectName.Tests"; Parameters=@{ProjectName=$ProjectName}} `
                            -Tag "PSScriptAnalyzer" `
                            -ExcludeTag $settings.ExcludeTags `
                            -OutputFile "$outPath/test-results/$ProjectName.PsScripttests.results.xml" `
                            -OutputFormat NUnitXml `
                            -PassThru `
                            -Show Fails
                            
    $NormalTests = Invoke-Pester -Script @{Path = "$rootpath/src/$ProjectName.Tests"; Parameters=@{ModulePath="$artifactsPath\$ProjectName";ProjectName=$ProjectName}} `
                            -ExcludeTag "PSScriptAnalyzer" `
                            -OutputFile "$outPath/test-results/$ProjectName.tests.results.xml" `
                            -OutputFormat NUnitXml  `
                            -CodeCoverage "$artifactsPath\$ProjectName\Functions\*.ps1" `
                            -CodeCoverageOutputFile "$outPath/test-results/coverage_$ProjectName.xml"  `
                            -PassThru `
                            -Show Fails

    Write-Host "Normal Tests Total $($NormalTests.TotalCount ) Passed $($NormalTests.PassedCount) "
    Write-Host "ScriptAnalysis Tests Total $($ScriptAnalysis.TotalCount ) Passed $($ScriptAnalysis.PassedCount) "
    if ($settings.FailOnTests -eq $true -and `
        ($NormalTests.TotalCount -ne $NormalTests.PassedCount `
        -or $ScriptAnalysis.TotalCount -ne $ScriptAnalysis.PassedCount  ))
        {
            Throw "Tests Failed see above"
    }
}

catch {
    throw
}
