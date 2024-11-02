<#-----Parameters
Download
    SqlDeepDB
    PowershellTools
Deploy
    SqlDeepDB
    PowershellTools
#>
[string]$LocalRepositoryPath='E:\Log\SqlDeep'

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
   
    WebRepositoryItem([SqlDeepRepositoryItemCategory]$Category,[string]$FileURI,[string]$LocalFolderPath,[string]$LocalFileName){
        Write-Verbose 'WebRepositoryItem object initializing started'
        $this.Category=$Category
        $this.FileURI=$FileURI
        $this.LocalFolderPath=$LocalFolderPath
        $this.LocalFileName=$LocalFileName
        Write-Verbose 'WebRepositoryItem object initialized'
    }
}

function DownloadFile {
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
        return $mtAnswer
    }
    end{}
}
#===============Parameters
[string]$mySqlDeepOfficialCatalogURI=$null;
[WebRepositoryItem[]]$myWebRepositoryCollection=$null;
[WebRepositoryItem]$myWebRepositoryItem=$null;
#===============Constants
$mySqlDeepOfficialCatalogURI='https://raw.githubusercontent.com/SiavashGolchoobian/SqlDeep-Synchronizer/refs/heads/main/SqlDeepCatalog.json'
$myWebRepositoryItem=[WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepCatalog,$mySqlDeepOfficialCatalogURI,$LocalRepositoryPath,'SqlDeepCatalog.json')
$myWebRepositoryCollection+=($myWebRepositoryItem)
#Download Catalog file(s)
$myWebRepositoryCollection | Where-Object -Property Category -eq SqlDeepCatalog | ForEach-Object{DownloadFile -URI ($_.FileURI) -FolderPath ($_.LocalFolderPath) -FileName ($_.LocalFileName)}
#Fill RepositoryCollection via Catalog file(s)
foreach ($myWebRepositoryItem in ($myWebRepositoryCollection | Where-Object -Property Category -eq SqlDeepCatalog)) {
    $myResult=Get-Content -Raw -Path ($myWebRepositoryItem.LocalFolderPath+'\'+$myWebRepositoryItem.LocalFileName) | ConvertFrom-Json
    $myResult.library.SqlDeepPowershellTools    | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepPowershellTools,($_.uri),$LocalRepositoryPath,($_.name)))}
    $myResult.library.SqlDeepDatabase           | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepDatabase,($_.uri),$LocalRepositoryPath,($_.name)))}
    $myResult.library.SqlDeepTsqlScript         | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepTsqlScript,($_.uri),$LocalRepositoryPath,($_.name)))}
}
#Download non-catalog type Repository Contents
$myWebRepositoryCollection | Where-Object -Property Category -ne SqlDeepCatalog | ForEach-Object{DownloadFile -URI ($_.FileURI) -FolderPath ($_.LocalFolderPath) -FileName ($_.LocalFileName)}