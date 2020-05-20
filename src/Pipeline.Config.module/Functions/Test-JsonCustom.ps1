Function Test-JsonCustom {
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [string]$json
    )

    try {
        ConvertFrom-Json $json -ErrorAction Stop;
        $true;
    }
    catch {
        $false;
    }
}