# Neither return nor exit do in PowerShell what you think they do.
# This function is from http://weblogs.asp.net/soever/returning-an-exit-code-from-a-powershell-script
Function ExitWithCode () {
    param($exitcode)
    if ($exitcode > 0) {
        Write-Host -f red "Exiting with code $exitcode"
    } else {
        Write-Host -f green "Done, exiting with code $exitcode"
    }    
    $host.SetShouldExit($exitcode)
    exit $exitcode
}

Function ParseFailuresInTrxResultFile ([string] $xmlInputFile) {
    $xml = [Xml](Get-Content $xmlInputFile)

    # <ResultSummary outcome="Failed">
    #   <Counters total="652" executed="650" passed="630" failed="20" error="0" timeout="0" aborted="0" inconclusive="0" passedButRunAborted="0" notRunnable="0" notExecuted="0" disconnected="0" warning="0" completed="0" inProgress="0" pending="0" />
    #   ...

    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    # our input mstest XML is per this schema
    $xmlNamespace = "http://microsoft.com/schemas/VisualStudio/TeamTest/2010"
    $ns.AddNamespace("ns", $xmlNamespace)

    $xpath = "//ns:ResultSummary/ns:Counters" # xpath when namespaces exists
    $resultSummary = $xml.SelectSingleNode($xpath, $ns)
    
    return $resultSummary.failed
}

Function Invoke-Utility {
<#
.SYNOPSIS
Invokes an external utility, ensuring successful execution.

.DESCRIPTION
Invokes an external utility (program) and, if the utility indicates failure by 
way of a nonzero exit code, throws a script-terminating error.

* Pass the command the way you would execute the command directly.
* Do NOT use & as the first argument if the executable name is not a literal.

.EXAMPLE
Invoke-Utility git push

Executes `git push` and throws a script-terminating error if the exit code
is nonzero.
#>
    $exe, $argsForExe = $Args
    $ErrorActionPreference = 'Stop' # in case $exe isn't found
    & $exe $argsForExe
    if ($LASTEXITCODE) { 
        Throw "$exe indicated failure (exit code $LASTEXITCODE; full command: $Args)." 
    }
}