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
[System.Windows.Forms.SaveFileDialog]$dlgSaveFile = $null
[System.Windows.Forms.OpenFileDialog]$dlgFileBrowser = $null
[System.Windows.Forms.CheckBox]$chkCompare = $null
[System.Windows.Forms.MenuStrip]$MenuStrip = $null
[System.Windows.Forms.ToolStripMenuItem]$FileToolStripMenuItem = $null
[System.Windows.Forms.ToolStripMenuItem]$mnuLoadConfig = $null
[System.Windows.Forms.ToolStripMenuItem]$mnuSaveConfig = $null
[System.Windows.Forms.ToolStripMenuItem]$mnuExit = $null
[System.Windows.Forms.ToolStripMenuItem]$ToolsToolStripMenuItem = $null
[System.Windows.Forms.ToolStripMenuItem]$mnuCertificate = $null
[System.Windows.Forms.ToolStripMenuItem]$mnuSqlPackage = $null
[System.Windows.Forms.ToolStripMenuItem]$mnuClearConsole = $null
[System.Windows.Forms.StatusStrip]$StatusStrip1 = $null
[System.Windows.Forms.ToolStripStatusLabel]$lblStatus = $null
[System.Windows.Forms.ToolStripStatusLabel]$lblMessage = $null
[System.Windows.Forms.ToolStripStatusLabel]$lblVersion = $null
[System.Windows.Forms.Label]$lblSqlPackage = $null
[System.Windows.Forms.TextBox]$txtSqlPackage = $null
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
$dlgSaveFile = (New-Object -TypeName System.Windows.Forms.SaveFileDialog)
$dlgFileBrowser = (New-Object -TypeName System.Windows.Forms.OpenFileDialog)
$chkCompare = (New-Object -TypeName System.Windows.Forms.CheckBox)
$MenuStrip = (New-Object -TypeName System.Windows.Forms.MenuStrip)
$FileToolStripMenuItem = (New-Object -TypeName System.Windows.Forms.ToolStripMenuItem)
$mnuLoadConfig = (New-Object -TypeName System.Windows.Forms.ToolStripMenuItem)
$mnuSaveConfig = (New-Object -TypeName System.Windows.Forms.ToolStripMenuItem)
$mnuExit = (New-Object -TypeName System.Windows.Forms.ToolStripMenuItem)
$ToolsToolStripMenuItem = (New-Object -TypeName System.Windows.Forms.ToolStripMenuItem)
$mnuCertificate = (New-Object -TypeName System.Windows.Forms.ToolStripMenuItem)
$mnuSqlPackage = (New-Object -TypeName System.Windows.Forms.ToolStripMenuItem)
$mnuClearConsole = (New-Object -TypeName System.Windows.Forms.ToolStripMenuItem)
$StatusStrip1 = (New-Object -TypeName System.Windows.Forms.StatusStrip)
$lblStatus = (New-Object -TypeName System.Windows.Forms.ToolStripStatusLabel)
$lblMessage = (New-Object -TypeName System.Windows.Forms.ToolStripStatusLabel)
$lblVersion = (New-Object -TypeName System.Windows.Forms.ToolStripStatusLabel)
$lblSqlPackage = (New-Object -TypeName System.Windows.Forms.Label)
$txtSqlPackage = (New-Object -TypeName System.Windows.Forms.TextBox)
$MenuStrip.SuspendLayout()
$StatusStrip1.SuspendLayout()
$Main.SuspendLayout()
#
#lblLocalRepositoryPath
#
$lblLocalRepositoryPath.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]35))
$lblLocalRepositoryPath.Name = [System.String]'lblLocalRepositoryPath'
$lblLocalRepositoryPath.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$lblLocalRepositoryPath.TabIndex = [System.Int32]0
$lblLocalRepositoryPath.Text = [System.String]'Local repository folder path:'
#
#txtLocalRepositoryPath
#
$txtLocalRepositoryPath.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]32))
$txtLocalRepositoryPath.Name = [System.String]'txtLocalRepositoryPath'
$txtLocalRepositoryPath.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]347,[System.Int32]21))
$txtLocalRepositoryPath.TabIndex = [System.Int32]1
$txtLocalRepositoryPath.Text = [System.String]'C:\SqlDeepAgent'
#
#lblConnectionString
#
$lblConnectionString.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]114))
$lblConnectionString.Name = [System.String]'lblConnectionString'
$lblConnectionString.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$lblConnectionString.TabIndex = [System.Int32]2
$lblConnectionString.Text = [System.String]'Connection string(s):'
#
#txtConnectionString
#
$txtConnectionString.AcceptsReturn = $true
$txtConnectionString.Enabled = $false
$txtConnectionString.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]114))
$txtConnectionString.Multiline = $true
$txtConnectionString.Name = [System.String]'txtConnectionString'
$txtConnectionString.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
$txtConnectionString.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]381,[System.Int32]161))
$txtConnectionString.TabIndex = [System.Int32]5
$txtConnectionString.Text = [System.String]$resources.'txtConnectionString.Text'
$txtConnectionString.WordWrap = $false
#
#Label1
#
$Label1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]62))
$Label1.Name = [System.String]'Label1'
$Label1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$Label1.TabIndex = [System.Int32]4
$Label1.Text = [System.String]'Repository catalog file name:'
#
#txtSqlDeepRepositoryItemFileName
#
$txtSqlDeepRepositoryItemFileName.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]59))
$txtSqlDeepRepositoryItemFileName.Name = [System.String]'txtSqlDeepRepositoryItemFileName'
$txtSqlDeepRepositoryItemFileName.ReadOnly = $true
$txtSqlDeepRepositoryItemFileName.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]381,[System.Int32]21))
$txtSqlDeepRepositoryItemFileName.TabIndex = [System.Int32]3
$txtSqlDeepRepositoryItemFileName.Text = [System.String]'SqlDeepCatalog.json.result'
#
#chkDownloadAssets
#
$chkDownloadAssets.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]161))
$chkDownloadAssets.Name = [System.String]'chkDownloadAssets'
$chkDownloadAssets.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]24))
$chkDownloadAssets.TabIndex = [System.Int32]6
$chkDownloadAssets.Text = [System.String]'Download Assets'
$chkDownloadAssets.UseVisualStyleBackColor = $true
$chkDownloadAssets.add_CheckedChanged($chkDownloadAssets_CheckedChanged)
#
#chkSyncDatabaseModule
#
$chkSyncDatabaseModule.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]221))
$chkSyncDatabaseModule.Name = [System.String]'chkSyncDatabaseModule'
$chkSyncDatabaseModule.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]24))
$chkSyncDatabaseModule.TabIndex = [System.Int32]8
$chkSyncDatabaseModule.Text = [System.String]'Sync Database Module'
$chkSyncDatabaseModule.UseVisualStyleBackColor = $true
$chkSyncDatabaseModule.add_CheckedChanged($chkSyncDatabaseModule_CheckedChanged)
#
#chkSyncScriptRepository
#
$chkSyncScriptRepository.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]251))
$chkSyncScriptRepository.Name = [System.String]'chkSyncScriptRepository'
$chkSyncScriptRepository.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]24))
$chkSyncScriptRepository.TabIndex = [System.Int32]9
$chkSyncScriptRepository.Text = [System.String]'Sync Script Repository'
$chkSyncScriptRepository.UseVisualStyleBackColor = $true
$chkSyncScriptRepository.add_CheckedChanged($chkSyncScriptRepository_CheckedChanged)
#
#btnSync
#
$btnSync.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]362,[System.Int32]285))
$btnSync.Name = [System.String]'btnSync'
$btnSync.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]95,[System.Int32]23))
$btnSync.TabIndex = [System.Int32]10
$btnSync.Text = [System.String]'&Run'
$btnSync.UseVisualStyleBackColor = $true
$btnSync.add_Click($btnSync_Click)
#
#btnBrowse
#
$btnBrowse.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]529,[System.Int32]30))
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
$btnExit.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]462,[System.Int32]285))
$btnExit.Name = [System.String]'btnExit'
$btnExit.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]95,[System.Int32]23))
$btnExit.TabIndex = [System.Int32]11
$btnExit.Text = [System.String]'E&xit'
$btnExit.UseVisualStyleBackColor = $true
$btnExit.add_Click($btnExit_Click)
#
#dlgSaveFile
#
$dlgSaveFile.DefaultExt = [System.String]'cfg'
$dlgSaveFile.FileName = [System.String]'SqlDeepAgent.cfg'
$dlgSaveFile.Filter = [System.String]'Config files|*.cfg'
$dlgSaveFile.SupportMultiDottedExtensions = $true
#
#dlgFileBrowser
#
$dlgFileBrowser.DefaultExt = [System.String]'cfg'
$dlgFileBrowser.FileName = [System.String]'SqlDeepAgent.cfg'
$dlgFileBrowser.Filter = [System.String]'Config files|*.cfg'
#
#chkCompare
#
$chkCompare.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]191))
$chkCompare.Name = [System.String]'chkCompare'
$chkCompare.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]24))
$chkCompare.TabIndex = [System.Int32]7
$chkCompare.Text = [System.String]'Comparision Report'
$chkCompare.UseVisualStyleBackColor = $true
$chkCompare.add_CheckedChanged($chkCompare_CheckedChanged)
#
#MenuStrip
#
$MenuStrip.Items.AddRange([System.Windows.Forms.ToolStripItem[]]@($FileToolStripMenuItem,$ToolsToolStripMenuItem))
$MenuStrip.LayoutStyle = [System.Windows.Forms.ToolStripLayoutStyle]::HorizontalStackWithOverflow
$MenuStrip.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]0,[System.Int32]0))
$MenuStrip.Name = [System.String]'MenuStrip'
$MenuStrip.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]569,[System.Int32]24))
$MenuStrip.TabIndex = [System.Int32]11
$MenuStrip.Text = [System.String]'MenuStrip1'
#
#FileToolStripMenuItem
#
$FileToolStripMenuItem.DropDownItems.AddRange([System.Windows.Forms.ToolStripItem[]]@($mnuLoadConfig,$mnuSaveConfig,$mnuExit))
$FileToolStripMenuItem.Name = [System.String]'FileToolStripMenuItem'
$FileToolStripMenuItem.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]37,[System.Int32]20))
$FileToolStripMenuItem.Text = [System.String]'&File'
#
#mnuLoadConfig
#
$mnuLoadConfig.Name = [System.String]'mnuLoadConfig'
$mnuLoadConfig.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]149,[System.Int32]22))
$mnuLoadConfig.Text = [System.String]'&Load config ...'
$mnuLoadConfig.add_Click($mnuLoadConfig_Click)
#
#mnuSaveConfig
#
$mnuSaveConfig.Name = [System.String]'mnuSaveConfig'
$mnuSaveConfig.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]149,[System.Int32]22))
$mnuSaveConfig.Text = [System.String]'&Save config ...'
$mnuSaveConfig.add_Click($mnuSaveConfig_Click)
#
#mnuExit
#
$mnuExit.Name = [System.String]'mnuExit'
$mnuExit.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]149,[System.Int32]22))
$mnuExit.Text = [System.String]'E&xit'
$mnuExit.add_Click($mnuExit_Click)
#
#ToolsToolStripMenuItem
#
$ToolsToolStripMenuItem.DropDownItems.AddRange([System.Windows.Forms.ToolStripItem[]]@($mnuCertificate,$mnuSqlPackage,$mnuClearConsole))
$ToolsToolStripMenuItem.Name = [System.String]'ToolsToolStripMenuItem'
$ToolsToolStripMenuItem.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]46,[System.Int32]20))
$ToolsToolStripMenuItem.Text = [System.String]'&Tools'
#
#mnuCertificate
#
$mnuCertificate.Name = [System.String]'mnuCertificate'
$mnuCertificate.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]168,[System.Int32]22))
$mnuCertificate.Text = [System.String]'Install Certificate'
$mnuCertificate.add_Click($mnuCertificate_Click)
#
#mnuSqlPackage
#
$mnuSqlPackage.Name = [System.String]'mnuSqlPackage'
$mnuSqlPackage.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]168,[System.Int32]22))
$mnuSqlPackage.Text = [System.String]'Install SqlPackage'
$mnuSqlPackage.add_Click($mnuSqlPackage_Click)
#
#mnuClearConsole
#
$mnuClearConsole.Name = [System.String]'mnuClearConsole'
$mnuClearConsole.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]168,[System.Int32]22))
$mnuClearConsole.Text = [System.String]'Clear console'
$mnuClearConsole.add_Click($mnuClearConsole_Click)
#
#StatusStrip1
#
$StatusStrip1.Items.AddRange([System.Windows.Forms.ToolStripItem[]]@($lblStatus,$lblMessage,$lblVersion))
$StatusStrip1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]0,[System.Int32]314))
$StatusStrip1.Name = [System.String]'StatusStrip1'
$StatusStrip1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]569,[System.Int32]22))
$StatusStrip1.SizingGrip = $false
$StatusStrip1.TabIndex = [System.Int32]15
$StatusStrip1.Text = [System.String]'StatusStrip1'
#
#lblStatus
#
$lblStatus.Name = [System.String]'lblStatus'
$lblStatus.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]0,[System.Int32]17))
#
#lblMessage
#
$lblMessage.ForeColor = [System.Drawing.Color]::Navy
$lblMessage.Name = [System.String]'lblMessage'
$lblMessage.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]516,[System.Int32]17))
$lblMessage.Spring = $true
$lblMessage.Text = [System.String]'You can comment connection string(s) by adding -- in front of each line.'
#
#lblVersion
#
$lblVersion.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Text
$lblVersion.Name = [System.String]'lblVersion'
$lblVersion.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]38,[System.Int32]17))
$lblVersion.Text = [System.String]'V1.0.5'
#
#lblSqlPackage
#
$lblSqlPackage.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]87))
$lblSqlPackage.Name = [System.String]'lblSqlPackage'
$lblSqlPackage.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$lblSqlPackage.TabIndex = [System.Int32]16
$lblSqlPackage.Text = [System.String]'SqlPackage.exe path (opt):'
#
#txtSqlPackage
#
$txtSqlPackage.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]84))
$txtSqlPackage.Name = [System.String]'txtSqlPackage'
$txtSqlPackage.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]381,[System.Int32]21))
$txtSqlPackage.TabIndex = [System.Int32]4
#
#Main
#
$Main.AcceptButton = $btnSync
$Main.CancelButton = $btnExit
$Main.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]569,[System.Int32]336))
$Main.Controls.Add($txtSqlPackage)
$Main.Controls.Add($lblSqlPackage)
$Main.Controls.Add($StatusStrip1)
$Main.Controls.Add($chkCompare)
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
$Main.Controls.Add($MenuStrip)
$Main.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Main.Icon = ([System.Drawing.Icon]$resources.'$this.Icon')
$Main.MainMenuStrip = $MenuStrip
$Main.MaximizeBox = $false
$Main.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Main.Text = [System.String]'SqlDeep Synchronizer Agent'
$MenuStrip.ResumeLayout($false)
$MenuStrip.PerformLayout()
$StatusStrip1.ResumeLayout($false)
$StatusStrip1.PerformLayout()
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
Add-Member -InputObject $Main -Name dlgSaveFile -Value $dlgSaveFile -MemberType NoteProperty
Add-Member -InputObject $Main -Name dlgFileBrowser -Value $dlgFileBrowser -MemberType NoteProperty
Add-Member -InputObject $Main -Name chkCompare -Value $chkCompare -MemberType NoteProperty
Add-Member -InputObject $Main -Name MenuStrip -Value $MenuStrip -MemberType NoteProperty
Add-Member -InputObject $Main -Name FileToolStripMenuItem -Value $FileToolStripMenuItem -MemberType NoteProperty
Add-Member -InputObject $Main -Name mnuLoadConfig -Value $mnuLoadConfig -MemberType NoteProperty
Add-Member -InputObject $Main -Name mnuSaveConfig -Value $mnuSaveConfig -MemberType NoteProperty
Add-Member -InputObject $Main -Name mnuExit -Value $mnuExit -MemberType NoteProperty
Add-Member -InputObject $Main -Name ToolsToolStripMenuItem -Value $ToolsToolStripMenuItem -MemberType NoteProperty
Add-Member -InputObject $Main -Name mnuCertificate -Value $mnuCertificate -MemberType NoteProperty
Add-Member -InputObject $Main -Name mnuSqlPackage -Value $mnuSqlPackage -MemberType NoteProperty
Add-Member -InputObject $Main -Name mnuClearConsole -Value $mnuClearConsole -MemberType NoteProperty
Add-Member -InputObject $Main -Name StatusStrip1 -Value $StatusStrip1 -MemberType NoteProperty
Add-Member -InputObject $Main -Name lblStatus -Value $lblStatus -MemberType NoteProperty
Add-Member -InputObject $Main -Name lblMessage -Value $lblMessage -MemberType NoteProperty
Add-Member -InputObject $Main -Name lblVersion -Value $lblVersion -MemberType NoteProperty
Add-Member -InputObject $Main -Name lblSqlPackage -Value $lblSqlPackage -MemberType NoteProperty
Add-Member -InputObject $Main -Name txtSqlPackage -Value $txtSqlPackage -MemberType NoteProperty
}
. InitializeComponent
