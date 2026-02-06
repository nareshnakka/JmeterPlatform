# merge-installer.ps1
# Merge split installer parts back into a single zip.

param(
    [string]$BaseName = "JMeterPlatform-FullInstaller.zip"
)

$destination = $BaseName

Write-Host "Looking for parts: $BaseName.part*** in $(Get-Location)" -ForegroundColor Cyan

# Find all part files for this installer
$pattern = "$BaseName.part*"
$parts = Get-ChildItem $pattern -ErrorAction SilentlyContinue | Sort-Object Name

if (-not $parts -or $parts.Count -eq 0) {
    Write-Error "No part files found matching pattern '$pattern'"
    exit 1
}

Write-Host "Found $($parts.Count) parts:" -ForegroundColor Green
$parts | ForEach-Object { Write-Host "  - " $_.Name }

if (Test-Path $destination) {
    Write-Host "Removing existing $destination" -ForegroundColor Yellow
    Remove-Item $destination -Force
}

Write-Host "Merging parts into $destination ..." -ForegroundColor Cyan

$out = [System.IO.File]::Create($destination)
try {
    foreach ($part in $parts) {
        Write-Host "Adding $($part.Name)..."
        $in = [System.IO.File]::OpenRead($part.FullName)
        try {
            $in.CopyTo($out)
        }
        finally {
            $in.Close()
        }
    }
}
finally {
    $out.Close()
}

Write-Host "Done. You can now unzip '$destination'" -ForegroundColor Green
