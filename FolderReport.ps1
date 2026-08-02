# ==========================================
# FolderReport.ps1
# Generates an HTML report of folders/files
# ==========================================

param(
    [string]$RootFolder = "C:\Temp",
    [string]$OutputFile = "FolderReport.html"
)

Write-Host "Scanning $RootFolder ..."
Write-Host ""

# Get all folders
$folders = Get-ChildItem -Path $RootFolder -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {

    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object Length -Sum).Sum

    [PSCustomObject]@{
        Type = "Folder"
        Name = $_.Name
        SizeMB = "{0:N2}" -f ($size / 1MB)
        LastModified = $_.LastWriteTime
        Path = $_.FullName
    }
}

# Get all files
$files = Get-ChildItem -Path $RootFolder -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {

    [PSCustomObject]@{
        Type = "File"
        Name = $_.Name
        SizeMB = "{0:N2}" -f ($_.Length / 1MB)
        LastModified = $_.LastWriteTime
        Path = $_.FullName
    }
}

$data = $folders + $files | Sort-Object Type, Name

$style = @"
<style>
body{
    font-family:Segoe UI;
    margin:20px;
    background:#f5f5f5;
}

h1{
    color:#003366;
}

table{
    border-collapse:collapse;
    width:100%;
    background:white;
}

th{
    background:#003366;
    color:white;
    padding:8px;
}

td{
    border:1px solid #ddd;
    padding:6px;
}

tr:nth-child(even){
    background:#f9f9f9;
}

tr:hover{
    background:#ffffcc;
}

.folder{
    color:blue;
    font-weight:bold;
}

.file{
    color:black;
}
</style>
"@

$html = $data |
ConvertTo-Html `
-Title "Folder Report" `
-Head $style `
-PreContent "<h1>Folder Report</h1><h3>Root Folder: $RootFolder</h3>" `
-PostContent "<br><b>Generated:</b> $(Get-Date)"

$html | Out-File $OutputFile -Encoding UTF8

Write-Host ""
Write-Host "Report generated:"
Write-Host "$OutputFile"

Invoke-Item $OutputFile