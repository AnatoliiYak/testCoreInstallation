$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$JAR_PATH = Join-Path $SCRIPT_DIR "TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar"
$GUI_JAR_PATH = Join-Path $SCRIPT_DIR "TetCoreGui.jar"
$INSTALL_DIR = $SCRIPT_DIR
$BIN_DIR = "$env:USERPROFILE\bin"

if (-Not (Test-Path $JAR_PATH)) {
    Write-Host "Error: CLI JAR file not found at $JAR_PATH"
    exit 1
}

if (-Not (Test-Path $GUI_JAR_PATH)) {
    Write-Host "Error: GUI JAR file not found at $GUI_JAR_PATH"
    exit 1
}

# CLI script
$cliScriptContent = @"
`$JAR_PATH = '$INSTALL_DIR\TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar'

if (-Not (Test-Path `$JAR_PATH)) {
    Write-Host "Error: JAR file not found at `$JAR_PATH"
    exit 1
}

java -jar `$JAR_PATH `$args
exit `$LASTEXITCODE
"@

# GUI script
$guiScriptContent = @"
`$JAR_PATH = '$INSTALL_DIR\TetCoreGui.jar'

if (-Not (Test-Path `$JAR_PATH)) {
    Write-Host "Error: JAR file not found at `$JAR_PATH"
    exit 1
}

java -jar `$JAR_PATH
exit `$LASTEXITCODE
"@

if (-Not (Test-Path $BIN_DIR)) {
    New-Item -ItemType Directory -Path $BIN_DIR | Out-Null
}

$cliScriptPath = "$BIN_DIR\testcorecli.ps1"
$cliScriptContent | Out-File -FilePath $cliScriptPath -Encoding utf8 -Force

$guiScriptPath = "$BIN_DIR\testcoregui.ps1"
$guiScriptContent | Out-File -FilePath $guiScriptPath -Encoding utf8 -Force

if ($env:Path -notlike "*$BIN_DIR*") {
    $env:Path += ";$BIN_DIR"
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)
}

Write-Host "TestCoreCLI installed successfully to $cliScriptPath"
Write-Host "TestCoreGUI installed successfully to $guiScriptPath"
