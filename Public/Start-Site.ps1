function Start-Site {
    <#
    .SYNOPSIS
        Starts the AppPool and Service of Specified Site
    .DESCRIPTION
        Function will properly start the IIS site, then start the AppPool
    .EXAMPLE
        > Start-Site -Site <site-name>
        Will start the Site Services and AppPool for the site specified in the Object
    .PARAMETER Site
        Specify the Site Object (from Get-Sites) to start associted Services and AppPool
    .NOTES
        Author: Mike Pruett
        Date: January 2nd, 2018
    #>
    [CmdletBinding()]
    param (
        [string]$Site
    )
    # Checking if Function is to be run interactivley
    Write-Progress -Activity "Starting Site" -Status "Enumerating Site Details" -PercentComplete 15
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
    # Starting AppPool
    try {
        Write-Progress -Activity "Starting Site" -Status "Starting AppPool" -PercentComplete 25
        Start-Sleep -s 2
        Write-Verbose -Message "Starting AppPool"
        Start-WebAppPool -Name $Target.AppPool
    }
    catch {
        Write-Error "Unable to Start AppPool!!!"
        Break
    }
    # Starting Site
    try {
        Write-Progress -Activity "Starting Site" -Status "Starting IIS Site" -PercentComplete 50
        Start-Sleep -s 2
        Write-Verbose -Message "Starting IIS Site"
        Start-Website -Name $Target.Site
    }
    catch {
        Write-Error "Unable to Start Site!!!"
        Break
    }
    Write-Progress -Activity "Starting Site" -Status "Site Started Successfully!" -PercentComplete 100
    Start-Sleep -s 2
}