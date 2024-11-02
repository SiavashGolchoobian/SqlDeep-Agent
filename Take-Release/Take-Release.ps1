Using module 'C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Database-Shipping\SqlDeepSync.psm1'

$myFileList=@{};
$myCertificate = (Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object -Property Subject -eq 'CN=sqldeep.com'); 
[string]$SqlDeepDbConnectionString2017='Data Source=172.18.3.49,2017;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=Armin1355$'
[string]$SqlDeepDbConnectionString2019='Data Source=172.18.3.49,2019;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=Armin1355$'
[string]$SqlDeepDbConnectionString2022='Data Source=172.18.3.49,2022;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=Armin1355$'
[string]$SqlDeepDbDockerHostHomePath= '/home/siavash/sqldeep/'
[string]$SqlDeepDbDockerContainerPath2017= '/var/opt/mssql/2017/backup/sqldeep'
[string]$SqlDeepDbDockerContainerPath2019= '/var/opt/mssql/2019/backup/sqldeep'
[string]$SqlDeepDbDockerContainerPath2022= '/var/opt/mssql/2022/backup/sqldeep'
[string]$SqlDeepPowershellToolsPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Database-Shipping\'
[string]$SqlDeepAssetBashScriptPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\Take-Release\Assets\Bash\'
[string]$SqlDeepAssetPowershellScriptPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\Take-Release\Assets\Powershell\'
[string]$SqlDeepAssetTsqlScriptPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\Take-Release\Assets\TSQL\'
[string]$SqlDeepProjectPath='D:\Siavash\TFS\sqldeep\'
[string]$SqlDeepProjectDacpacFilePath=$SqlDeepProjectPath+'Assets\Release\Latest\SqlDeep.dacpac'

