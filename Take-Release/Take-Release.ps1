$myFileList=@{};
$myCertificate = (Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object -Property Subject -eq 'CN=sqldeep.com'); 
[string]$ConnectionString='Data Source=172.18.3.49,2019;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=Armin1355$'
[string]$SqlDeepPowershellToolsPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Database-Shipping\'
[string]$SqlDeepPowershellAssetPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\Assets\Powershell\'
[string]$SqlDeepTsqlAssetPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\Assets\TSQL\'

$myFileList['SqlDeepTemplate_ScriptRepositoryJob.sql']=[PSCustomObject]@{ItemType='TSQL';Tags='TSX';ItemName='';FilePath=$SqlDeepTsqlAssetPath;ItemVersion='1.0';Description='Powershell Repository Job, Replace VAR_JOBNAME and VAR_REPOSITORYITEMNAME phrases with yours.'}
$myFileList['HelloWorld.ps1']=              [PSCustomObject]@{ItemType='POWERSHELL';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellAssetPath;ItemVersion='1.0';Description='Implement Sample Powershell Script'}
$myFileList['SqlDeepOsUserAudit.ps1']=      [PSCustomObject]@{ItemType='POWERSHELL';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellAssetPath;ItemVersion='1.0';Description='Implement OS logins audit'}
$myFileList['SqlDeepAudit.psm1']=           [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Find Unusall SQL Admin or OS Logins Powershell Module'}
$myFileList['SqlDeepBackupFileCleaner']=    [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Delete Old Backup files Powershell Module'}
$myFileList['SqlDeepBackupShipping.psm1']=  [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Backup Shipping Powershell Module'}
$myFileList['SqlDeepBackupTest.psm1']=      [PSCustomObject]@{ItemType='OTHER';Tags='MSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Testing Backup Files Powershell Module'}
$myFileList['SqlDeepCommon.psm1']=          [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Common Functions Powershell Module'}
$myFileList['SqlDeepDatabaseShipping.psm1']=[PSCustomObject]@{ItemType='OTHER';Tags='MSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep DatabaseShipping Powershell Module'}
$myFileList['SqlDeepFileEncryption.ps1']=   [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Encrypt/Decrypt File Powershell Module'}
$myFileList['SqlDeepLogWriter.psm1']=       [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep LogWriter Powershell Module'}
$myFileList['SqlDeepSync.psm1']=            [PSCustomObject]@{ItemType='OTHER';Tags='TSX';ItemName='';FilePath=$SqlDeepPowershellToolsPath;ItemVersion='1.0';Description='SqlDeep Sync DB and Repo with master branch Powershell Module'}

foreach ($myFile in $myFileList.Keys) {
    #Auto fill object attributes
    $myFileList[$myFile].ItemName=$myFile
    $myFileList[$myFile].FilePath+=$myFile
    #Sign files
    if ($myFile.EndsWith('.ps1') -or $myFile.EndsWith('.psm1')) {
        Set-AuthenticodeSignature -FilePath ($myFileList[$myFile].FilePath) -Certificate $myCertificate -IncludeChain All -TimeStampServer http://timestamp.digicert.com
    }
    #Copy files to linux server
    
    #Upload files
    [string]$Query="
        DECLARE @ItemName NVARCHAR(255)=N'"+$myFile+"'
        DECLARE @ItemType NVARCHAR(50)=N'"+$myFileList[$myFile].ItemType+"'
        DECLARE @ItemVersion NVARCHAR(50)=N'"+$myFileList[$myFile].ItemVersion+"'
        DECLARE @FilePath NVARCHAR(256)=N'"+$myFileList[$myFile].FilePath+"'
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
    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query
}