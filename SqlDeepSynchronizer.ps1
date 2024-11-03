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
    [bool]$IsValid
   
    WebRepositoryItem([SqlDeepRepositoryItemCategory]$Category,[string]$FileURI,[string]$LocalFolderPath,[string]$LocalFileName){
        Write-Verbose 'WebRepositoryItem object initializing started'
        $this.Category=$Category
        $this.FileURI=$FileURI
        $this.LocalFolderPath=$LocalFolderPath
        $this.LocalFileName=$LocalFileName
        $this.IsValid=$true
        Write-Verbose 'WebRepositoryItem object initialized'
    }
    [string] FilePath(){
        return $this.LocalFolderPath+'\'+$this.LocalFileName
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
function DownloadSqlDeepRepositoryItems(){
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="URI address to download")][string]$LocalRepositoryPath
    )
    begin{
        #===============Parameters
        [string]$mySqlDeepOfficialCatalogURI=$null;
        [WebRepositoryItem[]]$myWebRepositoryCollection=$null;
        [WebRepositoryItem]$myWebRepositoryItem=$null;
        #===============Constants
        $mySqlDeepOfficialCatalogURI='https://github.com/SiavashGolchoobian/SqlDeep-Synchronizer/raw/refs/heads/main/SqlDeepCatalog.json'
        $myInstalledCertificate = (Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object -Property Subject -eq 'CN=sqldeep.com'); 
        if ($LocalRepositoryPath[-1] -eq '\') {$LocalRepositoryPath=$LocalRepositoryPath.Substring(0,$LocalRepositoryPath.Length-1)}
        $myWebRepositoryItem=[WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepCatalog,$mySqlDeepOfficialCatalogURI,$LocalRepositoryPath,'SqlDeepCatalog.json')
        $myWebRepositoryCollection+=($myWebRepositoryItem)
    }
    process{
        #Download Catalog file(s)
        $myWebRepositoryCollection | Where-Object -Property Category -eq SqlDeepCatalog | ForEach-Object{DownloadFile -URI ($_.FileURI) -FolderPath ($_.LocalFolderPath) -FileName ($_.LocalFileName)}
        #Fill RepositoryCollection via Catalog file(s)
        foreach ($myWebRepositoryItem in ($myWebRepositoryCollection | Where-Object -Property Category -eq SqlDeepCatalog)) {
            $myResult=Get-Content -Raw -Path ($myWebRepositoryItem.FilePath()) | ConvertFrom-Json
            $myResult.library.SqlDeepPowershellTools    | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepPowershellTools,($_.uri),$LocalRepositoryPath,($_.name)))}
            $myResult.library.SqlDeepDatabase           | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepDatabase,($_.uri),$LocalRepositoryPath,($_.name)))}
            $myResult.library.SqlDeepTsqlScript         | Where-Object -Property uri -ne $null | ForEach-Object{$myWebRepositoryCollection+=([WebRepositoryItem]::New([SqlDeepRepositoryItemCategory]::SqlDeepTsqlScript,($_.uri),$LocalRepositoryPath,($_.name)))}
        }
        #Download non-catalog type Repository Contents
        $myWebRepositoryCollection | Where-Object -Property Category -ne SqlDeepCatalog | ForEach-Object{DownloadFile -URI ($_.FileURI) -FolderPath ($_.LocalFolderPath) -FileName ($_.LocalFileName)}
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
    end{}
}

DownloadSqlDeepRepositoryItems -LocalRepositoryPath 'E:\log\SqlDeep'