$myFileList['SqlDeepTemplate_ScriptRepositoryJob.sql']=[PSCustomObject]@{ItemType='TSQL';Tags='TSX';ItemName='';FilePath=$SqlDeepAssetTsqlScriptPath;ItemVersion='1.0';Description='Powershell Repository Job, Replace VAR_JOBNAME and VAR_REPOSITORYITEMNAME phrases with yours.'}
$myFileList['HelloWorld.ps1']=                  [PSCustomObject]@{ItemType='POWERSHELL';Tags='TSX';ItemName='';FilePath=$SqlDeepAssetPowershellScriptPath;ItemVersion='1.0';Description='Implement Sample Powershell Script'}
$myFileList['SqlDeepOsUserAudit.ps1']=          [PSCustomObject]@{ItemType='POWERSHELL';Tags='TSX';ItemName='';FilePath=$SqlDeepAssetPowershellScriptPath;ItemVersion='1.0';Description='Implement OS logins audit'}
$myFileList['SqlDeepAudit.psm1']=               [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Find Unusall SQL Admin or OS Logins Powershell Module'}
$myFileList['SqlDeepBackupFileCleaner.psm1']=   [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Delete Old Backup files Powershell Module'}
$myFileList['SqlDeepBackupShipping.psm1']=      [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Backup Shipping Powershell Module'}
$myFileList['SqlDeepBackupTest.psm1']=          [PSCustomObject]@{ItemType='OTHER';Tags='MSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Testing Backup Files Powershell Module'}
$myFileList['SqlDeepCommon.psm1']=              [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Common Functions Powershell Module'}
$myFileList['SqlDeepDatabaseShipping.psm1']=    [PSCustomObject]@{ItemType='OTHER';Tags='MSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep DatabaseShipping Powershell Module'}
$myFileList['SqlDeepFileEncryption.ps1']=       [PSCustomObject]@{ItemType='POWERSHELL';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Encrypt/Decrypt File Powershell Module'}
$myFileList['SqlDeepLogWriter.psm1']=           [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep LogWriter Powershell Module'}
$myFileList['SqlDeepSync.psm1']=                [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Sync DB and Repo with master branch Powershell Module'}

#-----Complete object attributes
Write-Host 'Complete object attributes'
foreach ($myFile in $myFileList.Keys) {
    $myFileList[$myFile].ItemName=$myFile
    $myFileList[$myFile].FilePath+=$myFile
}

#-----Sign file(s)
Write-Host 'Sign file(s)'
foreach ($myFile in $myFileList.Keys) {
    if ($myFile.EndsWith('.ps1') -or $myFile.EndsWith('.psm1')) {
        if ((Get-AuthenticodeSignature -FilePath $myFileList[$myFile].FilePath).Status -eq 'HashMismatch'){
            Set-AuthenticodeSignature -FilePath ($myFileList[$myFile].FilePath) -Certificate $myCertificate -IncludeChain All -TimeStampServer http://timestamp.digicert.com
        }
    }
}

#-----Copy file(s) to docker host
Write-Host 'Copy file(s) to docker host'
foreach ($myFile in $myFileList.Keys) {
    scp.exe ($myFileList[$myFile].FilePath) siavash@172.18.3.49:$SqlDeepDbDockerHostHomePath 
}

#-----Generate upload bash script file
Write-Host 'Generate upload bash script file'
[string]$myBashCommand=''
$myBashCommand+='#!/bin/sh'+"`n"
$myBashCommand+='rm ' + $SqlDeepDbDockerContainerPath2017 + '/*'+"`n"
$myBashCommand+='rm ' + $SqlDeepDbDockerContainerPath2019 + '/*'+"`n"
$myBashCommand+='rm ' + $SqlDeepDbDockerContainerPath2022 + '/*'+"`n"
foreach ($myFile in $myFileList.Keys) {
    $myBashCommand+='cp ' + $SqlDeepDbDockerHostHomePath + $myFileList[$myFile].ItemName + ' ' + $SqlDeepDbDockerContainerPath2017 +"`n"
    $myBashCommand+='cp ' + $SqlDeepDbDockerHostHomePath + $myFileList[$myFile].ItemName + ' ' + $SqlDeepDbDockerContainerPath2019 +"`n"
    $myBashCommand+='cp ' + $SqlDeepDbDockerHostHomePath + $myFileList[$myFile].ItemName + ' ' + $SqlDeepDbDockerContainerPath2022 +"`n"
}
New-Item -Path $SqlDeepAssetBashScriptPath -Name 'sqldeepupload' -Value $myBashCommand -Force -ItemType File
scp.exe ($SqlDeepAssetBashScriptPath+'sqldeepupload') siavash@172.18.3.49:$SqlDeepDbDockerHostHomePath

#-----Copy files from docker host to sql docker containers folder(s)
Write-Host 'Copy files from docker host to sql docker containers folder(s)'
[string]$myCommand='bash '+$SqlDeepDbDockerHostHomePath+'sqldeepupload'
ssh.exe siavash@172.18.3.49 $myCommand

#-----Upload file(s) to sqldeep refrence(s) databases
Write-Host 'Upload file(s) to sqldeep refrence(s) databases'
foreach ($myFile in $myFileList.Keys) {
    [string]$myQuery="
        DECLARE @ItemName NVARCHAR(255)=N'"+$myFileList[$myFile].ItemName+"'
        DECLARE @ItemType NVARCHAR(50)=N'"+$myFileList[$myFile].ItemType+"'
        DECLARE @ItemVersion NVARCHAR(50)=N'"+$myFileList[$myFile].ItemVersion+"'
        DECLARE @FilePath NVARCHAR(256)=N'/var/opt/mssql/backup/sqldeep/"+$myFileList[$myFile].ItemName+"'
        DECLARE @Tags NVARCHAR(4000)=N'"+$myFileList[$myFile].Tags+"'
        DECLARE @Description NVARCHAR(4000)=N'"+$myFileList[$myFile].Description+"'
        DECLARE @IsEnabled BIT=1
        DECLARE @Metadata XML=NULL
        DECLARE @AllowToReplaceIfExist BIT=1
        DECLARE @AllowGenerateMetadata BIT=1

        EXECUTE [SqlDeep].[repository].[dbasp_upload_to_publisher] 
        @ItemName
        ,@ItemType
        ,@ItemVersion
        ,@FilePath
        ,@Tags
        ,@Description
        ,@IsEnabled
        ,@Metadata
        ,@AllowToReplaceIfExist
        ,@AllowGenerateMetadata
    "
    #Invoke-Sqlcmd -ConnectionString $SqlDeepDbConnectionString2017 -Query $myQuery
    Invoke-Sqlcmd -ConnectionString $SqlDeepDbConnectionString2019 -Query $myQuery
    #Invoke-Sqlcmd -ConnectionString $SqlDeepDbConnectionString2022 -Query $myQuery
}
#-----Create dac pac file
Write-Host 'Create dac pac file'
$mySqlPackageFilePath=Find-SqlPackageLocation
$mySqlPackageFolderPath=(Get-Item -Path $mySqlPackageFilePath).DirectoryName
$mySqlPackageFolderPath=Clear-FolderPath -FolderPath $mySqlPackageFolderPath
if (-not ($env:Path).Contains($mySqlPackageFolderPath)) {$env:path = $env:path + ';'+$mySqlPackageFolderPath+';'}
Write-Host 'Export Source Database dacpac'
Export-DatabaseDacPac -ConnectionString $SqlDeepDbConnectionString2019 -DacpacFilePath $SqlDeepProjectDacpacFilePath

#-----Sync dac pack file with other SqlDeep Versions
Write-Host 'Sync dac pack file with other SqlDeep Versions'
Publish-DatabaseDacPac -ConnectionString $SqlDeepDbConnectionString2017 -DacpacFilePath $SqlDeepProjectDacpacFilePath
Publish-DatabaseDacPac -ConnectionString $SqlDeepDbConnectionString2022 -DacpacFilePath $SqlDeepProjectDacpacFilePath

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
$myLocalPath2017=$SqlDeepProjectPath+'Assets\Release\Latest\SqlDeep2017.bak'
$myLocalPath2019=$SqlDeepProjectPath+'Assets\Release\Latest\SqlDeep2019.bak'
$myLocalPath2022=$SqlDeepProjectPath+'Assets\Release\Latest\SqlDeep2022.bak'
scp.exe siavash@172.18.3.49:$myLinuxPath2017 $myLocalPath2017
scp.exe siavash@172.18.3.49:$myLinuxPath2019 $myLocalPath2019
scp.exe siavash@172.18.3.49:$myLinuxPath2022 $myLocalPath2022
