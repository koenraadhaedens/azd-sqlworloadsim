param (
    [string]$bacpacUrl,
    [string]$targetSqlServer,
    [string]$targetDatabase,
    [string]$sqlAdminUser,
    [string]$sqlAdminPassword
)

# Log start
Write-Output "Starting deployment..."

# Set working path
$tempPath = "$env:TEMP\sqlpackage"
New-Item -Path $tempPath -ItemType Directory -Force | Out-Null

# Download and install SqlPackage
Write-Output "Downloading and installing SqlPackage..."
$sqlPackageZip = "$tempPath\sqlpackage.zip"
Invoke-WebRequest -Uri "https://aka.ms/sqlpackage-win-x64" -OutFile $sqlPackageZip
Expand-Archive -Path $sqlPackageZip -DestinationPath $tempPath -Force

# Set the path to SqlPackage.exe
$env:PATH += ";$tempPath"

# Download the .bacpac
$bacpacFile = "$tempPath\database.bacpac"
Write-Output "Downloading bacpac from $bacpacUrl"
Invoke-WebRequest -Uri $bacpacUrl -OutFile $bacpacFile

# Import bacpac
Write-Output "Importing bacpac to $targetSqlServer..."
& "$tempPath\sqlpackage\SqlPackage.exe" /a:Import `
    /sf:$bacpacFile `
    /tsn:$targetSqlServer `
    /tdn:$targetDatabase `
    /tu:$sqlAdminUser `
    /tp:$sqlAdminPassword `
    /p:DatabaseEdition=GeneralPurpose `
    /p:ServiceObjective=S2 `
    /p:AllowPotentialDataLoss=true

# Exit with last command exit code
exit $LASTEXITCODE
