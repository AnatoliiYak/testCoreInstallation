$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$JAR_PATH = Join-Path $SCRIPT_DIR "TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar"
$INSTALL_DIR = $SCRIPT_DIR
$BIN_DIR = "$env:USERPROFILE\bin"

if (-Not (Test-Path $JAR_PATH)) {
    Write-Host "Error: JAR file not found at $JAR_PATH"
    exit 1
}

$scriptContent = @"
`$JAR_PATH = '$INSTALL_DIR\TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar'

if (-Not (Test-Path `$JAR_PATH)) {
    Write-Host "Error: JAR file not found at `$JAR_PATH"
    exit 1
}

java -jar `$JAR_PATH `$args
"@

if (-Not (Test-Path $BIN_DIR)) {
    New-Item -ItemType Directory -Path $BIN_DIR | Out-Null
}

$scriptPath = "$BIN_DIR\testcorecli.ps1"
$scriptContent | Out-File -FilePath $scriptPath -Encoding utf8 -Force

if ($env:Path -notlike "*$BIN_DIR*") {
    $env:Path += ";$BIN_DIR"
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)
}

Write-Host "TestCoreCLI installed successfully to $scriptPath"
