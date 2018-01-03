function Publish-Site () {
    <#
    .SYNOPSIS
        Publishes an IIS Site from code
    .DESCRIPTION
        Function publishes an IIS Site from code staging, using the Site details retrieived from Get-Sites
    .PARAMETER Site
        IIS Site name to publish
    .PARAMETER Stage
        Path to code staging files
    .EXAMPLE
        Calling the function with no site parameter will ask for the specific site to use
        > Publish-Site -Staging <path-to-staging-files>

        You can also pass the specific site to use, using the -Site parameter
        > Publish-Site -Site MySite -Staging <path-to-staging-files>
    .NOTES
        Author: Mike Pruett
        Date: October 19th, 2017
    #>
    [CmdletBinding()]
    param (
        [string]$Site,
        [string]$Staging
    )
    # Checking if $Staging variable n/e $NULL or Exists
    Write-Progress -Activity "Publish Site" -Status "Enumerating Site Details" -PercentComplete 15
    Start-Sleep -s 2
    if ( (!$Staging) -or (-Not (Test-Path -Path $Staging)) ) {
        Write-Error "ERROR: '-Staging' Must include path to Code Staging folder!!!"
        Break
    }
    # Checking if Function is to be run interactivley
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
    Write-Progress -Activity "Publish Site" -Status "Searching for Improper Path Variables" -PercentComplete 25
    Start-Sleep -s 2
    If ( $Target.Path -like "%SystemDrive%*" ) {
        $Target.Path = $Target.Path.Replace("%SystemDrive%","$Env:SystemDrive")
    }
    # Delete Contents of $Target.Path
    Write-Progress -Activity "Publish Site" -Status "Deleting Contents of $Target.Site" -PercentComplete 50
    Start-Sleep -s 2
    try {
        Write-Verbose -Message "Deleting Contents of $Target.Site"
        Remove-Item -Path $Target.Path -Recurse
    }
    catch {
        Write-Error "Unable to Delete Contents of $Target.Site!!!"
        Break
    }
    # Deploy Code from $Staging
    Write-Progress -Activity "Publish Site" -Status "Deploying Code to $Target.Site from $Staging" -PercentComplete 75
    Start-Sleep -s 2
    try {
        Write-Verbose -Message "Deploying Code to $Target.Site for $Staging"
        Copy-Item "$Staging" $Target.Path -Recurse
    }
    catch {
        Write-Error "Unable to Copy Contents of $Staging to $Target.Site!!!"
        Break
    }
    
    # Starting Site
    try {
        Write-Verbose -Message "Starting Site"
        Start-Site -Site $Target.Site
    }
    catch {
        Write-Error "Unable to Start Site!!!"
        Break
    }

    Write-Progress -Activity "Publish Site" -Status "New Site Published..." -PercentComplete 100
    Start-Sleep -s 2
}