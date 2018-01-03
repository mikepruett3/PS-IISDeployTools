# PS-IISDeployTools

A custom module of PowerShell cmdlets to aide in IIS Site Deployments.

**NOTE:** *Cmdlets are built around the WebAdministration PowerShell module, not the latest IISAdministration module. This provides compatibility with older Windows IIS Deployments that are not running on Windows Server 2016.*

# Installation

The PS-IISDeployTools module is now maintained in a Local PowerShellGet (NuGet) Repository, hosted on DFS File Server. The following instructions will assist with getting the module installed.

1. Determine if the current Operating System ships with the PowerShell Package Management Tools, or if you will need to install them. Refer to the following table for PowerShellGet Compatibility:

| Operating System  | Package Management Tools |
|-------------------|--------------------------|
| Windows Server 2008 | Missing (Need to install) |
| Windows Server 2008 R2 | Missing (Need to install) |
| Windows Server 2012 R2 | Missing (Need to install) |
| Windows Server 2016 | Already Installed |

**NOTE** *If the Package Management Tools are not installed on the server, you can download them from [Microsoft's Website](https://www.microsoft.com/en-us/download/details.aspx?id=49186). Alternatively, you can find a copy of both the Package Management Tools for both 32-bit and 64-bit servers on the Software Share.*

2. Install the Package Management Tools

3. Create the Local NuGet Repository connection on the server. *This is completed under an elevated PowerShell prompt.*

    ```PowerShell
    $Path = '\\dfsfileserver\PSRepo_NewRepo'
    Import-Module PowerShellGet
    $repo = @{
        Name = 'EngineeringRepo'
        SourceLocation = $Path
        PublishLocation = $Path
        InstallationPolicy = 'Trusted'
    }
    Register-PSRepository @repo

4. Verify that the new PSRepository is visible

    ```PowerShell
    Find-Module -Repository EngineeringRepo
5. Once the connection to the new local PSRepository is established, install PS-IISDeployTools

    ```PowerShell
    Install-Module -Name PS-IISDeployTools -Repository EngineeringRepo
# Usage

Once the PS-IISDeployTools module is installed, use the newly added cmdlets to automate IIS operations.

## Cmdlets Included

| Cmdlet | Description |
|:----------------|:-------------------------------------------|
| New-SiteArchive | Create a ZIP-file Backup of a site in IIS. |
| New-SiteCopy | Create a Folder-Copy Backup of a site in IIS. The Destination Folder will be named starting with "original.", and ending with a time-stamp. |
| Publish-Site | Deploys the Target Codebase to the specified site. |
| Copy-SiteLogs | Retrieve the IIS Logs from the specified site, using specific start and end dates. |

# Examples

* Create a Backup of the site 'www.mysite.com' to a ZIP-File in C:\TEMP\    (FileName created automatically)
    ```PowerShell
    New-SiteArchive -Site www.mysite.com -Destination C:\TEMP\
* Create a Backup of the site 'www.mysite.com' to a new folder called original.www.mysite.com.xxxxxxxx in the same folder.   (i.e. c:\inetpub\wwwroot\)
    ```PowerShell
    New-SiteCopy -Site www.mysite.com
* Publish specified Codebase to existing IIS site
    ```PowerShell
    Publish-Site -Site www.mysite.com -Staging \\path\to\staging\files\
* Create a ZIP file archive of the sites IIS Logs that match the specified start and end dates
    ```PowerShell
    Copy-SiteLogs -Site www.mysite.com -FromDate 1/1/17 -ToDate 12/1/17