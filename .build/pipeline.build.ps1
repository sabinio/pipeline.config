[CmdletBinding()]
param($rootPath, $Settings)

    try{
        $ProjectName = $settings.ProjectName;

        push-location $rootPath
        if (-not $noLogo) {
            Write-BannerBuild
        }

        if ($settings.CleanBuild) {
         #   remove-item "src/$dbProjectName/bin/$($settings.buildconfig)/" -force -Recurse | Out-Null
        }

        $results = Invoke-Pester -Script @{Path = "$rootpath/src/$ProjectName.ConfigTests"; } `
                                -OutputFile "$outPath/test-results/$ProjectName.configTests.results.xml" `
                                -OutputFormat NUnitXml  `
                                -PassThru
        if ($settings.FailOnTests -eq "true" -and $results.TotalCount -ne $results.PassedCount){
                throw "Tests have failed see results above"
        }    
    }
    catch {
        throw
    }
    finally 
    {
        Pop-Location
    }