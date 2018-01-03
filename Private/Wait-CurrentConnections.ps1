function Wait-CurrentConnections {
    <#
    .SYNOPSIS
        Wait the Current Connection count for a site to reach Zero
    .DESCRIPTION
        Function Measures the Current Connection count for the specfied site, and waits till it reaches Zero
    .EXAMPLE
        > Wait-CurrentConnections -SiteName <site-name>
        Will return the Current Connection count for the specified site, on the current server

        > Wait-CurrentConnections -Server MyServer.domain.com -SiteName <site-name>
        Will return the Current Connection count for the specified site, on the specified server
    .PARAMETER SiteName
        Specify the site name to retrieve the Current Connection count for
    .PARAMETER Server
        Specify the server name to retrieve the Currect Connection count from
    .NOTES
        Author: Mike Pruett
        Date: January 2nd, 2018
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$SiteName,
        [string]$Server = $Env:ComputerName
    )
    Write-Verbose -Message "Measuring Current Connections for $SiteName, will stop when count equals Zero"
    do {
        $ConnectionCount = (Get-CurrentConnections -Server $Server -SiteName $SiteName)
        #Write-Verbose "Waiting for Current Connections to terminate, Connection Count at $ConnectionCount"
        Write-Progress -Activity "Waiting for Current Connections to Terminate" -Status "Connection Count: $ConnectionCount" -PercentComplete -1
    } while ( $ConnectionCount -ne 0 )
}