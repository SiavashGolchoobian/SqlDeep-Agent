$mnuExit_Click = {
    $Main.Dispose()
}
$btnExit_Click = {
    $Main.Dispose()
}
$mnuCertificate_Click = {
    Install-Certificate
}
$mnuSqlPackage_Click = {
    Install-SqlPackage
}
$mnuLoadConfig_Click = {
    Load-Config
}
$mnuSaveConfig_Click = {
    Save-Config
}
$chkDownloadAssets_CheckedChanged = {
}
$chkSyncScriptRepository_CheckedChanged = {
    Set-Controls
}
$chkSyncDatabaseModule_CheckedChanged = {
    Set-Controls
}
$chkCompare_CheckedChanged = {
    Set-Controls
}
$btnSync_Click = {
    Execute-Commands
}
$btnBrowse_Click = {
    $dlgFolderBrowser.ShowDialog()
    $txtLocalRepositoryPath.Text=$dlgFolderBrowser.SelectedPath
}
function Execute-Commands(){
    $Main.Cursor=[System.Windows.Forms.Cursors]::WaitCursor
    $lblStatus.Text='Running...'
    [string[]]$myConnections=$null;
    $myConnections=$txtConnectionString.Text.Replace("`r","").Split("`n", [StringSplitOptions]::RemoveEmptyEntries) | Where-Object {$_ -notlike "--*"}
    
    if ($chkDownloadAssets.Checked){
        #. (Join-Path $PSScriptRoot 'SqlDeepAgent.ps1') -DownloadAssets -LocalRepositoryPath ($txtLocalRepositoryPath.Text)
        Sync-SqlDeep -DownloadAssets -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text)
    }
    if ($chkCompare.Checked){
        #. (Join-Path $PSScriptRoot 'SqlDeepAgent.ps1') -SyncDatabaseModule -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
        $myConnections | ForEach-Object{Sync-SqlDeep -CompareDatabaseModule -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($_) }
    }
    if ($chkSyncDatabaseModule.Checked){
        #. (Join-Path $PSScriptRoot 'SqlDeepAgent.ps1') -SyncDatabaseModule -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
        $myConnections | ForEach-Object{Sync-SqlDeep -SyncDatabaseModule -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($_) }
    }
    if ($chkSyncScriptRepository.Checked){
        #. (Join-Path $PSScriptRoot 'SqlDeepAgent.ps1') -SyncScriptRepository -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
        $myConnections | ForEach-Object{Sync-SqlDeep  -SyncScriptRepository -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($_) }
    }
    $Main.Cursor=[System.Windows.Forms.Cursors]::Default
    $lblStatus.Text=''
}
function Set-Controls(){
    if ($chkSyncDatabaseModule.Checked -eq $true -or $chkSyncScriptRepository.Checked -eq $true -or $chkCompare.Checked -eq $true){
        $txtConnectionString.Enabled=$true
    } else {
        $txtConnectionString.Enabled=$false
    }
}
function Save-Config(){
    $Main.dlgSaveFile.Title='Save config to a file'
    $myResult=$Main.dlgSaveFile.ShowDialog()
    if ($myResult -eq [System.Windows.Forms.DialogResult]::OK){
        [string]$FilePath=$dlgSaveFile.FileName
        [hashtable]$mySettings=@{
                LocalRepositoryPath=$txtLocalRepositoryPath.Text;
                ConnectionString=$txtConnectionString.Text;
                SqlDeepRepositoryItemsFileName=$txtSqlDeepRepositoryItemFileName.Text;
            }
        $mySettings | ConvertTo-Json | Out-File -FilePath $FilePath
    }
}
function Load-Config(){
    $Main.dlgFileBrowser.Title='Load config file'
    $myResult=$Main.dlgFileBrowser.ShowDialog()
    if ($myResult -eq [System.Windows.Forms.DialogResult]::OK) {
        [string]$FilePath=$dlgFileBrowser.FileName
        $mySettings = Get-Content -Path $FilePath | ConvertFrom-Json
        $txtLocalRepositoryPath.Text=$mySettings.LocalRepositoryPath;
        $txtConnectionString.Text=$mySettings.ConnectionString;
        $txtSqlDeepRepositoryItemFileName.Text=$mySettings.SqlDeepRepositoryItemsFileName;
    }
}
function Get-ResourceAsBinary {
    param($Name)
    
    $ProcessName = (Get-Process -Id $PID).Name
    $Stream = [System.Reflection.Assembly]::GetEntryAssembly().GetManifestResourceStream("$ProcessName.g.resources")
    $KV = [System.Resources.ResourceReader]::new($Stream) | Where-Object { $_.Key -EQ $Name }
    [System.IO.BinaryReader]::new($KV.Value).ReadBytes($KV.Value.Length)
}
function Install-Certificate(){
    [string]$LocalRepositoryPath=$txtLocalRepositoryPath.Text;
    Write-Host ('Exporting SqlDeepPublic.cer to ' + $LocalRepositoryPath)
    $myBinaryContent=Get-ResourceAsBinary -Name 'SqlDeepPublic.cer'
    Set-Content -Path ($LocalRepositoryPath+'\SqlDeepPublic.cer') -Value $myBinaryContent -Encoding Byte -Force
    Import-Certificate -FilePath ($LocalRepositoryPath+'\SqlDeepPublic.cer') -CertStoreLocation 'Cert:\CurrentUser\My'
    Write-Host ($LocalRepositoryPath + '\SqlDeepPublic.cer installed')
}
function Install-SqlPackage(){
    [string]$LocalRepositoryPath=$txtLocalRepositoryPath.Text;
    Write-Host ('Exporting DacFramework_161.msi to ' + $LocalRepositoryPath)
    $myBinaryContent=Get-ResourceAsBinary -Name 'DacFramework_161.msi'
    Set-Content -Path ($LocalRepositoryPath+'\DacFramework_161.msi') -Value $myBinaryContent -Encoding Byte -Force
    Start-Process ($LocalRepositoryPath+'\DacFramework_161.msi');
    Write-Host ($LocalRepositoryPath + '\DacFramework_161.msi installed')
}
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'sqldeepagentgui.designer.ps1')
. (Join-Path $PSScriptRoot 'SqlDeepAgent.psm1')
$Main.ShowDialog()
