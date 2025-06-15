$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$JAR_PATH = Join-Path $SCRIPT_DIR "TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar"
$GUI_JAR_PATH = Join-Path $SCRIPT_DIR "TetCoreGui.jar"
$INSTALL_DIR = $SCRIPT_DIR
$BIN_DIR = "$env:USERPROFILE\bin"
$JAVAFX_DIR = Join-Path $SCRIPT_DIR "javafx"

# Check and download JavaFX if not present
if (-Not (Test-Path $JAVAFX_DIR)) {
    Write-Host "JavaFX not found. Downloading..."

    $javafxUrl = "https://download2.gluonhq.com/openjfx/21.0.2/openjfx-21.0.2_windows-x64_bin-sdk.zip"
    $zipPath = Join-Path $SCRIPT_DIR "javafx.zip"

    Invoke-WebRequest -Uri $javafxUrl -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $SCRIPT_DIR -Force

    $extractedFolder = Get-ChildItem -Path $SCRIPT_DIR -Directory | Where-Object { $_.Name -like "javafx-sdk*" }
    Rename-Item -Path $extractedFolder.FullName -NewName "javafx"
    Remove-Item $zipPath

    Write-Host "JavaFX downloaded and extracted to $JAVAFX_DIR"
}

# CLI script
$cliScriptContent = @"
`$JAR_PATH = '$INSTALL_DIR\TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar'
`$JAVAFX_LIB = '$INSTALL_DIR\javafx\lib'

if (-Not (Test-Path `$JAR_PATH)) {
    Write-Host "Error: JAR file not found at `$JAR_PATH"
    exit 1
}

java -jar `$JAR_PATH `$args
exit `$LASTEXITCODE
"@

# GUI script with JavaFX support
$guiScriptContent = @"
`$JAR_PATH = '$INSTALL_DIR\TetCoreGui.jar'
`$JAVAFX_LIB = '$INSTALL_DIR\javafx\lib'

if (-Not (Test-Path `$JAR_PATH)) {
    Write-Host "Error: JAR file not found at `$JAR_PATH"
    exit 1
}

if (-Not (Test-Path `$JAVAFX_LIB)) {
    Write-Host "Error: JavaFX not found at `$JAVAFX_LIB"
    exit 1
}

java --module-path "`$JAVAFX_LIB" --add-modules javafx.controls,javafx.fxml -jar `$JAR_PATH
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

