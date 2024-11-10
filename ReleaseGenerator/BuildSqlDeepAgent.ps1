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
$myCertificate = (Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object -Property Subject -eq 'CN=sqldeep.com'); 
$myFolderPhrase='SqlDeep-Synchronizer'
$myBasePath=(Get-Location).Path
$myBasePath=$myBasePath.Substring(0,$myBasePath.LastIndexOf($myFolderPhrase)+$myFolderPhrase.Length)
if (Test-Path $myBasePath\GUI\Out -PathType Container) {Remove-Item $myBasePath\GUI\Out\ -Recurse -Force;Write-Host 'out folder was removed'}
if (Test-Path $myBasePath\GUI\SqlDeepAgentGUI.exe -PathType Leaf) {Remove-Item $myBasePath\GUI\SqlDeepAgentGUI.exe;Write-Host 'exe file was removed'}
if (Test-Path $myBasePath\CLI\SqlDeepAgent.psm1 -PathType Leaf) {Remove-AuthenticodeSignature -Path $myBasePath\CLI\SqlDeepAgent.psm1;Write-Host 'signature content was removed'}
if (Test-Path $myBasePath\CLI\SqlDeepAgent.psm1 -PathType Leaf) {(Get-Content $myBasePath\CLI\SqlDeepAgent.psm1).Replace('#<#SqlDeep-Comment','<#SqlDeep-Comment').Replace('#SqlDeep-Comment#>','SqlDeep-Comment#>') | Set-Content $myBasePath\CLI\SqlDeepAgent.psm1;Write-Host 'Comment parameters'}
Merge-Script -Script $myBasePath\GUI\SqlDeepAgentGUI.ps1 -Bundle -OutputPath $myBasePath\GUI\Out -Verbose
Write-Host 'SqlAgent bundle file is created'
Merge-Script -ConfigFile $myBasePath\GUI\SqlDeepAgentGUI.psd1 -Verbose -Debug
Write-Host 'SqlAgent exe file is created'
if (Test-Path $myBasePath\GUI\Out\SqlDeepAgentGUI.exe -PathType Leaf) {Move-Item $myBasePath\GUI\Out\SqlDeepAgentGUI.exe $myBasePath\GUI ;Write-Host 'exe file was moved'}
if (Test-Path $myBasePath\CLI\SqlDeepAgent.psm1 -PathType Leaf) {(Get-Content $myBasePath\CLI\SqlDeepAgent.psm1).Replace('<#SqlDeep-Comment','#<#SqlDeep-Comment').Replace('SqlDeep-Comment#>','#SqlDeep-Comment#>') | Set-Content $myBasePath\CLI\SqlDeepAgent.psm1;Write-Host 'Remove Comment parameters'}
Set-AuthenticodeSignature -FilePath  $myBasePath\CLI\SqlDeepAgent.psm1 -Certificate $myCertificate -IncludeChain All -TimeStampServer http://timestamp.digicert.com
Write-Host 'SqlDeepAgent.psm1 was re-signed'