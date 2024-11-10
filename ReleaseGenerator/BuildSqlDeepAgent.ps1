function Remove-AuthenticodeSignature {
    param (
        [string]$Path
    )

    $fileContent = Get-Content $Path
    $signatureLine = $fileContent | Select-String '# SIG # Begin signature block'

    if ($null -eq $signatureLine) {
        Write-Host "No signature block found in file: $Path"
        return
    }

    $lineNumber = $signatureLine.LineNumber - 2
    $newContent = $fileContent[0..$lineNumber]
    $newContent | Set-Content $Path
}
if (Test-Path ..\GUI\bin\ -PathType Container) {Remove-Item ..\GUI\Out\ -Recurse -Force;Write-Host 'out folder was removed'}
if (Test-Path ..\GUI\SqlDeepAgentGUI.exe -PathType Leaf) {Remove-Item ..\GUI\SqlDeepAgentGUI.exe;Write-Host 'exe file was removed'}
if (Test-Path ..\CLI\SqlDeepAgent.psm1 -PathType Leaf) {Remove-AuthenticodeSignature -Path ..\CLI\SqlDeepAgent.psm1;Write-Host 'signature content was removed'}
Merge-Script -Script ..\GUI\SqlDeepAgentGUI.ps1 -Bundle -OutputPath ..\GUI\Out -Verbose
Write-Host 'SqlAgent bundle file is created'
Merge-Script -ConfigFile ..\GUI\SqlDeepAgentGUI.psd1 -Verbose -Debug
Write-Host 'SqlAgent exe file is created'
