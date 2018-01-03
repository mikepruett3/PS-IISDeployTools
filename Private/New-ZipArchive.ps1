function New-ZipArchive () {
    <#
    .SYNOPSIS
        Makes a ZIP Archive of a Directory
    .DESCRIPTION
        Function creates a ZIP Archive of the specified Directory
    .PARAMETER Source
        Source Directory to create a ZIP Archive of
    .PARAMETER Destination
        Destination Path of ZIP Archive
    .PARAMETER Filename
        ZIP Archive Filename
    .EXAMPLE
        Calling the function with no parameters will ask for the specific site to use
        > New-ZipArchive -Source C:\TEMP\ -Destination C:\ -Filename temp.zip
    
    .NOTES
        Author: Mike Pruett
        Date: December 21st, 2017

       
    #>
    [CmdletBinding()]
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Filename
    )
    # Test Source Path
    Write-Verbose -Message "Determine if Source Path is valid"
    if (!(Resolve-Path $Source)) {
        Write-Error "Unable to Enumerate Source Path!!!"
        Break
    }
    # Test Destination Path
    Write-Verbose -Message "Determine if Destination Path is valid"
    if (!(Resolve-Path $Destination)) {
        Write-Error "Unable to Enumerate Destination Path!!!"
        Break
    }
    # Determine if ZIP File exists in Path
    Write-Verbose -Message "Determine if ZIP file already exists"
    if (Test-Path "$Destination\$Filename") {
        Write-Error "ZIP file already exists!!!"
        Break
    }
    # Create ZIP Archive
    try {
        Write-Verbose -Message "Creating ZIP Archive"
        Add-Type -A System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::CreateFromDirectory( "$Source", "$Destination\$ZipFileName")
    }
    catch {
        Write-Error "Unable to create ZIP Archive!!!"
        Break
    }
}