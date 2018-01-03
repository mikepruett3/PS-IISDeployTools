function Copy-SiteLogs () {
    <#
    .SYNOPSIS
        Collects logs from an IIS Site, saves to ZIP file
    .DESCRIPTION
        Function creates an Archive of the specified site IIS logs, using the Site details retrieived from Get-Sites
    .PARAMETER Site
        IIS Site name to Collect Logs
    .PARAMETER FromDate
        Date to start querying for logs
    .PARAMETER ToDate
        Date to end querying for logs
    .EXAMPLE
        Calling the function with only FromDate and ToDate parameters will ask for the specific site to use
        > Copy-SiteLogs -FromDate 12/1/17 -ToDate 12/31/17

        You can also pass the specific site to use, using the -Site parameter
        > Copy-SiteLogs -Site MySite -FromDate 12/1/17 -ToDate 12/31/17
    .NOTES
        Author: Mike Pruett
        Date: December 21st, 2017
    #>
    [CmdletBinding()]
    param (
        [string]$Site,
        [Parameter(Mandatory=$true)]
        [string]$FromDate,
        [Parameter(Mandatory=$true)]
        [string]$ToDate
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
    # Create Temporary Directory for IIS Logs
    try {
        Write-Verbose -Message "Creating Temporary Directory"
        New-Item -ItemType Directory -Path "$Env:Temp\Logs\" | Out-Null
    }
    catch {
        Write-Error "Unable to create Temporary Directory!!!"
        Break
    }
    # Collect IIS Logs which match Date Range
    try {
        Write-Verbose -Message "Gathering List of Logs that Match FromDate & ToDate"
        $FileList = Get-ChildItem -Path $LogFileDirectory | Where-Object { $_.LastWriteTime -gt $FromDate -AND $_.LastWriteTime -lt $ToDate } | Select-Object -ExpandProperty FullName
    }
    catch {
        Write-Error "Unable to find Log files in the specified date range!!!"
        Break
    }
    # Copy IIS Logs to Temporary Directory
    try {
        Write-Verbose -Message "Copying matching IIS Log files to Temporary Directory"
        Copy-Item $FileList $Env:Temp\Logs\
    }
    catch {
        Write-Error "Unable to copy Log files to Temporary Directory!!!"
        Break
    }
    # Create ZIP Archive of IIS Logs
    try {
        Write-Verbose -Message "Creating ZIP Archive of IIS Log files"
        $ZipFileName = $Env:ComputerName.ToLower() + "_" + $(get-date -f MM-dd-yyyy_HH_mm_ss) + ".zip"
        New-ZipArchive -Source "$Env:Temp\Logs\" -Destination "$Env:Temp\" -Filename "$ZipFileName"
    }
    catch {
        Write-Error "Unable to Create ZIP Archive!!!"
        Break
    }
    # Remove IIs Log files from Temporary Directory
    try {
        Write-Verbose -Message "Removing IIS Log files from Temporary Directory"
        Remove-Item "$Env:Temp\Logs\*" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Error "Unable to delete IIS Log files from Temporary Directory!!!"
        Break
    }
    #  Remove Temporary Directory
    try {
        Write-Verbose -Message "Removing Temporary Directory"
        Remove-Item "$Env:Temp\Logs" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Error "Unable to remove Temporary Directory!!!"
        Break
    }
    # Return ZIP Archive Path
    Write-Verbose -Message "ZIP Archive located at $("$Env:Temp\$ZipFileName")"
    Return $("$Env:Temp\$ZipFileName")
}