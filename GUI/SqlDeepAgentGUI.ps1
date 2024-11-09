$chkDownloadAssets_CheckedChanged = {
}
$chkSyncScriptRepository_CheckedChanged = {
    Check-Controls
}
$chkSyncDatabaseModule_CheckedChanged = {
    Check-Controls
}

$btnSync_Click = {
    Write-Host $PSScriptRoot
    if ($chkDownloadAssets.Checked){
        . $PSScriptRoot\..\SqlDeepAgent.ps1 -DownloadAssets -LocalRepositoryPath ($txtLocalRepositoryPath.Text)
    }
    if ($chkSyncDatabaseModule.Checked){
        . $PSScriptRoot\..\SqlDeepAgent.ps1 -SyncDatabaseModule -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
    }
    if ($chkSyncScriptRepository.Checked){
        . $PSScriptRoot\..\SqlDeepAgent.ps1 -SyncScriptRepository -LocalRepositoryPath ($txtLocalRepositoryPath.Text) -SqlDeepRepositoryItemsFileName ($txtSqlDeepRepositoryItemFileName.Text) -ConnectionString ($txtConnectionString.Text)
    }
}

$btnBrowse_Click = {
    $dlgFolderBrowser.ShowDialog()
    $txtLocalRepositoryPath.Text=$dlgFolderBrowser.SelectedPath
}

function Check-Controls(){
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
$Main.ShowDialog()
