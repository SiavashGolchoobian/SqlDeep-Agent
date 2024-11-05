enum SqlDeepRepositoryItemCategory {
    SqlDeepCatalog
    SqlDeepDatabase
    SqlDeepPowershellTools
    SqlDeepSynchronizerTools
    SqlDeepTsqlScript
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
            if((Test-Path -Path $FilePath -PathType Leaf) -eq $true) {
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
[RepositoryItem[]]$myRepositoryItems=$null
$myRepositoryItems=ConvertFrom-RepositoryItemsFile -FilePath 'E:\Log\SqlDeep\SqlDeepCatalog.json.result'

#.\SqlDeepSynchronizer.ps1 -DownloadAssets -LocalRepositoryPath 'E:\Log\SqlDeep'
#.\SqlDeepSynchronizer.ps1 -SyncScriptRepository -LocalRepositoryPath 'E:\Log\SqlDeep' -SqlDeepRepositoryItemsFileName 'SqlDeepCatalog.json.result' -ConnectionString 'Data Source=172.18.3.49,2019;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=Armin1355$'
#.\SqlDeepSynchronizer.ps1 -SyncDatabaseModule -LocalRepositoryPath 'E:\Log\SqlDeep' -SqlDeepRepositoryItemsFileName 'SqlDeepCatalog.json.result' -ConnectionString 'Data Source=172.18.3.49,2019;Initial Catalog=SqlDeep;TrustServerCertificate=True;Encrypt=True;User=sa;Password=Armin1355$'