param($ModulePath)

if (-not $ModulePath) { $ModulePath = "$PSScriptRoot\..\Pipeline.Config.module" }

get-module Pipeline.Config | Remove-Module -force

. "$ModulePath\functions\Get-ProjectSettings.ps1"
. "$ModulePath\functions\Get-MyIp.ps1"
. "$ModulePath\functions\Get-Settings.ps1"

Describe "Test Get-ProjectSettings" {
    It "Doesn't fail if IpAddresses setting is not set" {
        Mock Get-Settings { @{AddMyIp = $True } }
        Mock Get-MyIp { @{Content="1.1.1.1"} }

        { Get-ProjectSettings -configRootPath "test" } | Should not Throw
    }
    It "Doesn't fail if NoIp Addresses defined " {
        Mock Get-Settings { @{AddMyIp = $True; IpAddresses = @() } }
        Mock Get-MyIp { @{Content="1.1.1.1"} }

        { Get-ProjectSettings -configRootPath "test" } | Should not Throw
    }

    It "Doesn't fail if NoIp Addresses defined " {
        Mock Get-Settings { @{AddMyIp = $True; IpAddresses = @() } }
        Mock Get-MyIp { @{Content="1.1.1.1"} }
        ( Get-ProjectSettings -configRootPath "test" ).IpAddresses.startIpAddress | Should contain "1.1.1.1"
    }
}