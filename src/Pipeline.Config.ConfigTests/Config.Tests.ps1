param($RootPath)

if (-not $RootPath) { $RootPath = "$PSScriptRoot\..\.." }
$configRoot = "$rootpath/.build/config/"
Remove-module Pipeline.Config -force
Import-Module $rootpath/src/Pipeline.Config.Module/Pipeline.Config.psd1 -Force 

BeforeAll {
    if ($env:OldUsername) { throw "`$env:oldUsername set, copy back to `$env:UserName to ensure you don't lose it" }
    $Env:Oldusername = $env:UserName
}

AfterAll {
    $env:UserName = $Env:Oldusername
    $Env:Oldusername = ""
}
Describe "Config tests" {
    it "when a PR has a complex branch name the prereleaseTag is valid" {
        $originalValue = $env:System_PullRequest_SourceBranch 
        try {
            #Load settings from config
            $env:System_PullRequest_SourceBranch = "refs/pull/featurea"
            $settings = (Get-ProjectSettings -environment pr -ConfigRootPath $configRoot ) 
            
            $settings.prerelease | should be "prfeaturea"
        }
        finally {
            $env:System_PullRequest_SourceBranch = $originalValue
        }
    }
    it "when a PR has a complex branch name the prereleaseTag is valid" {
        $originalValue = $env:System_PullRequest_SourceBranch 
        try {
            #Load settings from config
            $env:System_PullRequest_SourceBranch = "refs/pull/123_someName"
            $settings = (Get-ProjectSettings -environment pr -ConfigRootPath $configRoot ) 
            
            $settings.prerelease | should be "pr123someName"
        }
        finally {
            $env:System_PullRequest_SourceBranch = $originalValue
        }
    }
}
Describe "Ensure Config runs for all users" {
    $users = ((Get-ChildItem $configRoot\personal).basename | Select-Object @{n = "user"; e = { $_.split('-')[0] } } -Unique).user
    $environments = (Get-ChildItem $configRoot\env | Select-Object basename -Unique).basename 
    $OriginalUsername = $env:UserName 
       
    Write-Verbose ("{0} {1}" -f $users.Count, $environments.Count)
    foreach ($environment in $environments) {
        it "ensure settings work for environment:$environment " {
            #  Mock GetPersonalConfigPath { "nonexistenuser-$environment.json" }
            try {
                $env:UserName = "non existent user"
                
                Get-ProjectSettings -environment $environment -ConfigRootPath $configRoot 
            }
            finally {
                $env:UserName = $OriginalUsername
            }
        }

        foreach ($user in $users) {
            it "ensure settings work for user:$user for environment:$environment " {
                $env:UserName = $user
                try {
                    $Settings = @{}
                    if ("SimonSabin","JonSeddon" -contains $user){$settings=@{PowershellRepositoryKey="none"}}
                    $getSetting = {Get-ProjectSettings -environment $environment -ConfigRootPath $configRoot @Settings -verbose:$VerbosePreference}

                    if ("RichardLee" -contains $user -and $environment -eq "localdev"  ){
                        $getSetting | should Throw "need to get PAT token for Azure DevOps"
                    }                 
                    else {
                        $getSetting| should not throw
                    }
                }
                finally {
                    $env:UserName = $OriginalUsername
                } }
        }
    }
}
