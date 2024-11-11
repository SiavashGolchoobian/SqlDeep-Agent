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
    $Main.Cursor=[System.Windows.Forms.Cursors]::WaitCursor
    [string[]]$myConnections=$null;
    $myConnections=$txtConnectionString.Text.Replace("`r","").Split("`n", [StringSplitOptions]::RemoveEmptyEntries) | Where-Object {$_ -notlike "--*"}
    
    if ($chkDownloadAssets.Checked){
        #. (Join-Path $PSScriptRoot 'SqlDeepAgent.ps1') -DownloadAssets -LocalRepositoryPath ($txtLocalRepositoryPath.Text)
        Sync-SqlDeep -DownloadAssets -LocalRepositoryPath ($txtLocalRepositoryPath.Text)
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
}
$btnLoadConfig_Click = {
    $Main.dlgFileBrowser.Title='Load config file'
    $Main.dlgFileBrowser.ShowDialog()
    Load-Config -FilePath ($dlgFileBrowser.FileName)    
}
$btnSaveConfig_Click = {
    $Main.dlgSaveFile.Title='Save config to a file'
    $Main.dlgSaveFile.ShowDialog()
    Save-Config -FilePath ($dlgSaveFile.FileName)
}
$btnBrowse_Click = {
    $dlgFolderBrowser.ShowDialog()
    $txtLocalRepositoryPath.Text=$dlgFolderBrowser.SelectedPath
}
function Set-Controls(){
    if ($chkSyncDatabaseModule.Checked -eq $true -or $chkSyncScriptRepository.Checked -eq $true -or $chkCompare.Checked -eq $true){
        $txtConnectionString.Enabled=$true
    } else {
        $txtConnectionString.Enabled=$false
    }
}
function Save-Config(){
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="json settings file path")][string]$FilePath
    )
    begin{}
    process{
        [hashtable]$mySettings=@{
                LocalRepositoryPath=$txtLocalRepositoryPath.Text;
                ConnectionString=$txtConnectionString.Text;
                SqlDeepRepositoryItemsFileName=$txtSqlDeepRepositoryItemFileName.Text;
            }
        $mySettings | ConvertTo-Json | Out-File -FilePath $FilePath
    }
    end{}
}
function Load-Config(){
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="json settings file path")][string]$FilePath
    )
    begin{}
    process{
        $mySettings = Get-Content -Path $FilePath | ConvertFrom-Json
        $txtLocalRepositoryPath.Text=$mySettings.LocalRepositoryPath;
        $txtConnectionString.Text=$mySettings.ConnectionString;
        $txtSqlDeepRepositoryItemFileName.Text=$mySettings.SqlDeepRepositoryItemsFileName;
    }
    end{}
}
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'sqldeepagentgui.designer.ps1')
. (Join-Path $PSScriptRoot 'SqlDeepAgent.psm1')
$Main.ShowDialog()
