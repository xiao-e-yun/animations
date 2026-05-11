# update-path.ps1 — Replace the stored project path across all TNZ files

$root = $PSScriptRoot
$pathFile = Join-Path $root "path.txt"

$oldPath = (Get-Content $pathFile -Raw).Trim()

# Open folder browser dialog
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = "Select new animation path"
$dialog.ShowNewFolderButton = $true
$result = $dialog.ShowDialog()

if ($result -ne "OK") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

$newPath = ($dialog.SelectedPath.TrimEnd('\') + '\').Replace('\', '\\')

if ($oldPath -eq $newPath) {
    Write-Host "Path unchanged: $newPath" -ForegroundColor Yellow
    exit 0
}

Write-Host "Old: $oldPath"
Write-Host "New: $newPath"

# Replace in all TNZ files (handles both single and double backslash variants)
$files = Get-ChildItem $root -Recurse -Include "*.tnz"
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $updated = $content.Replace($oldPath, $newPath)
    if ($updated -ne $content) {
        Set-Content $file.FullName $updated -Encoding UTF8 -NoNewline
        Write-Host "Updated: $($file.Name)"
    }
}

# Update path.txt
Set-Content $pathFile $newPath -Encoding UTF8 -NoNewline

Write-Host "success" -ForegroundColor Green
