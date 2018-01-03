function New-SiteCopy () {
    <#
    .SYNOPSIS
        Makes an Copy (Backup) of an IIS Site
    .DESCRIPTION
        Function creates an Copy of the specified site, using the Site details retrieived from Get-Sites
    .PARAMETER Site
        IIS Site name to archive
    .EXAMPLE
        Calling the function with no parameters will ask for the specific site to use
        > New-SiteCopy

        You can also pass the specific site to use, using the -Site parameter
        > New-SiteCopy -Site MySite
    .NOTES
        Author: Mike Pruett
        Date: September 12th, 2017
    #>
    [CmdletBinding()]
    param (
        [string]$Site
    )
    # Checking if Function is to be run interactivley
    Write-Progress -Activity "Copy Site" -Status "Enumerating Site Details" -PercentComplete 15
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
    # Stopping Site
    try {
        Write-Verbose -Message "Stopping Site"
        Stop-Site -Site $Target.Site
    }
    catch {
        Write-Error "Unable to Stop Site!!!"
        Break
    }
    # Check for Legacy DOS Variables for SystemDrive and Replace Them
    Write-Progress -Activity "Copy Site" -Status "Searching for Improper Path Variables" -PercentComplete 25
    Start-Sleep -s 2
    If ( $Target.Path -like "%SystemDrive%*" ) {
        $Target.Path = $Target.Path.Replace("%SystemDrive%","$Env:SystemDrive")
    }
    # Path Trickery to derive a new Target for the Archive folder
    Write-Progress -Activity "Copy Site" -Status "Generating Folder Name for Copy" -PercentComplete 50
    Start-Sleep -s 2
    $NewTarget = (Get-Item $Target.Path).Parent.FullName + "\original." + $Target.Path.split("\")[-1].Trim() + "_" + (Get-Date -Format yyyy-MM-dd)
    # Make copy of site
    Write-Progress -Activity "Copy Site" -Status "Making a copy of the site, using $NewTarget as the destination location" -PercentComplete 75
    Start-Sleep -s 2
    Write-Verbose -Message "Making a copy of the site, using $NewTarget as the destination location"
    Copy-Item $Target.Path $NewTarget -Recurse
    # Starting Site
    try {
        Write-Verbose -Message "Starting Site"
        Start-Site -Site $Target.Site
    }
    catch {
        Write-Error "Unable to Start Site!!!"
        Break
    }
    Write-Progress -Activity "Copy Site" -Status "Copy Complete" -PercentComplete 100
    Start-Sleep -s 2
    # Creating $Rollback Environment Vairable
    #[Environment]::SetEnvironmentVariable("Rollback", $NewTarget)
    Return $NewTarget
}