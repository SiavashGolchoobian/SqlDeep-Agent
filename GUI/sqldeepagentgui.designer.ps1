$Main = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Label]$lblLocalRepositoryPath = $null
[System.Windows.Forms.TextBox]$txtLocalRepositoryPath = $null
[System.Windows.Forms.Label]$lblConnectionString = $null
[System.Windows.Forms.TextBox]$txtConnectionString = $null
[System.Windows.Forms.Label]$Label1 = $null
[System.Windows.Forms.TextBox]$txtSqlDeepRepositoryItemFileName = $null
[System.Windows.Forms.CheckBox]$chkDownloadAssets = $null
[System.Windows.Forms.CheckBox]$chkSyncDatabaseModule = $null
[System.Windows.Forms.CheckBox]$chkSyncScriptRepository = $null
[System.Windows.Forms.Button]$btnSync = $null
[System.Windows.Forms.Button]$btnBrowse = $null
[System.Windows.Forms.FolderBrowserDialog]$dlgFolderBrowser = $null
[System.Windows.Forms.Button]$btnExit = $null
[System.Windows.Forms.Button]$btnSaveConfig = $null
[System.Windows.Forms.Button]$btnLoadConfig = $null
[System.Windows.Forms.SaveFileDialog]$dlgSaveFile = $null
[System.Windows.Forms.OpenFileDialog]$dlgFileBrowser = $null
[System.Windows.Forms.CheckBox]$chkCompare = $null
[System.Windows.Forms.Label]$lblMessage = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'sqldeepagentgui.resources.ps1')
$lblLocalRepositoryPath = (New-Object -TypeName System.Windows.Forms.Label)
$txtLocalRepositoryPath = (New-Object -TypeName System.Windows.Forms.TextBox)
$lblConnectionString = (New-Object -TypeName System.Windows.Forms.Label)
$txtConnectionString = (New-Object -TypeName System.Windows.Forms.TextBox)
$Label1 = (New-Object -TypeName System.Windows.Forms.Label)
$txtSqlDeepRepositoryItemFileName = (New-Object -TypeName System.Windows.Forms.TextBox)
$chkDownloadAssets = (New-Object -TypeName System.Windows.Forms.CheckBox)
$chkSyncDatabaseModule = (New-Object -TypeName System.Windows.Forms.CheckBox)
$chkSyncScriptRepository = (New-Object -TypeName System.Windows.Forms.CheckBox)
$btnSync = (New-Object -TypeName System.Windows.Forms.Button)
$btnBrowse = (New-Object -TypeName System.Windows.Forms.Button)
$dlgFolderBrowser = (New-Object -TypeName System.Windows.Forms.FolderBrowserDialog)
$btnExit = (New-Object -TypeName System.Windows.Forms.Button)
$btnSaveConfig = (New-Object -TypeName System.Windows.Forms.Button)
$btnLoadConfig = (New-Object -TypeName System.Windows.Forms.Button)
$dlgSaveFile = (New-Object -TypeName System.Windows.Forms.SaveFileDialog)
$dlgFileBrowser = (New-Object -TypeName System.Windows.Forms.OpenFileDialog)
$chkCompare = (New-Object -TypeName System.Windows.Forms.CheckBox)
$lblMessage = (New-Object -TypeName System.Windows.Forms.Label)
$Main.SuspendLayout()
#
#lblLocalRepositoryPath
#
$lblLocalRepositoryPath.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]9))
$lblLocalRepositoryPath.Name = [System.String]'lblLocalRepositoryPath'
$lblLocalRepositoryPath.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$lblLocalRepositoryPath.TabIndex = [System.Int32]0
$lblLocalRepositoryPath.Text = [System.String]'Local repository folder path:'
#
#txtLocalRepositoryPath
#
$txtLocalRepositoryPath.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]6))
$txtLocalRepositoryPath.Name = [System.String]'txtLocalRepositoryPath'
$txtLocalRepositoryPath.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]347,[System.Int32]21))
$txtLocalRepositoryPath.TabIndex = [System.Int32]1
$txtLocalRepositoryPath.Text = [System.String]'C:\SqlDeep'
#
#lblConnectionString
#
$lblConnectionString.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]63))
$lblConnectionString.Name = [System.String]'lblConnectionString'
$lblConnectionString.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$lblConnectionString.TabIndex = [System.Int32]2
$lblConnectionString.Text = [System.String]'Connection string(s):'
#
#txtConnectionString
#
$txtConnectionString.AcceptsReturn = $true
$txtConnectionString.Enabled = $false
$txtConnectionString.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]60))
$txtConnectionString.Multiline = $true
$txtConnectionString.Name = [System.String]'txtConnectionString'
$txtConnectionString.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
$txtConnectionString.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]381,[System.Int32]104))
$txtConnectionString.TabIndex = [System.Int32]3
$txtConnectionString.Text = [System.String]$resources.'txtConnectionString.Text'
$txtConnectionString.WordWrap = $false
#
#Label1
#
$Label1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]36))
$Label1.Name = [System.String]'Label1'
$Label1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$Label1.TabIndex = [System.Int32]4
$Label1.Text = [System.String]'Repository catalog file name:'
#
#txtSqlDeepRepositoryItemFileName
#
$txtSqlDeepRepositoryItemFileName.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]33))
$txtSqlDeepRepositoryItemFileName.Name = [System.String]'txtSqlDeepRepositoryItemFileName'
$txtSqlDeepRepositoryItemFileName.ReadOnly = $true
$txtSqlDeepRepositoryItemFileName.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]381,[System.Int32]21))
$txtSqlDeepRepositoryItemFileName.TabIndex = [System.Int32]4
$txtSqlDeepRepositoryItemFileName.Text = [System.String]'SqlDeepCatalog.json.result'
#
#chkDownloadAssets
#
$chkDownloadAssets.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]162))
$chkDownloadAssets.Name = [System.String]'chkDownloadAssets'
$chkDownloadAssets.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]127,[System.Int32]24))
$chkDownloadAssets.TabIndex = [System.Int32]5
$chkDownloadAssets.Text = [System.String]'Download Assets'
$chkDownloadAssets.UseVisualStyleBackColor = $true
$chkDownloadAssets.add_CheckedChanged($chkDownloadAssets_CheckedChanged)
#
#chkSyncDatabaseModule
#
$chkSyncDatabaseModule.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]222))
$chkSyncDatabaseModule.Name = [System.String]'chkSyncDatabaseModule'
$chkSyncDatabaseModule.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]24))
$chkSyncDatabaseModule.TabIndex = [System.Int32]7
$chkSyncDatabaseModule.Text = [System.String]'Sync Database Module'
$chkSyncDatabaseModule.UseVisualStyleBackColor = $true
$chkSyncDatabaseModule.add_CheckedChanged($chkSyncDatabaseModule_CheckedChanged)
#
#chkSyncScriptRepository
#
$chkSyncScriptRepository.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]252))
$chkSyncScriptRepository.Name = [System.String]'chkSyncScriptRepository'
$chkSyncScriptRepository.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]24))
$chkSyncScriptRepository.TabIndex = [System.Int32]8
$chkSyncScriptRepository.Text = [System.String]'Sync Script Repository'
$chkSyncScriptRepository.UseVisualStyleBackColor = $true
$chkSyncScriptRepository.add_CheckedChanged($chkSyncScriptRepository_CheckedChanged)
#
#btnSync
#
$btnSync.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]290))
$btnSync.Name = [System.String]'btnSync'
$btnSync.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]95,[System.Int32]23))
$btnSync.TabIndex = [System.Int32]9
$btnSync.Text = [System.String]'S&ynchronize'
$btnSync.UseVisualStyleBackColor = $true
$btnSync.add_Click($btnSync_Click)
#
#btnBrowse
#
$btnBrowse.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]529,[System.Int32]4))
$btnBrowse.Name = [System.String]'btnBrowse'
$btnBrowse.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]28,[System.Int32]23))
$btnBrowse.TabIndex = [System.Int32]2
$btnBrowse.Text = [System.String]'...'
$btnBrowse.UseVisualStyleBackColor = $true
$btnBrowse.add_Click($btnBrowse_Click)
#
#dlgFolderBrowser
#
$dlgFolderBrowser.RootFolder = [System.Environment+SpecialFolder]::MyComputer
#
#btnExit
#
$btnExit.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$btnExit.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]462,[System.Int32]290))
$btnExit.Name = [System.String]'btnExit'
$btnExit.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]95,[System.Int32]23))
$btnExit.TabIndex = [System.Int32]12
$btnExit.Text = [System.String]'E&xit'
$btnExit.UseVisualStyleBackColor = $true
#
#btnSaveConfig
#
$btnSaveConfig.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]113,[System.Int32]290))
$btnSaveConfig.Name = [System.String]'btnSaveConfig'
$btnSaveConfig.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]95,[System.Int32]23))
$btnSaveConfig.TabIndex = [System.Int32]10
$btnSaveConfig.Text = [System.String]'&Save config ...'
$btnSaveConfig.UseVisualStyleBackColor = $true
$btnSaveConfig.add_Click($btnSaveConfig_Click)
#
#btnLoadConfig
#
$btnLoadConfig.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]214,[System.Int32]290))
$btnLoadConfig.Name = [System.String]'btnLoadConfig'
$btnLoadConfig.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]95,[System.Int32]23))
$btnLoadConfig.TabIndex = [System.Int32]11
$btnLoadConfig.Text = [System.String]'&Load config...'
$btnLoadConfig.UseVisualStyleBackColor = $true
$btnLoadConfig.add_Click($btnLoadConfig_Click)
#
#dlgSaveFile
#
$dlgSaveFile.DefaultExt = [System.String]'cfg'
$dlgSaveFile.FileName = [System.String]'SqlDeep.cfg'
$dlgSaveFile.Filter = [System.String]'Config files|*.cfg'
$dlgSaveFile.SupportMultiDottedExtensions = $true
#
#dlgFileBrowser
#
$dlgFileBrowser.DefaultExt = [System.String]'cfg'
$dlgFileBrowser.FileName = [System.String]'SqlDeep.cfg'
$dlgFileBrowser.Filter = [System.String]'Config files|*.cfg'
#
#chkCompare
#
$chkCompare.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]192))
$chkCompare.Name = [System.String]'chkCompare'
$chkCompare.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]164,[System.Int32]24))
$chkCompare.TabIndex = [System.Int32]6
$chkCompare.Text = [System.String]'Comparision Report'
$chkCompare.UseVisualStyleBackColor = $true
$chkCompare.add_CheckedChanged($chkCompare_CheckedChanged)
#
#lblMessage
#
$lblMessage.ForeColor = [System.Drawing.Color]::Navy
$lblMessage.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]167))
$lblMessage.Name = [System.String]'lblMessage'
$lblMessage.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]381,[System.Int32]113))
$lblMessage.TabIndex = [System.Int32]13
$lblMessage.Text = [System.String]'You can comment connection string(s) by adding -- in front of each line.'
$lblMessage.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
#
#Main
#
$Main.AcceptButton = $btnSync
$Main.CancelButton = $btnExit
$Main.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]569,[System.Int32]321))
$Main.Controls.Add($lblMessage)
$Main.Controls.Add($chkCompare)
$Main.Controls.Add($btnLoadConfig)
$Main.Controls.Add($btnSaveConfig)
$Main.Controls.Add($btnExit)
$Main.Controls.Add($btnBrowse)
$Main.Controls.Add($btnSync)
$Main.Controls.Add($chkSyncScriptRepository)
$Main.Controls.Add($chkSyncDatabaseModule)
$Main.Controls.Add($chkDownloadAssets)
$Main.Controls.Add($txtSqlDeepRepositoryItemFileName)
$Main.Controls.Add($Label1)
$Main.Controls.Add($txtConnectionString)
$Main.Controls.Add($lblConnectionString)
$Main.Controls.Add($txtLocalRepositoryPath)
$Main.Controls.Add($lblLocalRepositoryPath)
$Main.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Main.Icon = ([System.Drawing.Icon]$resources.'$this.Icon')
$Main.MaximizeBox = $false
$Main.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Main.Text = [System.String]'SqlDeep Synchronizer'
$Main.ResumeLayout($false)
$Main.PerformLayout()
Add-Member -InputObject $Main -Name lblLocalRepositoryPath -Value $lblLocalRepositoryPath -MemberType NoteProperty
Add-Member -InputObject $Main -Name txtLocalRepositoryPath -Value $txtLocalRepositoryPath -MemberType NoteProperty
Add-Member -InputObject $Main -Name lblConnectionString -Value $lblConnectionString -MemberType NoteProperty
Add-Member -InputObject $Main -Name txtConnectionString -Value $txtConnectionString -MemberType NoteProperty
Add-Member -InputObject $Main -Name Label1 -Value $Label1 -MemberType NoteProperty
Add-Member -InputObject $Main -Name txtSqlDeepRepositoryItemFileName -Value $txtSqlDeepRepositoryItemFileName -MemberType NoteProperty
Add-Member -InputObject $Main -Name chkDownloadAssets -Value $chkDownloadAssets -MemberType NoteProperty
Add-Member -InputObject $Main -Name chkSyncDatabaseModule -Value $chkSyncDatabaseModule -MemberType NoteProperty
Add-Member -InputObject $Main -Name chkSyncScriptRepository -Value $chkSyncScriptRepository -MemberType NoteProperty
Add-Member -InputObject $Main -Name btnSync -Value $btnSync -MemberType NoteProperty
Add-Member -InputObject $Main -Name btnBrowse -Value $btnBrowse -MemberType NoteProperty
Add-Member -InputObject $Main -Name dlgFolderBrowser -Value $dlgFolderBrowser -MemberType NoteProperty
Add-Member -InputObject $Main -Name btnExit -Value $btnExit -MemberType NoteProperty
Add-Member -InputObject $Main -Name btnSaveConfig -Value $btnSaveConfig -MemberType NoteProperty
Add-Member -InputObject $Main -Name btnLoadConfig -Value $btnLoadConfig -MemberType NoteProperty
Add-Member -InputObject $Main -Name dlgSaveFile -Value $dlgSaveFile -MemberType NoteProperty
Add-Member -InputObject $Main -Name dlgFileBrowser -Value $dlgFileBrowser -MemberType NoteProperty
Add-Member -InputObject $Main -Name chkCompare -Value $chkCompare -MemberType NoteProperty
Add-Member -InputObject $Main -Name lblMessage -Value $lblMessage -MemberType NoteProperty
}
. InitializeComponent
