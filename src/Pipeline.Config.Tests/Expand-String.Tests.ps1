param($ModulePath)
$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

if (-not $ModulePath) { $ModulePath =  join-path (join-path $PSScriptRoot "..") "Pipeline.Config.module" }

get-module Pipeline.Config | Remove-Module -force

. $ModulePath/functions/$CommandName.ps1

function Compare-string
{
    param($expected,$actual)
    $mismatch=0
    $comparison =  (0..$expected.Length)| %{$i=$_;
        if ($i -lt $actual.length) {$actualByte = [byte]$actual[$i]} else {$actualByte=-1};
        if ($i -lt $expected.length) {$expectedByte = [byte]$expected[$i]} else {$expectedByte=-1};

        if ($actualByte -eq $expectedByte){$char=" "} else {$char="~";
            $mismatch ++
        }

        if ((($actualByte,$expectedByte)| where-object {(10,13) -contains $_ }| Measure-Object).Count){
            $len = 2
        } else {$len=1}
        
        [PSCustomObject]@{
        position = $_;
        compare = ([byte]$actual[$i]) -eq ([byte]$expected[$i]);
        marker = $char;
        len = $len
    }}

    return @{mismatch=$mismatch;
            actualEncoded = (($comparison|%{"{0,$($_.len)}" -f ($actual[$_.position] -replace "\r" ,"\r" -replace "\n","\n")}) -join "");
            positionMarkers =  (($comparison|%{"{0,$($_.len)}" -f $_.marker}) -join "");
            expectedencoded =  (($comparison|%{"{0,$($_.len)}" -f ($expected[$_.position] -replace "\r" ,"\r" -replace "\n","\n")}) -join "");
            results = $comparison
    }
}

Describe "Test Expand-String" {
    It "Ensure when script is invalid a meaningful error is thrown" {
        $ErrorActionPreference="stop"
        $expected = @"
At line:1 char:8`r`n+ {"{0}" "a string"}`r`n+        ~~~~~~~~~~`nUnexpected token '"a string"' in expression or statement.`r`n
"@
$ErrorActionPreference = "Stop"
        try        {
            Expand-String '{"{0}" "a string"}' -ErrorAction "Stop"}
        catch{
            $Exception = ($_.Exception.Message | out-string)
        }
        $Exception | should belike "*At line:1 char:8*"
        $Exception | should belike "*Unexpected token '`"a string`"' in expression or statement*"
        $Exception | should belike '*+ {"{0}`" "a string"}*'

        $results = Compare-string ($expected -replace "\r","" -replace "\n","") ($exception -replace "\r","" -replace "\n","")
        if ($results.mismatch -gt 0){
            Write-Host ("Actual    - {0}" -f $results.actualEncoded)
            Write-Host ("          - {0}" -f $results.positionMarkers)
            Write-Host ("Expected  - {0}" -f $results.expectedEncoded)
        }
        $results.mismatch | should be 0

    }
}

Describe "Validate Verbose output for $CommandName"{
    It "Verbose output returns script expression"{
        Mock Write-Verbose {Write-Host "**$Message"}

        Expand-String "{'Hello'}" -Verbose | Should be "Hello"

        Assert-MockCalled Write-Verbose  -times 1
        Assert-MockCalled Write-Verbose -parameterFilter {$Message -like "*evaluating script {'Hello'}"} -times 1

    }

}