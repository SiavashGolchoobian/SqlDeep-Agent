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
$txtLocalRepositoryPath.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]294,[System.Int32]21))
$txtLocalRepositoryPath.TabIndex = [System.Int32]1
$txtLocalRepositoryPath.Text = [System.String]'C:\SqlDeep'
#
#lblConnectionString
#
$lblConnectionString.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]37))
$lblConnectionString.Name = [System.String]'lblConnectionString'
$lblConnectionString.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$lblConnectionString.TabIndex = [System.Int32]2
$lblConnectionString.Text = [System.String]'Connection string:'
#
#txtConnectionString
#
$txtConnectionString.Enabled = $false
$txtConnectionString.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]34))
$txtConnectionString.Name = [System.String]'txtConnectionString'
$txtConnectionString.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]294,[System.Int32]21))
$txtConnectionString.TabIndex = [System.Int32]3
$txtConnectionString.Text = [System.String]'Data Source=localhost;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=P@$$W0rd'
#
#Label1
#
$Label1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]69))
$Label1.Name = [System.String]'Label1'
$Label1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]158,[System.Int32]23))
$Label1.TabIndex = [System.Int32]4
$Label1.Text = [System.String]'Repository catalog file name:'
#
#txtSqlDeepRepositoryItemFileName
#
$txtSqlDeepRepositoryItemFileName.Enabled = $false
$txtSqlDeepRepositoryItemFileName.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]176,[System.Int32]66))
$txtSqlDeepRepositoryItemFileName.Name = [System.String]'txtSqlDeepRepositoryItemFileName'
$txtSqlDeepRepositoryItemFileName.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]294,[System.Int32]21))
$txtSqlDeepRepositoryItemFileName.TabIndex = [System.Int32]4
$txtSqlDeepRepositoryItemFileName.Text = [System.String]'SqlDeepCatalog.json.result'
#
#chkDownloadAssets
#
$chkDownloadAssets.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]95))
$chkDownloadAssets.Name = [System.String]'chkDownloadAssets'
$chkDownloadAssets.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]458,[System.Int32]24))
$chkDownloadAssets.TabIndex = [System.Int32]5
$chkDownloadAssets.Text = [System.String]'Download Assets'
$chkDownloadAssets.UseVisualStyleBackColor = $true
$chkDownloadAssets.add_CheckedChanged($chkDownloadAssets_CheckedChanged)
#
#chkSyncDatabaseModule
#
$chkSyncDatabaseModule.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]125))
$chkSyncDatabaseModule.Name = [System.String]'chkSyncDatabaseModule'
$chkSyncDatabaseModule.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]458,[System.Int32]24))
$chkSyncDatabaseModule.TabIndex = [System.Int32]6
$chkSyncDatabaseModule.Text = [System.String]'Sync Database Module'
$chkSyncDatabaseModule.UseVisualStyleBackColor = $true
$chkSyncDatabaseModule.add_CheckedChanged($chkSyncDatabaseModule_CheckedChanged)
#
#chkSyncScriptRepository
#
$chkSyncScriptRepository.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]155))
$chkSyncScriptRepository.Name = [System.String]'chkSyncScriptRepository'
$chkSyncScriptRepository.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]458,[System.Int32]24))
$chkSyncScriptRepository.TabIndex = [System.Int32]7
$chkSyncScriptRepository.Text = [System.String]'Sync Script Repository'
$chkSyncScriptRepository.UseVisualStyleBackColor = $true
$chkSyncScriptRepository.add_CheckedChanged($chkSyncScriptRepository_CheckedChanged)
#
#btnSync
#
$btnSync.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]196))
$btnSync.Name = [System.String]'btnSync'
$btnSync.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]23))
$btnSync.TabIndex = [System.Int32]8
$btnSync.Text = [System.String]'&Synchronize'
$btnSync.UseVisualStyleBackColor = $true
$btnSync.add_Click($btnSync_Click)
#
#btnBrowse
#
$btnBrowse.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]476,[System.Int32]6))
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
$btnExit.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]424,[System.Int32]196))
$btnExit.Name = [System.String]'btnExit'
$btnExit.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]23))
$btnExit.TabIndex = [System.Int32]9
$btnExit.Text = [System.String]'E&xit'
$btnExit.UseVisualStyleBackColor = $true
#
#Main
#
$Main.AcceptButton = $btnSync
$Main.CancelButton = $btnExit
$Main.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]511,[System.Int32]231))
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
$Main.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
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
}
. InitializeComponent
