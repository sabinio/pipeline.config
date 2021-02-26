Function GetPersonalConfigPath {
    [CmdletBinding()]
    param(
        [string]$environment
    )
	
    if ($PSVersionTable.Platform -eq "unix") {
		$UserPrefix =  $env:USER
	}
	else {
		$UserPrefix =  $env:UserName
	}
    join-path "personal" "$UserPrefix-$environment"
}