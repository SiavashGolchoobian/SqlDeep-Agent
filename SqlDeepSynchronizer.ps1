<#-----Parameters
Download
    SqlDeepDB
    PowershellTools
Deploy
    SqlDeepDB
    PowershellTools
#>
[string]$LocalRepositoryRoot='E:\Log\SqlDeep'
[string]$myCurrentPath='C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer'

enum SqlDeepRepositoryItemCategory {
    SqlDeepCatalog
    SqlDeepDatabase
    SqlDeepPowershellTools
}
Class WebRepositoryItem {
    [SqlDeepRepositoryItemCategory]$Category
    [string]$FileName
    [string]$FileURI
    [string]$LocalFilePath
   
    WebRepositories([SqlDeepRepositoryItemCategory]$Category,[string]$FileName,[string]$FileURI){
        Write-Verbose 'WebRepositoryItem object initializing started'
        $this.Category=$Category
        $this.FileName=$FileName
        $this.FileURI=$FileURI
        $this.LocalFilePath=$null
        Write-Verbose 'WebRepositoryItem object initialized'
    }
}

[WebRepositoryItem[]]$myWebRepositoryCollection=$null
[WebRepositoryItem]$myWebRepositoryItem=$null

$myWebRepositoryItem=[WebRepositoryItem]::New([WebRepositoryItem]::SqlDeepCatalog,'SqlDeepCatalog.txt','',$null)
#Initialize Repository
$mySqlDeepRepositories

#Create Local Repository Root folder if not exists
if((Test-Path -Path $LocalRepositoryRoot) -eq $false) {
    New-Item -ItemType Directory -Path $LocalRepositoryRoot -Force
}

#='https://github.com/SiavashGolchoobian/SqlDeep/raw/refs/heads/main/Assets/Release/Latest/SqlDeep.dacpac'
#Download Repository Contents
Invoke-WebRequest -Uri $myLocalRepositoryRoot -OutFile .\helloworld.ps1