param($ModulePath)

BeforeAll {
	Set-StrictMode -Version 1.0
	if (-not $PSBoundParameters.ContainsKey("ProjectName")) { $ProjectName = (get-item $PSScriptRoot).basename -replace ".tests", "" }
	if (-not $PSBoundParameters.ContainsKey("ModulePath")) { $ModulePath = "$PSScriptRoot\..\$ProjectName.module" }

    get-module Pipeline.Config | Remove-Module -force
    . "$ModulePath\Functions\Get-ProjectSettings.ps1"
    . "$ModulePath\Functions\Get-MyIP.ps1"
    . "$ModulePath\Functions\Get-Settings.ps1"
}

Describe "Test Get-ProjectSettings" {
    It "Doesn't fail if IpAddresses setting is not set" {
        Mock Get-Settings { @{AddMyIp = $True } }
        Mock Get-MyIp { @{Content="1.1.1.1"} }

        { Get-ProjectSettings -configRootPath "test" } | Should -Not -Throw
    }
    It "Doesn't fail if NoIp Addresses defined " {
        Mock Get-Settings { @{AddMyIp = $True; IpAddresses = @() } }
        Mock Get-MyIp { @{Content="1.1.1.1"} }

        { Get-ProjectSettings -configRootPath "test" } | Should -Not -Throw
    }

    It "Doesn't fail if NoIp Addresses defined " {
        Mock Get-Settings { @{AddMyIp = $True; IpAddresses = @() } }    
        Mock Get-MyIp { @{Content="1.1.1.1"} }
        ( Get-ProjectSettings -configRootPath "test" ).IpAddresses.startIpAddress | Should -contain "1.1.1.1"
    }
}