function Get-Sites () {
    <#
    .SYNOPSIS
        Reture a list of IIS Sites configured
    .DESCRIPTION
        A function that returns a Object list of sites in IIS
    .EXAMPLE
        Get-Sites
    .NOTES
        Author: Mike Pruett
        Date: September 6th, 2017
    
    # https://technet.microsoft.com/en-us/library/hh867855(v=wps.630).aspx
    # https://technet.microsoft.com/en-us/library/ee909471(v=ws.10).aspx
    # https://blogs.msdn.microsoft.com/aaronsaikovski/2011/11/30/get-the-application-pool-for-a-web-application-using-the-iis7-powershell-snap-in/
    # https://octopus.com/blog/iis-powershell
    # https://technet.microsoft.com/en-us/library/hh750381.aspx
    # http://www.tomsitpro.com/articles/powershell-manage-iis-application-pools,2-992.html
    #>
    # Main Codeblock
    [CmdletBinding()]
    $Sites = $(Get-ChildItem -Path IIS:\Sites)
    $SiteInventory = @()
    # Enumerate a list of all Sites configured in IIS
    ForEach ($Site in $Sites) {
        $SiteName = $Site.Name
        $SiteState = $Site.State
        $HTTP = (Get-Item -Path "IIS:\Sites\$SiteName" | Get-WebBinding -Protocol HTTP | Select-Object bindingInformation | Out-String)
        $HTTPS = (Get-Item -Path "IIS:\Sites\$SiteName" | Get-WebBinding -Protocol HTTPS | Select-Object bindingInformation | Out-String)
        $SiteLogFileDirectory = (Get-Item -Path "IIS:\Sites\$SiteName" | Select-Object -ExpandProperty Logfile |  Select-Object -ExpandProperty Directory)
        $SiteDetails = @()
        $SiteDetails = New-Object PSObject -Property @{
            ID   = ($Site.ID | Out-String).Trim()  # loose the whitespace!
            Site = $Site.Name
            AppPool = (Get-Item -Path "IIS:\Sites\$SiteName" | Select-Object ApplicationPool | Select-Object -ExpandProperty applicationPool)
            Path = $Site.PhysicalPath
            State = $SiteState
            HTTP = $HTTP.split(":")[-1].Trim()
            HTTPS = $HTTPS.split(":")[-1].Trim()
            LogFileDirectory = $SiteLogFileDirectory
        }
        $SiteInventory += $SiteDetails
        # Check for Virtual Directories associated to the Site, and add them to the inventory
        $VirtualDirectories = $(Get-WebApplication -Site "$SiteName")
        if ($VirtualDirectories) {
            ForEach ($Directory in $VirtualDirectories) {
                $SiteDetails = @()
                $SiteDetails = New-Object PSObject -Property @{
                    ID = "n/a"
                    Name = $Directory.Path
                    AppPool = $Directory.ApplicationPool
                    Path = $Directory.PhysicalPath
                    State = $SiteState
                }
                $SiteInventory += $SiteDetails
            }
        }
    }
    Return $SiteInventory
}