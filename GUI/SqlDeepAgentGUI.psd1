@{
    Root = 'C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\GUI\SqlDeepAgentGUI.ps1'
    OutputPath = 'C:\Users\Siavash\Dropbox\SQL Deep\Tools\SqlDeep Projects\SqlDeep-Synchronizer\GUI\SqlDeepAgentGUIBundle.ps1'
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
        FileVersion = '1.0.0'
        FileDescription = 'SqlDeep Synchronizer Agent'
        ProductName = 'SqlDeep Synchronizer'
        ProductVersion = '1.0.0'
        Copyright = 'SqlDeep'
        RequireElevation = $false
        ApplicationIconPath = 'C:\Users\Siavash\Dropbox\SQL Deep\Logo\SqlDeepV4.ico'
        PackageType = 'Console'
        Company = 'Bina Management'
        Certificate = 'Cert:\CurrentUser\My\CFF6B983B70FA11FCDD3C7CFC68F724E903A01B4'
    }
}
        