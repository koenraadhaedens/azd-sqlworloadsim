param (
    [string]$BacpacUrl,
    [string]$SqlServer,
    [string]$Database,
    [string]$SqlAdmin,
    [string]$SqlPassword
)

Invoke-WebRequest -Uri $BacpacUrl -OutFile "C:\temp\import.bacpac"

& "C:\Program Files\Microsoft SQL Server\150\DAC\bin\SqlPackage.exe" /a:Import `
    /sf:"C:\temp\import.bacpac" `
    /tsn:$SqlServer `
    /tdn:$Database `
    /tu:$SqlAdmin `
    /tp:$SqlPassword `
    /p:DatabaseEdition=Standard `
    /p:DatabaseServiceObjective=S1
