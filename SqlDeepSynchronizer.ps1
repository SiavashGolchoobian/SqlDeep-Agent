#region Functions
    enum SqlDeepRepositoryItemCategory {
        SqlDeepCatalog
        SqlDeepDatabase
        SqlDeepPowershellTools
        SqlDeepTsqlScript
    }
    Class WebRepositoryItem {
        [SqlDeepRepositoryItemCategory]$Category
        [string]$FileURI
        [string]$LocalFileName
        [string]$LocalFolderPath
        [string]$Description
        [bool]$IsValid
    
        WebRepositoryItem([SqlDeepRepositoryItemCategory]$Category,[string]$FileURI,[string]$LocalFolderPath,[string]$LocalFileName,[string]$Description){
            Write-Verbose 'WebRepositoryItem object initializing started'
            $this.Category=$Category
            $this.FileURI=$FileURI
            $this.LocalFolderPath=$LocalFolderPath
            $this.LocalFileName=$LocalFileName
            $this.Description=$Description
            $this.IsValid=$true
            Write-Verbose 'WebRepositoryItem object initialized'
        }
        [string] FilePath(){
            return $this.LocalFolderPath+'\'+$this.LocalFileName
        }
    }
    Class RepositoryItem {
        [SqlDeepRepositoryItemCategory]$Category
        [string]$FileName
        [string]$Description
    
        RepositoryItem([SqlDeepRepositoryItemCategory]$Category,[string]$FileName,[string]$Description){
            Write-Verbose 'RepositoryItem object initializing started'
            $this.Category=$Category
            $this.FileName=$FileName
            $this.Description=$Description
            Write-Verbose 'RepositoryItem object initialized'
        }
        [string] FilePath([string]$FolderPath){
            [string]$myAnswer=$null
            if ($FolderPath[-1] -eq '\'){
                $myAnswer=$FolderPath+$this.FileName
            }else{
                $myAnswer=$FolderPath+'\'+$this.FileName
            }
            return $myAnswer
        }
    }
    function Download-File {
        [OutputType([bool])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="URI address to download")][string]$URI,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Save downloaded file to this folder path")][string]$FolderPath,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Save downloaded file as this name")][string]$FileName
        )
        begin{
            #Create SaveToFolderPath if not exists
            [bool]$myAnswer=$false
            if((Test-Path -Path $FolderPath) -eq $false) {
                New-Item -ItemType Directory -Path $FolderPath -Force
            }
        }
        process{
            try {
                if((Test-Path -Path $FolderPath) -eq $true) {
                    Invoke-WebRequest -Uri $URI -OutFile ($FolderPath+'\'+$FileName)
                    $myAnswer=(Test-Path -Path ($FolderPath+'\'+$FileName))
                }else{
                    $myAnswer=$false
                }
            }catch{
                $myAnswer=$false
            }
            return $myAnswer
        }
        end{}
    }
    function Find-SqlPackageLocation {
        #Downloaded from https://www.powershellgallery.com/packages/PublishDacPac/
        <#
            .SYNOPSIS
            Lists all locations of SQLPackage.exe files on the machine
        
            .DESCRIPTION
            Simply finds and lists the location path to every version of SqlPackage.exe on the machine.
        
            For information on SqlPackage.exe see https://docs.microsoft.com/en-us/sql/tools/sqlpackage
        
            .EXAMPLE
            Find-SqlPackageLocations
        
            Simply lists all instances of SqlPackage.exe on the host machine
        
            .INPUTS
            None
        
            .OUTPUTS
            Output is written to standard output.
            
            .LINK
            https://github.com/DrJohnT/PublishDacPac
        
            .NOTES
            Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/PublishDacPac
            This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
        #>
        [OutputType([string])]
        param()
        begin {
            [string]$myExeName = "SqlPackage.exe";
            [string]$mySqlPackageFilePath=$null;
            [string]$mySqlPackageFolderPath=$null;
        }
        process{
            [string]$myAnswer=$null
            [string]$myProductVersion=$null
            try {
                # Get SQL Server locations
                [System.Management.Automation.PathInfo[]]$myPathsToSearch = Resolve-Path -Path "${env:ProgramFiles}\Microsoft SQL Server\*\DAC\bin" -ErrorAction SilentlyContinue;
                $myPathsToSearch += Resolve-Path -Path "${env:ProgramFiles}\Microsoft SQL Server\*\Tools\Binn" -ErrorAction SilentlyContinue;
                $myPathsToSearch += Resolve-Path -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\Tools\Binn" -ErrorAction SilentlyContinue;
                $myPathsToSearch += Resolve-Path -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\DAC\bin" -ErrorAction SilentlyContinue;
                $myPathsToSearch += Resolve-Path -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio *\Common7\IDE\Extensions\Microsoft\SQLDB\DAC" -ErrorAction SilentlyContinue;
                $myPathsToSearch += Resolve-Path -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\" -ErrorAction SilentlyContinue;    

                # For those that install SQLPackage.exe in a completely different location, set environment variable CustomSqlPackageInstallLocation
                $myCustomInstallLocation = [Environment]::GetEnvironmentVariable('CustomSqlPackageInstallLocation');
                $myCustomInstallLocation = Clear-FolderPath -FolderPath $myCustomInstallLocation
                if ($myCustomInstallLocation -ne '') {
                    if (Test-Path $myCustomInstallLocation) {
                        $myPathsToSearch += Resolve-Path -Path ($myCustomInstallLocation+'\') -ErrorAction SilentlyContinue;
                    }        
                }

                foreach ($myPathToSearch in $myPathsToSearch) {
                    [System.IO.FileSystemInfo[]]$mySqlPackageExes += Get-Childitem -Path $myPathToSearch -Recurse -Include $myExeName -ErrorAction SilentlyContinue;
                }

                # list all the locations found
                [string]$myCurrentVersion=''
                foreach ($mySqlPackageExe in $mySqlPackageExes) {
                    $myProductVersion = $mySqlPackageExe.VersionInfo.ProductVersion.Substring(0,2);
                    if ($myProductVersion -gt $myCurrentVersion){
                        $myCurrentVersion=$myProductVersion
                        $myAnswer=$mySqlPackageExe
                    }
                    Write-Host ($myProductVersion + ' ' + $mySqlPackageExe);
                }       
            }
            catch {
                Write-Error 'Find-SqlPackageLocations failed with error: ' + $_.ToString();
            }

            if ($myAnswer) {
                $mySqlPackageFilePath=$myAnswer
                $mySqlPackageFolderPath=(Get-Item -Path $mySqlPackageFilePath).DirectoryName
                $mySqlPackageFolderPath=Clear-FolderPath -FolderPath $mySqlPackageFolderPath
                if (-not ($env:Path).Contains($mySqlPackageFolderPath)) {$env:path = $env:path + ';'+$mySqlPackageFolderPath+';'}
            }
            return $myAnswer
        }
        end {
        }
    }
    function Download-RepositoryItems(){
        [OutputType([RepositoryItem[]])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Folder path to save downloaded items")][string]$LocalRepositoryPath
        )
        begin{
            #===============Parameters
            [string]$mySqlDeepOfficialCatalogURI=$null;
            [string]$mySqlDeepOfficialCatalogFilename=$null;
            [string]$myLocalRepositoryArchivePath=$null;
            [WebRepositoryItem[]]$myWebRepositoryCollection=$null;
            [WebRepositoryItem]$myWebRepositoryItem=$null;
            [RepositoryItem[]]$myAnswer=$null;
            #===============Constants
            $mySqlDeepOfficialCatalogURI='https://github.com/SiavashGolchoobian/SqlDeep-Synchronizer/raw/refs/heads/main/SqlDeepCatalog.json'
            $myInstalledCertificate = (Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object -Property Subject -eq 'CN=sqldeep.com'); 
            $mySqlDeepOfficialCatalogFilename=$mySqlDeepOfficialCatalogURI.Split('/')[-1]
            if ($LocalRepositoryPath[-1] -eq '\') {$LocalRepositoryPath=$LocalRepositoryPath.Substring(0,$LocalRepositoryPath.Length-1)}
            $myLocalRepositoryArchivePath=$LocalRepositoryPath+'\Archive\'+(Get-Date -Format "yyyyMMdd_HHmmss").ToString()
            if((Test-Path -Path $myLocalRepositoryArchivePath) -eq $false) {New-Item -ItemType Directory -Path $myLocalRepositoryArchivePath -Force}
            $myWebRepositoryItem=[WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepCatalog,$mySqlDeepOfficialCatalogURI,$LocalRepositoryPath,$mySqlDeepOfficialCatalogFilename,'This file contains standard SqlDeep catalog items to download.')
            $myWebRepositoryCollection+=($myWebRepositoryItem)
        }
        process{
            #Download Catalog file(s)
            $myWebRepositoryCollection | Where-Object -Property Category -eq SqlDeepCatalog | ForEach-Object{
                Move-Item -Path ($_.FilePath()) -Destination $myLocalRepositoryArchivePath -Force
                Download-File -URI ($_.FileURI) -FolderPath ($_.LocalFolderPath) -FileName ($_.LocalFileName)
            }
            #Fill RepositoryCollection via Catalog file(s)
            foreach ($myWebRepositoryItem in ($myWebRepositoryCollection | Where-Object -Property Category -eq SqlDeepCatalog)) {
                $myResult=Get-Content -Raw -Path ($myWebRepositoryItem.FilePath()) | ConvertFrom-Json
                $myResult.library.SqlDeepPowershellTools    | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepPowershellTools,($_.uri),$LocalRepositoryPath,($_.name),($_.description)))}
                $myResult.library.SqlDeepDatabase           | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepDatabase,($_.uri),$LocalRepositoryPath,($_.name),($_.description)))}
                $myResult.library.SqlDeepTsqlScript         | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepTsqlScript,($_.uri),$LocalRepositoryPath,($_.name),($_.description)))}
            }
            #Download non-catalog type Repository Contents
            $myWebRepositoryCollection | Where-Object -Property Category -ne SqlDeepCatalog | ForEach-Object{
                Move-Item -Path ($_.FilePath()) -Destination $myLocalRepositoryArchivePath -Force
                Download-File -URI ($_.FileURI) -FolderPath ($_.LocalFolderPath) -FileName ($_.LocalFileName)
            }
            #Validate all files are downloaded and validate their signatures
            foreach ($myWebRepositoryItem in ($myWebRepositoryCollection | Where-Object -Property LocalFileName -Match '.ps1|.psm1')) {
                $mySignerCertificate=Get-AuthenticodeSignature -FilePath ($myWebRepositoryItem.FilePath())
                if ($mySignerCertificate.Status -notin ('Valid','UnknownError') -or $mySignerCertificate.SignerCertificate.Thumbprint -ne $myInstalledCertificate.Thumbprint) {
                    Write-Host ('Signature is not valid for ' + $myWebRepositoryItem.FilePath() + ' file. this file was removed.' )
                    $myWebRepositoryItem.IsValid=$false
                    Remove-Item -Path ($myWebRepositoryItem.FilePath()) -Force
                } 
            }
        }
        end{
            Move-Item -Path ($LocalRepositoryPath+'\'+$mySqlDeepOfficialCatalogFilename+'.result') -Destination $myLocalRepositoryArchivePath -Force 
            $null = $myWebRepositoryCollection | Where-Object {$_.IsValid -eq $true -and $_.Category -ne 'SqlDeepCatalog'} | Select-Object -Property Category,LocalFileName,Description | Sort-Object -Property Category,LocalFileName | ForEach-Object{$myAnswer+=[RepositoryItem]::New($_.Category,$_.LocalFileName,$_.Description)}
            $null = $myAnswer | ConvertTo-Json | Out-File -FilePath ($LocalRepositoryPath+'\'+$mySqlDeepOfficialCatalogFilename+'.result') -Force
            return $myAnswer
        }
    }
    function ConvertFrom-RepositoryItemsFile(){
        [OutputType([RepositoryItem[]])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="SqlDeep RepositoryItems file")][ValidateNotNullOrEmpty()][string]$FilePath
        )
        begin{
            [RepositoryItem[]]$myAnswer=$null
        }
        process{
            try {
                if((Test-Path -Path $FilePath) -eq $true) {
                    $null=Get-Content -Raw -Path $FilePath | ConvertFrom-Json | Select-Object -Property Category,FileName,Description | Sort-Object -Property Category,FileName | ForEach-Object{$myAnswer+=[RepositoryItem]::New($_.Category,$_.FileName,$_.Description)}
                }else{
                    $myAnswer=$null
                }
            }catch{
                $myAnswer=$null
            }
            return $myAnswer
        }
        end{}
    }
    function Publish-DatabaseDacPac {
        [OutputType([bool])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage=".dapac file path to import")][ValidateNotNullOrEmpty()][string]$DacpacFilePath,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Target database connection string")][ValidateNotNullOrEmpty()][string]$ConnectionString
        )
        begin {}
        process {
            [bool]$myAnswer=$false;
            try
            {
                if (Test-Path -Path $DacpacFilePath) {
                    $null=SqlPackage /Action:Publish /OverwriteFiles:true /TargetConnectionString:$ConnectionString /SourceFile:$DacpacFilePath /Properties:AllowIncompatiblePlatform=True /Properties:BackupDatabaseBeforeChanges=True /Properties:BlockOnPossibleDataLoss=False /Properties:DeployDatabaseInSingleUserMode=True /Properties:DisableAndReenableDdlTriggers=True /Properties:DropObjectsNotInSource=True /Properties:GenerateSmartDefaults=True /Properties:IgnoreExtendedProperties=True /Properties:IgnoreFilegroupPlacement=False /Properties:IgnoreFillFactor=False /Properties:IgnoreIndexPadding=False /Properties:IgnoreObjectPlacementOnPartitionScheme=False /Properties:IgnorePermissions=True /Properties:IgnoreRoleMembership=True /Properties:IgnoreSemicolonBetweenStatements=False /Properties:IncludeTransactionalScripts=True /Properties:VerifyDeployment=True;
                    $myAnswer=$true
                }
                return $myAnswer
            }
            catch
            {       
                $myAnswer=$false;
                Write-Error($_.ToString());
                Throw;
            }
            return $myAnswer;
        }
        end {}
    }
    function Publish-DatabaseRepositoryScripts(){
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Folder path including downloaded items")][string]$LocalRepositoryPath,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Target database connection string")][ValidateNotNullOrEmpty()][string]$ConnectionString,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="SqlDeep RepositoryItems")]$SqlDeepRepositoryItems
        )
        begin{
            [string]$myItemType=$null;
            [SqlDeepRepositoryItemCategory[]]$myAcceptedCategories=@();
            $myAcceptedCategories+=[SqlDeepRepositoryItemCategory]::SqlDeepPowershellTools;
            $myAcceptedCategories+=[SqlDeepRepositoryItemCategory]::SqlDeepTsqlScript;

            $mySqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString);
            $mySqlCommand = $mySqlConnection.CreateCommand();
            $mySqlConnection.Open(); 
            $mySqlCommand.CommandText = '[SqlDeep].[repository].[dbasp_upload_to_publisher]';
            $mySqlCommand.CommandType=[System.Data.CommandType]'StoredProcedure'
            $null = $mySqlCommand.Parameters.Add("@ItemName", [System.Data.SqlDbType]'NVarChar')
            $null = $mySqlCommand.Parameters.Add("@ItemType", [System.Data.SqlDbType]'NVarChar')
            $null = $mySqlCommand.Parameters.Add("@ItemVersion", [System.Data.SqlDbType]'NVarChar')
            $null = $mySqlCommand.Parameters.Add("@ItemContent", [System.Data.SqlDbType]'VarBinary')
            $null = $mySqlCommand.Parameters.Add("@Tags", [System.Data.SqlDbType]'NVarChar')
            $null = $mySqlCommand.Parameters.Add("@Description", [System.Data.SqlDbType]'NVarChar')
            $null = $mySqlCommand.Parameters.Add("@IsEnabled", [System.Data.SqlDbType]'Bit')
            $null = $mySqlCommand.Parameters.Add("@Metadata", [System.Data.SqlDbType]'Xml')
            $null = $mySqlCommand.Parameters.Add("@AllowToReplaceIfExist", [System.Data.SqlDbType]'Bit')
            $null = $mySqlCommand.Parameters.Add("@AllowGenerateMetadata", [System.Data.SqlDbType]'Bit')
        }
        process{
            if ($null -ne $SqlDeepRepositoryItems){
                foreach($mySqlDeepRepositoryItem in ($SqlDeepRepositoryItems|Where-Object -Property Category -In $myAcceptedCategories)){
                    $myItemType=SWITCH($mySqlDeepRepositoryItem.FileName.Split('.')[-1].ToUpper()) {
                        'PSM1'  {'OTHER'}
                        'PS1'   {'POWERSHELL'}
                        'SQL'   {'TSQL'}
                        Default {'OTHER'}
                    }
                    try {
                        #Get the file
                        [Byte[]]$myFileContent = Get-Content -AsByteStream ($mySqlDeepRepositoryItem.FilePath($LocalRepositoryPath))
                        $mySqlCommand.Parameters["@ItemName"].Value=($mySqlDeepRepositoryItem.FileName)
                        $mySqlCommand.Parameters["@ItemType"].Value=($myItemType)
                        $mySqlCommand.Parameters["@ItemVersion"].Value=[DBNull]::Value
                        $mySqlCommand.Parameters["@ItemContent"].Size=-1
                        $mySqlCommand.Parameters["@ItemContent"].Value=$myFileContent
                        $mySqlCommand.Parameters["@Tags"].Value=[DBNull]::Value
                        $mySqlCommand.Parameters["@Description"].Value=($mySqlDeepRepositoryItem.Description)
                        $mySqlCommand.Parameters["@IsEnabled"].Value=1
                        $mySqlCommand.Parameters["@Metadata"].Value=[DBNull]::Value
                        $mySqlCommand.Parameters["@AllowToReplaceIfExist"].Value=1
                        $mySqlCommand.Parameters["@AllowGenerateMetadata"].Value=1
                        $null = $mySqlCommand.ExecuteNonQuery()
                    }
                    catch {
                        Write-Error (($_.ToString()).ToString())
                    }
                }
            }
        }
        end{
            $mySqlCommand.Dispose();
            $mySqlConnection.Close();
            $mySqlConnection.Dispose();
        }
    }
    function Sync-SqlDeep(){
        [CmdletBinding(DefaultParameterSetName = 'SYNC_ONLINE')]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Folder path including downloaded items")][string]$LocalRepositoryPath,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Target database connection string",ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][ValidateNotNullOrEmpty()][string]$ConnectionString,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="SqlDeep RepositoryItems",ParameterSetName = 'SYNC_ONLINE')]$SqlDeepRepositoryItems,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="SqlDeep RepositoryItems file path",ParameterSetName = 'SYNC_OFFLINE')]$SqlDeepRepositoryItemsFileName,
            [Parameter(Mandatory=$false,ParameterSetName = 'DOWNLOAD')][Parameter(ParameterSetName = 'SYNC_ONLINE')][Switch]$DownloadAssets,
            [Parameter(Mandatory=$false,ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][Switch]$SyncDatabaseModule,
            [Parameter(Mandatory=$false,ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][Switch]$SyncScriptRepository
        )
        begin{}
        process{
            [RepositoryItem[]]$myRepositoryItems=$null
            if ($DownloadAssets) {
                Write-Host 'Download ...'
                $myRepositoryItems=Download-RepositoryItems -LocalRepositoryPath $LocalRepositoryPath
            }
            if ($SyncDatabaseModule) {
                Write-Host 'SyncDatabaseModule ...'
                if ($PSCmdlet.ParameterSetName -eq 'SYNC_OFFLINE'){
                    Write-Host 'Load Catalog ...'
                    $myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath ($LocalRepositoryPath+'\SqlDeepCatalog.json.result')
                }
                Write-Host 'Publish DatabaseDacPac ...'
                $null=$myRepositoryItems | Where-Object -Property Category -eq SqlDeepDatabase | ForEach-Object{Publish-DatabaseDacPac -DacpacFilePath ($_.FileName) -ConnectionString $ConnectionString}
            }
            if ($SyncScriptRepository) {
                Write-Host 'SyncScriptRepository ...'
                if ($PSCmdlet.ParameterSetName -eq 'SYNC_OFFLINE'){
                    Write-Host 'Load Catalog ...'
                    $myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath ($LocalRepositoryPath+'\SqlDeepCatalog.json.result')
                }
                Write-Host 'Publish DatabaseRepositoryScripts ...'
                Publish-DatabaseRepositoryScripts -LocalRepositoryPath $LocalRepositoryPath -ConnectionString $ConnectionString -SqlDeepRepositoryItems $myRepositoryItems
            }
        }
        end{}
    }
#endregion

# #region Export
# Export-ModuleMember -Function Sync-SqlDeep
# #endregion

Sync-SqlDeep -LocalRepositoryPath 'E:\Log\SqlDeep' -DownloadAssets