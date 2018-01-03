function Trace-SiteLogs () {
    <#
    .SYNOPSIS
        Watches the latest Log file for IIS Site
    .DESCRIPTION
        Function locates the latest IIS Log for the specified Site, and monitors it
    .PARAMETER Site
        IIS Site name to Collect Logs
    .EXAMPLE
        Calling the function with no parameters will ask for the specific site to use
        > Trace-SiteLogs

        You can also pass the specific site to use, using the -Site parameter
        > Trace-SiteLogs -Site MySite
    .NOTES
        Author: Mike Pruett
        Date: December 21st, 2017
    #>
    [CmdletBinding()]
    param (
        [string]$Site
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
    # Determine IIS Log File Directory
    $LogFileDirectory = $Target.LogFileDirectory + "\W3SVC" + $Target.ID
    # Environment variable conversion
    Switch -wildcard ($LogFileDirectory) {
        "%SystemDrive%*" { $LogFileDirectory = $LogFileDirectory | foreach {$_ -replace "%SystemDrive%","$Env:SystemDrive"} }
    }
    # Determine if IIS Log File Directory is Valid
    Write-Verbose -Message "Determine IIS Log File Directory is Valid"
    if (!(Resolve-Path $LogFileDirectory -ErrorAction SilentlyContinue)) {
        Write-Error "Log Directory Invalid!!!"
        Break
    }
    # Locate the latest IIS Log file
    try {
        Write-Verbose -Message "Locating the latest IIS Log file"
        $LogFile = (Get-ChildItem -Path $LogFileDirectory | Sort-Object LastWriteTime | Select-Object -Last 1 | Select-Object -ExpandProperty FullName)
    }
    catch {
        Write-Error "Unable to find the latest IIS Log file"
        Break
    }
    # Get-Content -Wait on $LogFile.FullName
    Write-Verbose -Message "Tailing $LogFile"
    Get-Content -Path "$LogFile" -Wait
}