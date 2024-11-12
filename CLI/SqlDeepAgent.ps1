#<#SqlDeep-Comment
param (
    [Parameter(Mandatory=$true,HelpMessage="Folder path including downloaded items")][string]$LocalRepositoryPath,
    [Parameter(Mandatory=$false,HelpMessage="Target database connection string")][ValidateNotNullOrEmpty()][string]$ConnectionString,
    [Parameter(Mandatory=$false,HelpMessage="SqlDeep RepositoryItems file path")]$SqlDeepRepositoryItemsFileName,
    [Parameter(Mandatory=$false)][Switch]$DownloadAssets,
    [Parameter(Mandatory=$false)][Switch]$CompareDatabaseModule,
    [Parameter(Mandatory=$false)][Switch]$SyncDatabaseModule,
    [Parameter(Mandatory=$false)][Switch]$SyncScriptRepository
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
                if ($myCustomInstallLocation -ne '' -and $null -ne $myCustomInstallLocation) {
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
                Write-Host 'DacPac module does not found, please Downloaded and install it from official site https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-ver16 or install informal version from https://www.powershellgallery.com/packages/PublishDacPac/ or run this command in powershell console: Install-Module -Name PublishDacPac'
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
            [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Target database connection string")][ValidateNotNullOrEmpty()][string]$ConnectionString,
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="SqlDeep RepositoryItems file path")]$SqlDeepRepositoryItemsFileName,
            [Parameter(Mandatory=$false)][Switch]$DownloadAssets,
            [Parameter(Mandatory=$false)][Switch]$CompareDatabaseModule,
            [Parameter(Mandatory=$false)][Switch]$SyncDatabaseModule,
            [Parameter(Mandatory=$false)][Switch]$SyncScriptRepository
        )
        begin{
            Write-Host ('Sync-SqlDeep started.')
            if ($LocalRepositoryPath[-1] -eq '\'){
                $LocalRepositoryPath=$LocalRepositoryPath.Substring(0,$LocalRepositoryPath.Length-1)
            }
        }
        process{
            [RepositoryItem[]]$myRepositoryItems=$null
            [string]$myReportFilePath=$null
            if ($DownloadAssets) {
                Write-Host 'Download ...' -ForegroundColor Green
                $myRepositoryItems=Download-RepositoryItems -LocalRepositoryPath $LocalRepositoryPath
            }else{
                Write-Host ('Load Catalog from '+ ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName) +' ...')
                $myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName)
            }

            if ($CompareDatabaseModule) {
                Write-Host 'CompareDatabaseModule ...' -ForegroundColor Green
                if ($null -ne $myRepositoryItems){
                    Write-Host 'Generate Diff Report ...' -ForegroundColor Green
                    $null=$myRepositoryItems | Where-Object -Property Category -eq SqlDeepDatabase | ForEach-Object{
                        $myReportFilePath=$LocalRepositoryPath + '\' + $_.FileName + (Get-Date -Format "yyyyMMdd_HHmmss").ToString() + '.report.xml';
                        Write-Host ('Generating DatabaseDacPac report to file ' + $myReportFilePath) -ForegroundColor Green;
                        Get-PrePublishReport -DacpacFilePath ($LocalRepositoryPath+'\'+$_.FileName) -ConnectionString $ConnectionString -ReportFilePath $myReportFilePath;
                        Write-Host ('DatabaseDacPac report was generated on file ' + $myReportFilePath) -ForegroundColor Green;
                    }
                }else{
                    Write-Host 'Catalog is empty.' -ForegroundColor Red
                }
            }
            if ($SyncDatabaseModule) {
                if ($null -ne $myRepositoryItems){
                    Write-Host 'Publish DatabaseDacPac ...' -ForegroundColor Green
                    $null=$myRepositoryItems | Where-Object -Property Category -eq SqlDeepDatabase | ForEach-Object{
                        Write-Host ('Publish DatabaseDacPac file ' + $LocalRepositoryPath + '\' + $_.FileName) -ForegroundColor Green;
                        Publish-DatabaseDacPac -DacpacFilePath ($LocalRepositoryPath+'\'+$_.FileName) -ConnectionString $ConnectionString;
                    }
                }else{
                    Write-Host 'Catalog is empty.' -ForegroundColor Red
                }
            }
            if ($SyncScriptRepository) {
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

#region Export
#Export-ModuleMember -Function Sync-SqlDeep
#endregion

#<#SqlDeep-Comment
#---------MAIN
if ($LocalRepositoryPath[-1] -eq '\'){
    $LocalRepositoryPath=$LocalRepositoryPath.Substring(0,$LocalRepositoryPath.Length-1)
}
[RepositoryItem[]]$myRepositoryItems=$null
[string]$myReportFilePath=$null

if ($DownloadAssets) {
    Write-Host 'Download ...' -ForegroundColor Green
    $myRepositoryItems=Download-RepositoryItems -LocalRepositoryPath $LocalRepositoryPath
}else{
    Write-Host ('Load Catalog from '+ ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName) +' ...')
    $myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath ($LocalRepositoryPath+'\'+$SqlDeepRepositoryItemsFileName)
}

if ($CompareDatabaseModule) {
    Write-Host 'CompareDatabaseModule ...' -ForegroundColor Green
    if ($null -ne $myRepositoryItems){
        Write-Host 'Generate Diff Report ...' -ForegroundColor Green
        $null=$myRepositoryItems | Where-Object -Property Category -eq SqlDeepDatabase | ForEach-Object{
            $myReportFilePath=($LocalRepositoryPath + '\' + $_.FileName + (Get-Date -Format "yyyyMMdd_HHmmss").ToString() + '.report.xml');
            Write-Host ('Generating DatabaseDacPac report to file ' + $myReportFilePath) -ForegroundColor Green;
            Get-PrePublishReport -DacpacFilePath ($LocalRepositoryPath+'\'+$_.FileName) -ConnectionString $ConnectionString -ReportFilePath $myReportFilePath;
            Write-Host ('DatabaseDacPac report was generated on file ' + $myReportFilePath) -ForegroundColor Green;
        }
    }else{
        Write-Host 'Catalog is empty.' -ForegroundColor Red
    }
}
if ($SyncDatabaseModule) {
    Write-Host 'SyncDatabaseModule ...' -ForegroundColor Green
    if ($null -ne $myRepositoryItems){
        Write-Host 'Publish DatabaseDacPac ...' -ForegroundColor Green
        $null=$myRepositoryItems | Where-Object -Property Category -eq SqlDeepDatabase | ForEach-Object{
            Write-Host ('Publish DatabaseDacPac file ' + $LocalRepositoryPath + '\' + $_.FileName) -ForegroundColor Green;
            Publish-DatabaseDacPac -DacpacFilePath ($LocalRepositoryPath+'\'+$_.FileName) -ConnectionString $ConnectionString;
        }
    }else{
        Write-Host 'Catalog is empty.' -ForegroundColor Red
    }
}
if ($SyncScriptRepository) {
    Write-Host 'SyncScriptRepository ...' -ForegroundColor Green
    if ($null -ne $myRepositoryItems){
        Write-Host 'Publish DatabaseRepositoryScripts ...' -ForegroundColor Green
        Publish-DatabaseRepositoryScripts -LocalRepositoryPath $LocalRepositoryPath -ConnectionString $ConnectionString -SqlDeepRepositoryItems $myRepositoryItems
    }else{
        Write-Host 'Catalog is empty.' -ForegroundColor Red
    }
}
#SqlDeep-Comment#>





































# SIG # Begin signature block
# MIIFngYJKoZIhvcNAQcCoIIFjzCCBYsCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBpTr7lHuPGWLKw
# xlSuT6Nm9PpSc83Ca4DvIiZ9TvjTaaCCAxgwggMUMIIB/KADAgECAhAT2c9S4U98
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
# 6lUxggHcMIIB2AIBATAqMBYxFDASBgNVBAMMC3NxbGRlZXAuY29tAhAT2c9S4U98
# jEh2eqrtOGKiMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHTQZ4RwKNdCOC7QC+YHWOhw
# JeLvpdgyX7KeMHYPyvi9MA0GCSqGSIb3DQEBAQUABIIBAHqaKVGuwFTLmSwBZzfu
# m5ENOzV7ahIvzVXX8+Z8UsRBWj14mGomlVZa3Jqx4xSyxY1C1iSHg7RB4MKS2ONm
# xUdAuMtRMKcSZSg7ZAx0QYAt+PI40nLWkA1z9C1l2s0arVx0kTo+Unma6DyZtvBP
# Tu7gWcQPPJe6m+qrnLIvbuV45ywA26A7Li4tr8gOP8HjnDycSkMPlXyabV01enCs
# Klzof7ZZz+a94JnFQjkkMw7DaXo2qlFRz2O1cJTqpNHyZsZt4N8x1vqNgEUN/m+T
# tRJyAmmESeJIeieQuEukE2OlNm0LlhaeUjuzkATvIoYOKBDogYQ+4VbPwUq0f8Pl
# zk4=
# SIG # End signature block
