param (
    [string]$storageAccountName,
    [string]$sasToken,
    [string]$containerName = "tempbacpac",
    [string]$bacpacUrl = "https://raw.githubusercontent.com/<username>/<repo>/<branch>/adventureworks.bacpac",
    [string]$localPath = "C:\\temp\\adventureworks.bacpac"
)

# Create temp directory
$localDir = Split-Path $localPath
if (-not (Test-Path $localDir)) {
    New-Item -ItemType Directory -Path $localDir -Force
}

# Download the .bacpac file from GitHub
Invoke-WebRequest -Uri $bacpacUrl -OutFile $localPath

# Upload to Azure Blob Storage using AzCopy
$blobUri = "https://$storageAccountName.blob.core.windows.net/$containerName/adventureworks.bacpac?$sasToken"

# Download AzCopy if not already present
$azCopyPath = "C:\\AzCopy\\azcopy.exe"
if (-not (Test-Path $azCopyPath)) {
    Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile "C:\\AzCopy.zip"
    Expand-Archive -Path "C:\\AzCopy.zip" -DestinationPath "C:\\AzCopy" -Force
    $azCopyExe = Get-ChildItem -Path "C:\\AzCopy" -Recurse -Filter azcopy.exe | Select-Object -First 1
    Copy-Item $azCopyExe.FullName -Destination $azCopyPath
}

# Upload the file
& $azCopyPath copy $localPath $blobUri --overwrite=true

Write-Host "Upload complete."
