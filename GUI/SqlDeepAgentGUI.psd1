@{
    Root = 'C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Agent\GUI\Out\SqlDeepAgentGUI.ps1'
    OutputPath = 'C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Agent\GUI\Out'
    #OutputPath = 'D:\Out'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.6.2'
        PowerShellVersion = 'Windows PowerShell'
        #DotNetVersion = 'net4.7.0'                     bad
        #PowerShellVersion = 'Windows PowerShell'       bad
        #DotNetVersion = 'net4.7.1'
        #PowerShellVersion = 'Windows PowerShell'
        #DotNetVersion = 'net4.7.2'                     bad
        #PowerShellVersion = 'Windows PowerShell'       bad
        #DotNetVersion = 'net4.8.0'
        #PowerShellVersion = 'Windows PowerShell'
        #DotNetVersion = 'net8.0'
        #PowerShellVersion = '7.4.0'
        #DotNetVersion = 'net5.0'       bad
        #PowerShellVersion = '7.1.4'    bad
        FileVersion = '1.0.1'
        FileDescription = 'SqlDeep Agent'
        ProductName = 'SqlDeep Agent'
        ProductVersion = '1.0.6'
        Copyright = 'SqlDeep'
        RequireElevation = $false
        ApplicationIconPath = 'C:\Users\Siavash\Dropbox\SQL Deep\Logo\SqlDeepV4.ico'
        PackageType = 'Console'
        Company = 'Bina Management'
        Resources = [string[]]@('SqlDeepPublic.cer','DacFramework_161.msi')
        Certificate = 'Cert:\CurrentUser\My\CFF6B983B70FA11FCDD3C7CFC68F724E903A01B4'
    }
}
        