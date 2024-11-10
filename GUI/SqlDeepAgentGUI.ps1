$chkDownloadAssets_CheckedChanged = {
}
$chkSyncScriptRepository_CheckedChanged = {
    Set-Controls
}
$chkSyncDatabaseModule_CheckedChanged = {
    Set-Controls
}

$btnSync_Click = {
    $Main.Cursor=[System.Windows.Forms.Cursors]::WaitCursor
    if ($chkDownloadAssets.Checked){
        #. (Join-Path $PSScriptRoot 'SqlDeepAgent.ps1') -DownloadAssets -LocalRepositoryPath ($txtLocalRepositoryPath.Text)
        Sync-SqlDeep -DownloadAssets -LocalRepositoryPath ($txtLocalRepositoryPath.Text)
    }
    if ($chkSyncDatabaseModule.Checked){
        #. (Join-Path $PSScriptRoot 'SqlDeepAgent.ps1') -SyncDatabaseModule -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
        Sync-SqlDeep -SyncDatabaseModule -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
    }
    if ($chkSyncScriptRepository.Checked){
        #. (Join-Path $PSScriptRoot 'SqlDeepAgent.ps1') -SyncScriptRepository -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
        Sync-SqlDeep  -SyncScriptRepository -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
    }
    $Main.Cursor=[System.Windows.Forms.Cursors]::Default
}

$btnBrowse_Click = {
    $dlgFolderBrowser.ShowDialog()
    $txtLocalRepositoryPath.Text=$dlgFolderBrowser.SelectedPath
}

function Set-Controls(){
    if ($chkSyncDatabaseModule.Checked -eq $true -or $chkSyncScriptRepository.Checked -eq $true){
        $txtConnectionString.Enabled=$true
        $txtSqlDeepRepositoryItemFileName.Enabled=$true
    } else {
        $txtConnectionString.Enabled=$false
        $txtSqlDeepRepositoryItemFileName.Enabled=$false
    }
}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'sqldeepagentgui.designer.ps1')
. (Join-Path ($PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf('\'))+'\CLI\') 'SqlDeepAgent.psm1')
$Main.ShowDialog()
