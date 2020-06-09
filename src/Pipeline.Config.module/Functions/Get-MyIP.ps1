
Function Get-MyIp {
    <#
    .Synopsis
    Get internet-facing IP address
    .Description
    Get internet-facing IP address
    #>
    [CmdletBinding()]
    param()
    try {
        $myIP = Invoke-WebRequest -UserAgent "sabin.io build tools" -UseBasicParsing -Uri "http://bot.whatismyipaddress.com/" -TimeoutSec 1  -ErrorAction SilentlyContinue
    }
    catch {
            Write-Host "Error occurred getting MyIP - Will be ignored"
            Write-Host $_.Message
            $myIP=""
    }
    return $myIP
}