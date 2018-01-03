function Add-Zip () {
    <#
    .SYNOPSIS
        Makes an Archive (Backup) of an IIS Site
    .DESCRIPTION
        Function creates an Archive of the specified site, using the Site details retrieived from Get-Sites
    .PARAMETER Site
        IIS Site name to archive
    .EXAMPLE
        Calling the function with no parameters will ask for the specific site to use
        > New-SiteArchive

        You can also pass the specific site to use, using the -Site parameter
        > New-SiteArchive -Site MySite
    .NOTES
        Author: Mike Pruett
        Date: September 12th, 2017

        https://stackoverflow.com/questions/11021879/creating-a-zipped-compressed-folder-in-windows-using-powershell-or-the-command-l
    #>
    [CmdletBinding()]
    param(
        [string]$zipfilename
    )
    if (-not ( Test-Path($zipfilename)) )
    {
        set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (dir $zipfilename).IsReadOnly = $false  
    }

    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfilename)

    foreach($file in $input) 
    { 
            $zipPackage.CopyHere($file.FullName)
            Start-sleep -milliseconds 500
    }
}

# Function ArchiveSite {
#     Param (
#         [string]$target,
#         [string]$destination,
#         [string]$filename
#     )
#     # Environment variable conversion
#     switch -wildcard ($target) {
#         "%SystemDrive%*" { $target = $target | foreach {$_ -replace "%SystemDrive%","$Env:SystemDrive"} }
#     }
#     Write-Host $target
#     # Determin .NET Framework Version
#     [int]$DotNetVersion = (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' | Sort-Object PSChildName -Des | Select-Object -First 1 -ExpandProperty PSChildName).TrimStart("v")
#     # If .NET Framework v4.5 installed (or Greater)i
#     # http://stackoverflow.com/questions/3487265/powershell-script-to-return-versions-of-net-framework-on-a-machine
#     If ($DotNetVersion -ge 4.5) {
#         # . NET Zip Creation Method
#         # http://blogs.technet.com/b/heyscriptingguy/archive/2015/03/09/use-powershell-to-create-zip-archive-of-folder.aspx
#         Write-Host ".NET"
#         Add-Type -assembly "System.IO.Compression.FileSystem"
#         [IO.Compression.ZipFile]::CreateFromDirectory("$target", "$destination\$filename")
#     } else {
#         # 7Zip Creation Method
#         # http://stackoverflow.com/questions/11021879/creating-a-zipped-compressed-folder-in-windows-using-powershell-or-the-command-l
#         # http://ithinkthereforeiehlo.com/create-a-zip-file-or-unzip-in-powershell/
#         Write-Host "Zip"

#         $TargetDir = Get-ChildItem -Path $target -Recurse
#         $zipfilename = $destination + "\" + $filename

#         If (-not (Test-Path($zipfilename))) {
#             Set-Content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
#             (dir $zipfilename).IsReadOnly = $false
#         }

#         $shellApplication = New-Object -com Shell.Application
#         $zipfilename = [IO.Path]::GetFullPath($zipfilename)
#         $zipPackage = $shellApplication.NameSpace($zipfilename)

#         ForEach ($file in $TargetDir) {
#             $zipPackage.CopyHere($file.FullName)
#             Start-sleep -milliseconds 100
#         }
#     }
# }