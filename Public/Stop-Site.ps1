function Stop-Site {
    <#
    .SYNOPSIS
        Stops the AppPool and Service of Specified Site
    .DESCRIPTION
        Function will properly stop the IIS site, then Stop the AppPool and check that Processes are stopped
    .EXAMPLE
        > Stop-Site -Site <site-name>
        Will stop the Site Services and AppPool for the site specified in the Object
    .PARAMETER Site
        Specify the Site Object (from Get-Sites) to stop associted Services and AppPool
    .NOTES
        Author: Mike Pruett
        Date: January 2nd, 2018
    #>
    [CmdletBinding()]
    param (
        [string]$Site
    )
    # Checking if Function is to be run interactivley
    Write-Progress -Activity "Stopping Site" -Status "Enumerating Site Details" -PercentComplete 15
    Start-Sleep -s 2
    if (!$Site) {
        try {
            Write-Verbose -Message "Retrieving a list of Sites from IIS"
            Get-Sites | Where-Object {$_.ID -ne "n/a"} | Select-Object Site, AppPool, HTTP, HTTPS, State | Format-Table
        }
        catch {
            Write-Error "Unable to retrieve the list of Sites on the server!!!"
            Break
        }
        Write-Verbose -Message "Catching selection of a Site from user"
        $Site = Read-Host -Prompt "Enter the site name from the following list of sites"
    }
    try {
        Write-Verbose -Message "Creating an Object for use with all details about the specified site"
        $Target = (Get-Sites | Where-Object {$_.ID -ne "n/a"} | Where-Object {$_.Site -eq $Site})
    }
    catch {
        Write-Error "Unable to locate Specified Site on the server!!!"
        Break
    }
    # Stopping AppPool
    try {
        Write-Progress -Activity "Stopping Site" -Status "Stopping AppPool" -PercentComplete 25
        Start-Sleep -s 2
        Write-Verbose -Message "Stopping AppPool"
        Stop-WebAppPool -Name $Target.AppPool
    }
    catch {
        Write-Error "Unable to Stop AppPool!!!"
        Break
    }
    # Stopping Site
    try {
        Write-Progress -Activity "Stopping Site" -Status "Stopping IIS Site" -PercentComplete 50
        Start-Sleep -s 2
        Write-Verbose -Message "Stopping IIS Site"
        Stop-Website -Name $Target.Site
    }
    catch {
        Write-Error "Unable to Stop Site!!!"
        Break
    }
        # Checking Current Connections
        try {
            Write-Progress -Activity "Stopping Site" -Status "Checking Active Connections" -PercentComplete 75
            Start-Sleep -s 2
            Write-Verbose -Message "Checking Active Connections"
            Wait-CurrentConnections -SiteName $Target.Site
        }
        catch {
            Write-Error "Site still has Active Connections!!!"
        }
    Write-Progress -Activity "Stopping Site" -Status "Site Stopped Successfully!" -PercentComplete 100
    Start-Sleep -s 2
}