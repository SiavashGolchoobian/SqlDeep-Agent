#<#SqlDeep-Comment
[CmdletBinding(DefaultParameterSetName = 'SYNC_ONLINE')]
param (
    [Parameter(Mandatory=$true,HelpMessage="Folder path including downloaded items")][string]$LocalRepositoryPath,
    [Parameter(Mandatory=$false,HelpMessage="Target database connection string",ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][ValidateNotNullOrEmpty()][string]$ConnectionString,
    [Parameter(Mandatory=$true,HelpMessage="SqlDeep RepositoryItems file path",ParameterSetName = 'SYNC_OFFLINE')]$SqlDeepRepositoryItemsFileName,
    [Parameter(Mandatory=$false,ParameterSetName = 'DOWNLOAD')][Parameter(ParameterSetName = 'SYNC_ONLINE')][Switch]$DownloadAssets,
    [Parameter(Mandatory=$false,ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][Switch]$SyncDatabaseModule,
    [Parameter(Mandatory=$false,ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][Switch]$SyncScriptRepository
)
#SqlDeep-Comment#>

#region Functions
    enum SqlDeepRepositoryItemCategory {
        SqlDeepCatalog
        SqlDeepDatabase
        SqlDeepPowershellTools
        SqlDeepTsqlScript
        SqlDeepSynchronizerTools
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
    function Clear-FolderPath { #Remove latest '\' char from folder path
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Input folder path to evaluate")][AllowEmptyString()][AllowNull()][string]$FolderPath
    )
    begin{}
    process{
        $FolderPath=$FolderPath.Trim()
        if ($FolderPath.ToCharArray()[-1] -eq '\') {$FolderPath=$FolderPath.Substring(0,$FolderPath.Length-1)}    
        return $FolderPath
    }
    end{}    
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
            Write-Host ('Download-File started.')
            [bool]$myAnswer=$false
            if((Test-Path -Path $FolderPath) -eq $false) {
                Write-Host ('Creating destination folder named ' + $FolderPath)
                New-Item -ItemType Directory -Path $FolderPath -Force
            }
        }
        process{
            try {
                if((Test-Path -Path $FolderPath) -eq $true) {
                    Write-Host ('Downloading ' + $URI)
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
        end{
            Write-Host ('Download-File finished.')
        }
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
            Write-Host ('Find-SqlPackageLocation started.')
            [string]$myAnswer=$null
            [string]$myExeName = "SqlPackage.exe";
            [string]$mySqlPackageFilePath=$null;
            [string]$mySqlPackageFolderPath=$null;
        }
        process{
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
            if ($null -eq $myAnswer) {
                Write-Host 'DacPac module does not found, please Downloaded and install it from https://www.powershellgallery.com/packages/PublishDacPac/ or run this command in powershell console: Install-Module -Name PublishDacPac'
            }
            Write-Host ('Find-SqlPackageLocation finished.')
        }
    }
    function Validate-Signature {
        [OutputType([bool])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="File path")][ValidateNotNullOrEmpty()][string]$FilePath
        )
        begin{
            Write-Host ('Validate-Signature started.')
            [bool]$myAnswer=$false
            $myInstalledCertificate = (Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object -Property Subject -eq 'CN=sqldeep.com'); 
        }
        process{
            Write-Host ('Check signature of file ' + $FilePath)
            $mySignerCertificate=Get-AuthenticodeSignature -FilePath $FilePath
            if ($mySignerCertificate.Status -notin ('Valid','UnknownError') -or $mySignerCertificate.SignerCertificate.Thumbprint -ne $myInstalledCertificate.Thumbprint) {
                Write-Host ('Signature is not valid for ' + $FilePath + ' file' )
                $myAnswer=$false
            } else {
                $myAnswer=$true
            }
            return $myAnswer
        }
        end{
            Write-Host ('Validate-Signature finished.')
        }
    }
    function Download-RepositoryItems(){
        [OutputType([RepositoryItem[]])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Folder path to save downloaded items")][string]$LocalRepositoryPath
        )
        begin{
            Write-Host ('Download-RepositoryItems started.')
            #===============Parameters
            [string]$mySqlDeepOfficialCatalogURI=$null;
            [string]$mySqlDeepOfficialCatalogFilename=$null;
            [string]$myLocalRepositoryArchivePath=$null;
            [WebRepositoryItem[]]$myWebRepositoryCollection=$null;
            [WebRepositoryItem]$myWebRepositoryItem=$null;
            [RepositoryItem[]]$myAnswer=$null;
            #===============Constants
            $mySqlDeepOfficialCatalogURI='https://github.com/SiavashGolchoobian/SqlDeep-Synchronizer/raw/refs/heads/main/Assets/SqlDeepCatalog.json'
            $mySqlDeepOfficialCatalogFilename=$mySqlDeepOfficialCatalogURI.Split('/')[-1]
            if ($LocalRepositoryPath[-1] -eq '\') {$LocalRepositoryPath=$LocalRepositoryPath.Substring(0,$LocalRepositoryPath.Length-1)}
            $myLocalRepositoryArchivePath=$LocalRepositoryPath+'\Archive\'+(Get-Date -Format "yyyyMMdd_HHmmss").ToString()
            if((Test-Path -Path $myLocalRepositoryArchivePath) -eq $false) {
                Write-Host ('Creating archive folder named ' + $myLocalRepositoryArchivePath)
                $null = New-Item -ItemType Directory -Path $myLocalRepositoryArchivePath -Force
            }
            $myWebRepositoryItem=[WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepCatalog,$mySqlDeepOfficialCatalogURI,$LocalRepositoryPath,$mySqlDeepOfficialCatalogFilename,'This file contains standard SqlDeep catalog items to download.')
            $myWebRepositoryCollection+=($myWebRepositoryItem)
        }
        process{
            #Download Catalog file(s)
            $null = $myWebRepositoryCollection | Where-Object -Property Category -eq SqlDeepCatalog | ForEach-Object{
                if (Test-Path -Path ($_.FilePath()) -PathType Leaf){
                    Write-Host ('Move old file ' + ($_.FilePath()) + ' to ' + $myLocalRepositoryArchivePath)
                    $null = Move-Item -Path ($_.FilePath()) -Destination $myLocalRepositoryArchivePath -Force
                }
                Download-File -URI ($_.FileURI) -FolderPath ($_.LocalFolderPath) -FileName ($_.LocalFileName)
            }
            #Fill RepositoryCollection via Catalog file(s)
            foreach ($myWebRepositoryItem in ($myWebRepositoryCollection | Where-Object -Property Category -eq SqlDeepCatalog)) {
                $myResult=Get-Content -Raw -Path ($myWebRepositoryItem.FilePath()) | ConvertFrom-Json
                $null=$myResult.library.SqlDeepPowershellTools    | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepPowershellTools,($_.uri),$LocalRepositoryPath,($_.name),($_.description)))}
                $null=$myResult.library.SqlDeepDatabase           | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepDatabase,($_.uri),$LocalRepositoryPath,($_.name),($_.description)))}
                $null=$myResult.library.SqlDeepTsqlScript         | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepTsqlScript,($_.uri),$LocalRepositoryPath,($_.name),($_.description)))}
                $null=$myResult.library.SqlDeepSynchronizerTools  | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepSynchronizerTools,($_.uri),$LocalRepositoryPath,($_.name),($_.description)))}
            }
            #Download non-catalog type Repository Contents
            $null = $myWebRepositoryCollection | Where-Object -Property Category -ne SqlDeepCatalog | ForEach-Object{
                if (Test-Path -Path ($_.FilePath()) -PathType Leaf) {
                    Write-Host ('Move old file ' + ($_.FilePath()) + ' to ' + $myLocalRepositoryArchivePath)
                    $null = Move-Item -Path ($_.FilePath()) -Destination $myLocalRepositoryArchivePath -Force
                }
                $null = Download-File -URI ($_.FileURI) -FolderPath ($_.LocalFolderPath) -FileName ($_.LocalFileName)
            }
            #Validate all files are downloaded and validate their signatures
            foreach ($myWebRepositoryItem in ($myWebRepositoryCollection | Where-Object -Property LocalFileName -Match '.ps1|.psm1')) {
                if ((Validate-Signature -FilePath ($myWebRepositoryItem.FilePath())) -eq $false){
                    Write-Host ('because of invalid signature file was removed.' )
                    $myWebRepositoryItem.IsValid=$false
                    $null = Remove-Item -Path ($myWebRepositoryItem.FilePath()) -Force
                } 
            }
        }
        end{
            if (Test-Path -Path ($LocalRepositoryPath+'\'+$mySqlDeepOfficialCatalogFilename+'.result') -PathType Leaf) {
                Write-Host ('Move old file ' + ($LocalRepositoryPath+'\'+$mySqlDeepOfficialCatalogFilename+'.result') + ' to ' + $myLocalRepositoryArchivePath)
                $null = Move-Item -Path ($LocalRepositoryPath+'\'+$mySqlDeepOfficialCatalogFilename+'.result') -Destination $myLocalRepositoryArchivePath -Force 
            }
            $null = $myWebRepositoryCollection | Where-Object {$_.IsValid -eq $true -and $_.Category -ne 'SqlDeepCatalog'} | Select-Object -Property Category,LocalFileName,Description | Sort-Object -Property Category,LocalFileName | ForEach-Object{$myAnswer+=[RepositoryItem]::New($_.Category,$_.LocalFileName,$_.Description)}
            Write-Host ('Save RepositoryItems catalog to ' + ($LocalRepositoryPath+'\'+$mySqlDeepOfficialCatalogFilename+'.result'))
            $null = $myAnswer | ConvertTo-Json | Out-File -FilePath ($LocalRepositoryPath+'\'+$mySqlDeepOfficialCatalogFilename+'.result') -Force
            Write-Host ('Download-RepositoryItems finished.')
            return $myAnswer
        }
    }
    function ConvertFrom-RepositoryItemsFile(){
        [OutputType([RepositoryItem[]])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="SqlDeep RepositoryItems file")][ValidateNotNullOrEmpty()][string]$FilePath
        )
        begin{
            Write-Host ('ConvertFrom-RepositoryItemsFile started.')
            [RepositoryItem[]]$myAnswer=$null
        }
        process{
            try {
                if((Test-Path -Path $FilePath -PathType Leaf) -eq $true) {
                    $myCollection=Get-Content -Raw -Path $FilePath | ConvertFrom-Json 
                    $null = $myCollection | Select-Object -Property Category,FileName,Description | Sort-Object -Property Category,FileName | ForEach-Object{$myAnswer+=([RepositoryItem]::New($_.Category,$_.FileName,$_.Description))}
                }else{
                    $myAnswer=$null
                }
            }catch{
                $myAnswer=$null
                Write-Error($_.ToString());
                Throw;
            }
        }
        end{
            Write-Host ($myAnswer.Count.ToString() + ' items detected in catalog file.')
            Write-Host ('ConvertFrom-RepositoryItemsFile finished.')
            return $myAnswer
        }
    }
    function Get-PrePublishReport {
        [OutputType([bool])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage=".dapac file path to import")][ValidateNotNullOrEmpty()][string]$DacpacFilePath,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Target database connection string")][ValidateNotNullOrEmpty()][string]$ConnectionString,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Report file path to export")][ValidateNotNullOrEmpty()][string]$ReportFilePath
        )
        begin {
            [bool]$myAnswer=$false;
        }
        process {
            try
            {
                if ($null -ne (Find-SqlPackageLocation)) {
                    if (Test-Path -Path $DacpacFilePath) {
                        $null=SqlPackage /Action:DeployReport /OutputPath:$ReportFilePath /OverwriteFiles:true /TargetConnectionString:$ConnectionString /SourceFile:$DacpacFilePath /Properties:AllowIncompatiblePlatform=True /Properties:BackupDatabaseBeforeChanges=True /Properties:BlockOnPossibleDataLoss=False /Properties:DeployDatabaseInSingleUserMode=True /Properties:DisableAndReenableDdlTriggers=True /Properties:DropObjectsNotInSource=True /Properties:GenerateSmartDefaults=True /Properties:IgnoreExtendedProperties=True /Properties:IgnoreFilegroupPlacement=False /Properties:IgnoreFillFactor=False /Properties:IgnoreIndexPadding=False /Properties:IgnoreObjectPlacementOnPartitionScheme=False /Properties:IgnorePermissions=True /Properties:IgnoreRoleMembership=True /Properties:IgnoreSemicolonBetweenStatements=False /Properties:IncludeTransactionalScripts=True /Properties:VerifyDeployment=True;
                        $myAnswer=$true
                    }
                }else{
                    Write-Error 'DacPac binaries does not found. please install dacpac binaries.'
                }
            }
            catch
            {       
                $myAnswer=$false;
                Write-Error($_.ToString());
                Throw;
            }
        }
        end {
            return $myAnswer;
        }
    }
    function Publish-DatabaseDacPac {
        [OutputType([bool])]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage=".dapac file path to import")][ValidateNotNullOrEmpty()][string]$DacpacFilePath,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Target database connection string")][ValidateNotNullOrEmpty()][string]$ConnectionString
        )
        begin {
            Write-Host ('Publish-DatabaseDacPac started.')
            [bool]$myAnswer=$false;
        }
        process {
            try
            {
                if ($null -ne (Find-SqlPackageLocation)) {
                    if (Test-Path -Path $DacpacFilePath -PathType Leaf) {
                        Write-Host ('Publish DatabaseDacPac file ' + $DacpacFilePath) -ForegroundColor Green
                        $null=SqlPackage /Action:Publish /OverwriteFiles:true /TargetConnectionString:$ConnectionString /SourceFile:$DacpacFilePath /Properties:AllowIncompatiblePlatform=True /Properties:BackupDatabaseBeforeChanges=True /Properties:BlockOnPossibleDataLoss=False /Properties:DeployDatabaseInSingleUserMode=True /Properties:DisableAndReenableDdlTriggers=True /Properties:DropObjectsNotInSource=True /Properties:GenerateSmartDefaults=True /Properties:IgnoreExtendedProperties=True /Properties:IgnoreFilegroupPlacement=False /Properties:IgnoreFillFactor=False /Properties:IgnoreIndexPadding=False /Properties:IgnoreObjectPlacementOnPartitionScheme=False /Properties:IgnorePermissions=True /Properties:IgnoreRoleMembership=True /Properties:IgnoreSemicolonBetweenStatements=False /Properties:IncludeTransactionalScripts=True /Properties:VerifyDeployment=True;
                        $myAnswer=$true
                    }else{
                        Write-Error ('DacPac file ' +$DacpacFilePath+ ' does not found.')    
                    }
                }else{
                    Write-Error 'DacPac binaries does not found. please install dacpac binaries.'
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
        end {
            Write-Host ('Publish-DatabaseDacPac finished.')
        }
    }
    function Publish-DatabaseRepositoryScripts(){
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Folder path including downloaded items")][string]$LocalRepositoryPath,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Target database connection string")][ValidateNotNullOrEmpty()][string]$ConnectionString,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="SqlDeep RepositoryItems")]$SqlDeepRepositoryItems
        )
        begin{
            Write-Host ('Publish-DatabaseRepositoryScripts started.')
            [string]$myItemExtension=$null;
            [string]$myItemType=$null;
            [SqlDeepRepositoryItemCategory[]]$myAcceptedCategories=@();
            $myAcceptedCategories+=[SqlDeepRepositoryItemCategory]::SqlDeepPowershellTools;
            $myAcceptedCategories+=[SqlDeepRepositoryItemCategory]::SqlDeepTsqlScript;

            $mySqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString);
            $mySqlCommand = $mySqlConnection.CreateCommand();
            $mySqlConnection.Open(); 
            $mySqlCommand.CommandText = '[SqlDeep].[repository].[dbasp_upload_to_publisher]';
            $mySqlCommand.CommandType=[System.Data.CommandType]::StoredProcedure
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
                    Write-Host ('Publish Repository file ' + $mySqlDeepRepositoryItem.FileName)
                    $myItemExtension=$mySqlDeepRepositoryItem.FileName.Split('.')[-1].ToUpper()
                    $myItemType=SWITCH($myItemExtension) {
                        'PSM1'  {'OTHER'}
                        'PS1'   {'POWERSHELL'}
                        'SQL'   {'TSQL'}
                        Default {'OTHER'}
                    }
                    try {
                        #Validate file signatures
                        if ($myItemExtension -in ('PSM1','PS1') -and (Validate-Signature -FilePath ($mySqlDeepRepositoryItem.FilePath($LocalRepositoryPath))) -eq $false){
                            Write-Host ('Because of invalid signature this file was skipped.' )
                        } else {
                            #Get the file
                            [int]$myPowershellVersion=($PSVersionTable.PSVersion.Major)
                            [Byte[]]$myFileContent = $null
                            if ($myPowershellVersion -ge 7){
                                $myFileContent=Get-Content -AsByteStream ($mySqlDeepRepositoryItem.FilePath($LocalRepositoryPath))
                            }else{
                                $myFileContent=Get-Content -Encoding Byte ($mySqlDeepRepositoryItem.FilePath($LocalRepositoryPath))
                            }
                            
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
            Write-Host ('Publish-DatabaseRepositoryScripts finished.')
        }
    }
    function Sync-SqlDeep(){
        [CmdletBinding(DefaultParameterSetName = 'SYNC_ONLINE')]
        param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Folder path including downloaded items")][string]$LocalRepositoryPath,
            [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Target database connection string",ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][ValidateNotNullOrEmpty()][string]$ConnectionString,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="SqlDeep RepositoryItems file path",ParameterSetName = 'SYNC_OFFLINE')]$SqlDeepRepositoryItemsFileName,
            [Parameter(Mandatory=$false,ParameterSetName = 'DOWNLOAD')][Parameter(ParameterSetName = 'SYNC_ONLINE')][Switch]$DownloadAssets,
            [Parameter(Mandatory=$false,ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][Switch]$SyncDatabaseModule,
            [Parameter(Mandatory=$false,ParameterSetName = 'SYNC_ONLINE')][Parameter(ParameterSetName = 'SYNC_OFFLINE')][Switch]$SyncScriptRepository
        )
        begin{
            Write-Host ('Sync-SqlDeep started.')
            if ($LocalRepositoryPath[-1] -eq '\'){
                $LocalRepositoryPath=$LocalRepositoryPath.Substring(0,$LocalRepositoryPath.Length-1)
            }
        }
        process{
            [RepositoryItem[]]$myRepositoryItems=$null
            if ($DownloadAssets) {
                Write-Host 'Download ...' -ForegroundColor Green
                $myRepositoryItems=Download-RepositoryItems -LocalRepositoryPath $LocalRepositoryPath
            }
            if ($SyncDatabaseModule) {
                Write-Host 'SyncDatabaseModule ...' -ForegroundColor Green
                if ($PSCmdlet.ParameterSetName -eq 'SYNC_OFFLINE'){
                    Write-Host ('Load Offline Catalog from '+ ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName) +' ...')
                    $myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName)
                }
                if ($null -ne $myRepositoryItems){
                    Write-Host 'Publish DatabaseDacPac ...' -ForegroundColor Green
                    $null=$myRepositoryItems | Where-Object -Property Category -eq SqlDeepDatabase | ForEach-Object{
                        Write-Host ('Generate DatabaseDacPac report file ' + $LocalRepositoryPath + '\' + $_.FileName + '.report') -ForegroundColor Green;
                        Get-PrePublishReport -DacpacFilePath ($LocalRepositoryPath+'\'+$_.FileName) -ConnectionString $ConnectionString -ReportFilePath ($LocalRepositoryPath+'\'+$_.FileName+'.report');
                        Write-Host ('Publish DatabaseDacPac file ' + $LocalRepositoryPath + '\' + $_.FileName) -ForegroundColor Green;
                        Publish-DatabaseDacPac -DacpacFilePath ($LocalRepositoryPath+'\'+$_.FileName) -ConnectionString $ConnectionString;
                    }
                }else{
                    Write-Host 'Catalog is empty.' -ForegroundColor Red
                }
            }
            if ($SyncScriptRepository) {
                Write-Host 'SyncScriptRepository ...' -ForegroundColor Green
                if ($PSCmdlet.ParameterSetName -eq 'SYNC_OFFLINE'){
                    Write-Host ('Load Offline Catalog from '+ ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName) +' ...')
                    $myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName)
                }
                if ($null -ne $myRepositoryItems){
                    Write-Host 'Publish DatabaseRepositoryScripts ...' -ForegroundColor Green
                    Publish-DatabaseRepositoryScripts -LocalRepositoryPath $LocalRepositoryPath -ConnectionString $ConnectionString -SqlDeepRepositoryItems $myRepositoryItems
                }else{
                    Write-Host 'Catalog is empty.' -ForegroundColor Red
                }
            }
        }
        end{
            Write-Host ('Sync-SqlDeep finished.')
        }
    }
#endregion

#<#SqlDeep-Comment
#region Export
Export-ModuleMember -Function Sync-SqlDeep
#endregion

#---------MAIN
if ($LocalRepositoryPath[-1] -eq '\'){
    $LocalRepositoryPath=$LocalRepositoryPath.Substring(0,$LocalRepositoryPath.Length-1)
}
[RepositoryItem[]]$myRepositoryItems=$null
if ($DownloadAssets) {
    Write-Host 'Download ...' -ForegroundColor Green
    $myRepositoryItems=Download-RepositoryItems -LocalRepositoryPath $LocalRepositoryPath
}
if ($SyncDatabaseModule) {
    Write-Host 'SyncDatabaseModule ...' -ForegroundColor Green
    if ($PSCmdlet.ParameterSetName -eq 'SYNC_OFFLINE'){
        Write-Host ('Load Offline Catalog from '+ ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName) +' ...')
        $myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName)
    }
    if ($null -ne $myRepositoryItems){
        Write-Host 'Generate Diff Report and Publish DatabaseDacPac ...' -ForegroundColor Green
        $null=$myRepositoryItems | Where-Object -Property Category -eq SqlDeepDatabase | ForEach-Object{
            Write-Host ('Generate DatabaseDacPac report file ' + $LocalRepositoryPath + '\' + $_.FileName + '.report') -ForegroundColor Green;
            Get-PrePublishReport -DacpacFilePath ($LocalRepositoryPath+'\'+$_.FileName) -ConnectionString $ConnectionString -ReportFilePath ($LocalRepositoryPath+'\'+$_.FileName+'.report');
            Write-Host ('Publish DatabaseDacPac file ' + $LocalRepositoryPath + '\' + $_.FileName) -ForegroundColor Green;
            Publish-DatabaseDacPac -DacpacFilePath ($LocalRepositoryPath+'\'+$_.FileName) -ConnectionString $ConnectionString;
        }
    }else{
        Write-Host 'Catalog is empty.' -ForegroundColor Red
    }
}
if ($SyncScriptRepository) {
    Write-Host 'SyncScriptRepository ...' -ForegroundColor Green
    if ($PSCmdlet.ParameterSetName -eq 'SYNC_OFFLINE'){
        Write-Host ('Load Offline Catalog from '+ ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName) +' ...')
        $myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName)
    }
    if ($null -ne $myRepositoryItems){
        Write-Host 'Publish DatabaseRepositoryScripts ...' -ForegroundColor Green
        Publish-DatabaseRepositoryScripts -LocalRepositoryPath $LocalRepositoryPath -ConnectionString $ConnectionString -SqlDeepRepositoryItems $myRepositoryItems
    }else{
        Write-Host 'Catalog is empty.' -ForegroundColor Red
    }
}
#SqlDeep-Comment#>



# SIG # Begin signature block
# MIIbxQYJKoZIhvcNAQcCoIIbtjCCG7ICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCKK3rRITMiQXQO
# eXw7mVKPjo6xfnQkkyrVDt8NPeYyVKCCFhswggMUMIIB/KADAgECAhAT2c9S4U98
# jEh2eqrtOGKiMA0GCSqGSIb3DQEBBQUAMBYxFDASBgNVBAMMC3NxbGRlZXAuY29t
# MB4XDTI0MTAyMzEyMjAwMloXDTI2MTAyMzEyMzAwMlowFjEUMBIGA1UEAwwLc3Fs
# ZGVlcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDivSzgGDqW
# woiD7OBa8twT0nzHGNakwZtEzvq3HcL8bCgfDdp/0kpzoS6IKpjt2pyr0xGcXnTL
# SvEtJ70XOgn179a1TlaRUly+ibuUfO15inrwPf1a6fqgvPMoXV6bMxpsbmx9vS6C
# UBYO14GUN10GtlQgpUYY1N0czabC7yXfo8EwkO1ZTGoXADinHBF0poKffnR0EX5B
# iL7/WGRfT3JgFZ8twYMoKOc4hJ+GZbudtAptvnWzAdiWM8UfwQwcH8SJQ7n5whPO
# PV8e+aICbmgf9j8NcVAKUKqBiGLmEhKKjGKaUow53cTsshtGCndv5dnMgE2ppkxh
# aWNn8qRqYdQFAgMBAAGjXjBcMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAWBgNVHREEDzANggtzcWxkZWVwLmNvbTAdBgNVHQ4EFgQUwoHZNhYd
# VvtzY5g9WlOViG86b8EwDQYJKoZIhvcNAQEFBQADggEBAAvLzZ9wWrupREYXkcex
# oLBwbxjIHueaxluMmJs4MSvfyLG7mzjvkskf2AxfaMnWr//W+0KLhxZ0+itc/B4F
# Ep4cLCZynBWa+iSCc8iCF0DczTjU1exG0mUff82e7c5mXs3oi6aOPRyy3XBjZqZd
# YE1HWl9GYhboC5kY65Z42ZsbNyPOM8nhJNzBKq9V6eyNE2JnxlrQ1v19lxXOm6WW
# Hgnh++tUf9k8DI1D7Da3bQqsj8O+ACHjhjMVzWKqAtnDxydaOOjRhKWIlHUQ7fLW
# GYFZW2JXnogqxFR2tzdpZxsNgD4vHFzt1CspiHzhIsMwfQFxIg44Ny/U96l2aVpR
# 6lUwggWNMIIEdaADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUA
# MGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
# EHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQg
# Um9vdCBDQTAeFw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqcl
# LskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YF
# PFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceIt
# DBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZX
# V59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1
# ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2Tox
# RJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdp
# ekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF
# 30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9
# t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQ
# UOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXk
# aS+YHS312amyHeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1Ud
# DgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEt
# UYunpyGd823IDzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAw
# DQYJKoZIhvcNAQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyF
# XqkauyL4hxppVCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76
# LVbP+fT3rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8L
# punyNDzs9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2
# CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si
# /xK4VC0nftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQwggauMIIElqADAgEC
# AhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMw
# MDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0
# MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la
# 9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4r
# gISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/Z
# kIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y
# 3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6ws
# OeKlSNbwsDETqVcplicu9Yemj052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz
# 9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4
# xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB
# 7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhK
# WD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8e
# CXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQAB
# o4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3Mp
# dpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYD
# VR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGsw
# aTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUF
# BzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVk
# Um9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeB
# DAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQi
# AX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+Vc
# W9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/
# q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6Wvep
# ELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoar
# CkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJS
# pzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrk
# nq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f5
# 6PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2Bn
# FqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ
# 8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW
# +6kvRBVK5xMOHds3OBqhK/bt1nz8MIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnp
# BOMzBDANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5
# NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEy
# NTIzNTk1OVowQjELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYD
# VQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQAD
# ggIPADCCAgoCggIBAL5qc5/2lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBD
# Er4IxHRGd7+L660x5XltSVhhK64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo
# 76EO7o5tLuslxdr9Qq82aKcpA9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rO
# H3bpLEx7pZ7avVnpUVmPvkxT8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9R
# eNZ8hIOYe4jl7/r419CvEYVIrH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgX
# j3o5WHhHVO+NBikDO0mlUh902wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTV
# DSupWJNstVkiqLq+ISTdEjJKGjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16J
# idj5XiPVdsn5n10jxmGpxoMc6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/C
# acBqU0R4k+8h6gYldp4FCMgrXdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93N
# Rxvd1aepSeNeREXAu2xUDEW8aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1X
# CB+1rxvbKmLqfY/M/SdV6mwWTyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMB
# AAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1s
# BwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9X
# LAN3DigVkGalY17uT5IfdqBbMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNl
# cnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZU
# aW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQS
# R9lDkfYR25tOCB3RKE/P09x7gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWB
# b0HvqT00nFSXgmUrDKNSQqGTdpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDC
# zFzUy34VarPnvIWrqVogK0qM8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1
# UruJKlTnCVaM2UeUUW/8z3fvjxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3Wp
# ByXtgVQxiBlTVYzqfLDbe9PpBKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGE
# sshJmLbJ6ZbQ/xll/HjO9JbNVekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8
# a1u7cIqV0yef4uaZFORNekUgQHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNF
# YagLDBzpmk9104WQzYuVNsxyoVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7Q
# EY7MhKRyrBe7ucykW7eaCuWBsBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgE
# deoHNHT9l3ZDBD+XgbF+23/zBjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/J
# ceENc2Sg8h3KeFUCS7tpFk7CrDqkMYIFADCCBPwCAQEwKjAWMRQwEgYDVQQDDAtz
# cWxkZWVwLmNvbQIQE9nPUuFPfIxIdnqq7ThiojANBglghkgBZQMEAgEFAKCBhDAY
# BgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEi
# BCDkqA5lPkjVvpVZ7q7swy1znVX6n97liaMgcmj+kHiOGTANBgkqhkiG9w0BAQEF
# AASCAQBBQkWjoCb224AVC2ufHUXHMZDZdhimktafGDDD1u71AtRvCVrF+VKKNQcC
# kd8Z1kdjXC9c1vFWPSdEAmx8kUxiPPvf4IB4LTR0NDzUvYrWgzb2h+e0oeZFN2Ib
# wXBPETrALnloh22hla2GBKO4kgEJpvu/VQZqQxPwY5c9pcnu/n9I4XiTlCGRTl1b
# 1wS4PJueuLKiwekLsmMoT0bAnr+nswZFh0LL7UiZq36IFrXXVapisX0dfIJxDeVy
# Pqm+Jzg/IjoESzGt96fy/JrxSDMizgWxfoUPUjqhonsj0M38FSDxwqV+yZLfDlFt
# aCxUBp1JgfEErlpHZlQm0Y6OwK0UoYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJ
# AgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTsw
# OQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVT
# dGFtcGluZyBDQQIQC65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgEFAKBpMBgG
# CSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI0MTExMDIx
# NDUxN1owLwYJKoZIhvcNAQkEMSIEIN7eIqg44doBQFq0VOMiQO7YW1GpqXUC+RMf
# A6w+UwozMA0GCSqGSIb3DQEBAQUABIICACBVjeh295sIR8Al10p68EuG1XqTkNY/
# p7P41JA54xheSrvu77qbr5+Vm2Gn9UsAn/Uaww+CftuwvZdQ3NhKAFR0UXIjKszi
# H+Lnd2PYKFqIr+T9W4P1Wk6eVEkaJNh8zFhl7NMY9eA8qhHyI18R0/KvNHI4+iSs
# NBmfQgM3gXcQ1xaJwJN7K0NpjGSk46S5R9HK205S+lpkjm8MTgOZbnIjGzYB3phE
# VKF1xGiiCT3MFoloG1Z4lAf+GeXEESh8oCAPULx2KMsrLMOR4LVkmqxifbG3zGDl
# wPALtlL8Iz2hd7xxs6W3AHvEdpshbKJiC8THoPEV6+DbcoH5FTSAbINvbogk6YNB
# Jh07jmKv08ziV84RY/xUe5NjcUABlJisuNJiq3WKzaY3vEXNfPSdk2wuhnDTnUpn
# zzkwDUvwZrON81tUcaDwMf9SW6N4Ufh7hdKK+bFnvgX/gO97A8oJ2Z1GLZwvtPtT
# mZ7Zt0mpaPQFsN7WNIqFWKX+c6DXDRj+KrIufR9yr1+hfFpxw24adN0uu1y6yKN3
# pQwDP8OmkPDsDpuVHhJS9UztJlleWyTFFKNLRRoZfOWMP91AuVAmSslyhpq1Y2F3
# EQFr/Je5cmZ6eJbCoxcAUY34GWcOChKbFrJ72OAHhEUxuZGwc6qcBrm3yIQU0/+A
# P1i9JLSsaHek
# SIG # End signature block
