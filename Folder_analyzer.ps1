#==============================================================
# Folder & File Inventory Generator
#==============================================================

$RootFolder = "C:\Sahidreams"        # Change this
$OutputCSV  = "C:\Sahidreams\Sahidreams_Report.csv"

Write-Host "Scanning folder..."
Write-Host $RootFolder

$result = Get-ChildItem -Path $RootFolder -Recurse -Force | ForEach-Object {

    $acl = Get-Acl $_.FullName -ErrorAction SilentlyContinue

    [PSCustomObject]@{

        Name              = $_.Name
        FullPath          = $_.FullName

        Type              = if ($_.PSIsContainer) {"Folder"} else {"File"}

        Extension         = if ($_.PSIsContainer) {""} else {$_.Extension}

        SizeBytes         = if ($_.PSIsContainer) {""} else {$_.Length}

        SizeKB            = if ($_.PSIsContainer) {""} else {[math]::Round($_.Length/1KB,2)}

        SizeMB            = if ($_.PSIsContainer) {""} else {[math]::Round($_.Length/1MB,2)}

        Created           = $_.CreationTime

        LastModified      = $_.LastWriteTime

        LastAccessed      = $_.LastAccessTime

        ParentFolder      = $_.DirectoryName

        ReadOnly          = $_.IsReadOnly

        Hidden            = ($_.Attributes -match "Hidden")

        System            = ($_.Attributes -match "System")

        Archive           = ($_.Attributes -match "Archive")

        Owner             = if($acl){$acl.Owner}else{""}

        Depth             = ($_.FullName.Replace($RootFolder,"").Split("\").Count)-1
    }
}

$result | Export-Csv $OutputCSV -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Done."
Write-Host "CSV created:"
Write-Host $OutputCSV