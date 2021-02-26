param($ModulePath)

BeforeAll {
	Set-StrictMode -Version 1.0
	if (-not $PSBoundParameters.ContainsKey("ProjectName")) { $ProjectName = (get-item $PSScriptRoot).basename -replace ".tests", "" }
	if (-not $PSBoundParameters.ContainsKey("ModulePath")) { $ModulePath = "$PSScriptRoot\..\$ProjectName.module" }

	get-module Pipeline.Config | Remove-Module -force
	. "$ModulePath\Functions\Internal\GetPersonalConfigPath.ps1"
}

Describe "Test Import-PersonalSettings" {
	BeforeDiscovery {
		if ($PSVersionTable.Platform -eq "unix") {
			$TestCase = @(@{UserEnv="USER"})
		}
		else {
			$TestCase = @(@{UserEnv="Username"})
		}
		 
	}
	Context "When looking for a personal config" {
		It "If should use the environment variable <UserEnv>" -TestCases $Testcase {
			Write-Host (GetPersonalConfigPath -environment "Prod")
			$USerName = (Get-Item env:$UserEnv).Value
			GetPersonalConfigPath -environment "Prod" | should -be (join-path "personal" "$USerName-Prod")
		}
	}

}