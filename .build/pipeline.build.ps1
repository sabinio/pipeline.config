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
        $Functions = (Get-ChildItem $rootpath/src/$ProjectName.module/Functions -File | Select-Object ).BaseName

        Update-ModuleManifest -Path $rootpath/src/$ProjectName.module/$ProjectName.psd1   -FunctionsToExport $Functions
        
        $results = Invoke-Pester -Script @{Path = "$rootpath/src/$ProjectName.ConfigTests"; } `
                                -OutputFile "$outPath/test-results/$ProjectName.configTests.results.xml" `
                                -OutputFormat NUnitXml  `
                                -PassThru `
                                -Show Fails

        if ($settings.FailOnTests -eq $true -and $results.TotalCount -ne $results.PassedCount){
                throw "Tests have failed see results above"
        }    

        $results = Invoke-Pester -Script @{Path = "$rootpath/src/$ProjectName.Tests";  } `
        -Tag "ModuleInstall" `
        -OutputFile "$outPath/test-results/$ProjectName.configTests.results.xml" `
        -OutputFormat NUnitXml  `
        -PassThru `
        -Show Fails
    }
    catch {
        throw
    }
    finally 
    {
        Pop-Location
    }