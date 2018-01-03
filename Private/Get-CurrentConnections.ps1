function Get-CurrentConnections {
    <#
    .SYNOPSIS
        Get the Current Connection count for a site
    .DESCRIPTION
        Function returns a object containing the Current Connection Count for a specified site
    .EXAMPLE
        > Get-CurrentConnections -SiteName <site-name>
        Will return the Current Connection count for the specified site, on the current server

        > Get-CurrentConnections -Server MyServer.domain.com -SiteName <site-name>
        Will return the Current Connection count for the specified site, on the specified server
    .PARAMETER SiteName
        Specify the site name to retrieve the Current Connection count for
    .PARAMETER Server
        Specify the server name to retrieve the Currect Connection count from
    .NOTES
        Author: Mike Pruett
        Date: January 2nd, 2018

        Idea's Borrowed from: http://www.trycatchfinally.net/2012/04/powershell-command-to-get-current-sessions-on-an-iis-site/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$SiteName,
        [string]$Server = $Env:ComputerName
    )
    try {
        Write-Verbose -Message "Getting Current Connections for $SiteName"
        $ConnectionCount =  (Get-Counter "\\$Server\Web Service($SiteName)\Current Connections" | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue)
    }
    catch {
        Write-Error "Unable to get Current Connections for the Site!!! Ensure the SiteName ($SiteName) is correct!!!"
        Break
    }
    Return $ConnectionCount
}