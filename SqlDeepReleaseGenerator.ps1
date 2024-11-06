Using module 'C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-PowershellTools\SqlDeepDatabasePublisher.psm1'

$myCertificate = (Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object -Property Subject -eq 'CN=sqldeep.com'); 
[string]$SqlDeepDbConnectionString2017='Data Source=172.18.3.49,2017;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=P@$$W0rd'
[string]$SqlDeepDbConnectionString2019='Data Source=172.18.3.49,2019;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=P@$$W0rd'
[string]$SqlDeepDbConnectionString2022='Data Source=172.18.3.49,2022;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=P@$$W0rd'
[string]$SqlDeepDbDockerHostHomePath= '/home/siavash/sqldeep/'
[string]$SqlDeepDbDockerContainerPath2017= '/var/opt/mssql/2017/backup/sqldeep'
[string]$SqlDeepDbDockerContainerPath2019= '/var/opt/mssql/2019/backup/sqldeep'
[string]$SqlDeepDbDockerContainerPath2022= '/var/opt/mssql/2022/backup/sqldeep'
[string]$SqlDeepProjectReleasePath='D:\Siavash\TFS\sqldeep\Assets\Release\Latest'
[string]$SqlDeepPowershellToolsProjectPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-PowershellTools\'
[string]$SqlDeepSynchronizerProjectPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\'
[string]$SqlDeepAssetBashScriptPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\Assets\Bash\'

#-----Sign file(s)
Write-Host 'Sign file(s)'
$mySqlDeepPowershellToolsFiles=Get-ChildItem -Path $SqlDeepPowershellToolsProjectPath -Recurse | Where-Object {$_.Extension.ToUpper() -in ('.PSM1','.PS1') -and $_.Name.ToUpper() -notlike '*SAMPLE*'}
$mySqlDeepSynchronizerFiles=Get-ChildItem -Path $SqlDeepSynchronizerProjectPath -Recurse | Where-Object {$_.Extension.ToUpper() -in ('.PSM1','.PS1') -and $_.Name.ToUpper() -notlike '*SAMPLE*'}
$myPowershellFiles=$mySqlDeepPowershellToolsFiles+$mySqlDeepSynchronizerFiles
foreach ($myFile in $myPowershellFiles) {
    if ((Get-AuthenticodeSignature -FilePath ($myFile.FullName)).Status -eq 'HashMismatch'){
        Set-AuthenticodeSignature -FilePath  ($myFile.FullName) -Certificate $myCertificate -IncludeChain All -TimeStampServer http://timestamp.digicert.com
    }
}

#-----Create dac pac file
Write-Host 'Create dac pac file'
$mySqlPackageFilePath=Find-SqlPackageLocation
$mySqlPackageFolderPath=(Get-Item -Path $mySqlPackageFilePath).DirectoryName
$mySqlPackageFolderPath=Clear-FolderPath -FolderPath $mySqlPackageFolderPath
if (-not ($env:Path).Contains($mySqlPackageFolderPath)) {$env:path = $env:path + ';'+$mySqlPackageFolderPath+';'}
Write-Host 'Export Source Database dacpac'
Export-DatabaseDacPac -ConnectionString $SqlDeepDbConnectionString2019 -DacpacFilePath ($SqlDeepProjectReleasePath+'\SqlDeep.dacpac')

#-----Sync dac pack file with other SqlDeep Versions
Write-Host 'Sync dac pack file with other SqlDeep Versions'
Publish-DatabaseDacPac -ConnectionString $SqlDeepDbConnectionString2017 -DacpacFilePath ($SqlDeepProjectReleasePath+'\SqlDeep.dacpac')
Publish-DatabaseDacPac -ConnectionString $SqlDeepDbConnectionString2022 -DacpacFilePath ($SqlDeepProjectReleasePath+'\SqlDeep.dacpac')

