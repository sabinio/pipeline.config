function Expand-String {
    [CmdletBinding()]
    param ([string]$ExpressionToExpand)

    #If its not a script then we 
    #If its a script need to invoke it
    if ($ExpressionToExpand -is [String] `
            -and $ExpressionToExpand.StartsWith("{") -and $ExpressionToExpand.EndsWith("}")) {
        Write-Verbose "evaluating script"
        try{
            $Script = [scriptblock]::create($ExpressionToExpand).invoke()
        }
        Catch{
            $errorString = "Failed to create script block from value '$ExpressionToExpand'"
            Throw $errorString
        }

        return $script.invoke()
    }
    else {
        Write-Verbose "evaluating string $ExpressionToExpand" 
        return [scriptblock]::create("`"$ExpressionToExpand`"").invoke()
    }

}