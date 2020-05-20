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

    $ScriptAnalysis = Invoke-Pester -Script @{Path = "$rootpath/src/$ProjectName.tests"; Parameters=@{ProjectName=$ProjectName}} `
                            -Tag "PSScriptAnalyzer" `
                            -OutputFile "$outPath/test-results/$ProjectName.PsScripttests.results.xml" `
                            -OutputFormat NUnitXml `
                            -PassThru

    $NormalTests = Invoke-Pester -Script @{Path = "$rootpath/src/$ProjectName.tests"; } `
                            -ExcludeTag "PSScriptAnalyzer" `
                            -OutputFile "$outPath/test-results/$ProjectName.tests.results.xml" `
                            -OutputFormat NUnitXml  `
                            -CodeCoverage "$rootpath/src/$ProjectName.module/Functions/*.ps1" `
                            -CodeCoverageOutputFile "$outPath/test-results/coverage_$ProjectName.xml"  `
                            -PassThru 
                            
    if ($settings.FailOnTests -eq "true" -and `
        ($NormalTests.TotalCount -ne $NormalTests.PassedCount `
        -or $ScriptAnalysis.TotalCount -ne $ScriptAnalysis.PassedCount  ))
        {
            Throw "Tests Failed see above"
    }
}

catch {
    throw
}