#-----Upload file(s) to sqldeep refrence(s) databases
Write-Host 'Backup sqldeep database'
[string]$myQuery="USE [master]; BACKUP DATABASE [SqlDeep] TO DISK=N'/var/opt/mssql/backup/sqldeep/SqlDeep{version}.bak' WITH NOFORMAT, INIT,  NAME = N'SqlDeep-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, CHECKSUM"
Invoke-Sqlcmd -ConnectionString $SqlDeepDbConnectionString2017 -Query ($myQuery.Replace('{version}','2017'))
Invoke-Sqlcmd -ConnectionString $SqlDeepDbConnectionString2019 -Query ($myQuery.Replace('{version}','2019'))
Invoke-Sqlcmd -ConnectionString $SqlDeepDbConnectionString2022 -Query ($myQuery.Replace('{version}','2022'))

#-----Generate download bash script file
Write-Host 'Generate download bash script file'
[string]$myBashCommand=''
$myBashCommand+='#!/bin/sh'+"`n"
$myBashCommand+='rm ' + $SqlDeepDbDockerHostHomePath + 'SqlDeep2017.bak' +"`n"
$myBashCommand+='rm ' + $SqlDeepDbDockerHostHomePath + 'SqlDeep2019.bak' +"`n"
$myBashCommand+='rm ' + $SqlDeepDbDockerHostHomePath + 'SqlDeep2022.bak' +"`n"
$myBashCommand+='sudo chown -R siavash ' + $SqlDeepDbDockerContainerPath2017 + '/SqlDeep2017.bak' +"`n"
$myBashCommand+='sudo chown -R siavash ' + $SqlDeepDbDockerContainerPath2019 + '/SqlDeep2019.bak' +"`n"
$myBashCommand+='sudo chown -R siavash ' + $SqlDeepDbDockerContainerPath2022 + '/SqlDeep2022.bak' +"`n"
$myBashCommand+='cp ' + $SqlDeepDbDockerContainerPath2017 + '/SqlDeep2017.bak ' + $SqlDeepDbDockerHostHomePath +"`n"
$myBashCommand+='cp ' + $SqlDeepDbDockerContainerPath2019 + '/SqlDeep2019.bak ' + $SqlDeepDbDockerHostHomePath +"`n"
$myBashCommand+='cp ' + $SqlDeepDbDockerContainerPath2022 + '/SqlDeep2022.bak ' + $SqlDeepDbDockerHostHomePath +"`n"
$myBashCommand+='sudo rm ' + $SqlDeepDbDockerContainerPath2017 + '/SqlDeep2017.bak ' +"`n"
$myBashCommand+='sudo rm ' + $SqlDeepDbDockerContainerPath2019 + '/SqlDeep2019.bak ' +"`n"
$myBashCommand+='sudo rm ' + $SqlDeepDbDockerContainerPath2022 + '/SqlDeep2022.bak ' +"`n"

New-Item -Path $SqlDeepAssetBashScriptPath -Name 'sqldeepdownload' -Value $myBashCommand -Force -ItemType File
scp.exe ($SqlDeepAssetBashScriptPath+'sqldeepdownload') siavash@172.18.3.49:$SqlDeepDbDockerHostHomePath

#-----Copy files from sql docker containers folder(s) to docker host home
Write-Host 'Copy files from sql docker containers folder(s) to docker host home'
[string]$myCommand='bash '+$SqlDeepDbDockerHostHomePath+'sqldeepdownload'
Write-Host ('Execute this command in a WSL session and then press any key to continue: ' + $myCommand)
Read-Host 'Press any key after executing above command...'

#-----Download backup file(s) from docker host
Write-Host 'Download backup file(s) from docker host'
$myLinuxPath2017=($SqlDeepDbDockerHostHomePath+'SqlDeep2017.bak')
$myLinuxPath2019=($SqlDeepDbDockerHostHomePath+'SqlDeep2019.bak')
$myLinuxPath2022=($SqlDeepDbDockerHostHomePath+'SqlDeep2022.bak')
$myLocalPath2017=$SqlDeepProjectReleasePath+'\SqlDeep2017.bak'
$myLocalPath2019=$SqlDeepProjectReleasePath+'\SqlDeep2019.bak'
$myLocalPath2022=$SqlDeepProjectReleasePath+'\SqlDeep2022.bak'
scp.exe siavash@172.18.3.49:$myLinuxPath2017 $myLocalPath2017
scp.exe siavash@172.18.3.49:$myLinuxPath2019 $myLocalPath2019
scp.exe siavash@172.18.3.49:$myLinuxPath2022 $myLocalPath2022
