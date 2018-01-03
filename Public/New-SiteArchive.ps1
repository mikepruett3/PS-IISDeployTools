function New-SiteArchive () {
    <#
    .SYNOPSIS
        Makes a ZIP Archive (Backup) of an IIS Site
    .DESCRIPTION
        Function creates an ZIP Archive of the specified site, using the Site details retrieived from Get-Sites
    .PARAMETER Site
        IIS Site name to archive
    .EXAMPLE
        Calling the function with no parameters will ask for the specific site to use
        > New-SiteArchive -Destination C:\TEMP\

        You can also pass the specific site to use, using the -Site parameter
        > New-SiteArchive -Site MySite -Destination C:\TEMP\
    .NOTES
        Author: Mike Pruett
        Date: December 21st, 2017
    #>
    [CmdletBinding()]
    param (
        [string]$Site,
        [Parameter(Mandatory=$true)]
        [string]$Destination
    )
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
    # Test Destination Path
    Write-Verbose -Message "Determine if Destination Path is valid"
    if (!(Resolve-Path $Destination)) {
        Write-Error "Unable to Enumerate Destination Path!!!"
        Break
    }
    # Determine if ZIP File exists in Path
    $ZipFileName = $Env:ComputerName.ToLower() + "_" + $(get-date -f MM-dd-yyyy_HH_mm_ss) + ".zip"
    Write-Verbose -Message "Determine if ZIP file already exists"
    if (Test-Path "$Destination\$ZipFileName") {
        Write-Error "ZIP file already exists!!!"
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
    If ( $Target.Path -like "%SystemDrive%*" ) {
        $Target.Path = $Target.Path.Replace("%SystemDrive%","$Env:SystemDrive")
    }
    # Create ZIP Archive of IIS Site
    try {
        Write-Verbose -Message "Making a archive of the site, using $Destination as the destination location"
        New-ZipArchive -Verbose -Source $Target.Path -Destination "$Destination" -Filename "$ZipFileName"
    }
    catch {
        Write-Error "Unable to Create ZIP Archive!!!"
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
    # Creating $Rollback Environment Vairable
    #[Environment]::SetEnvironmentVariable("Rollback", $NewTarget)
    #Return $NewTarget
}