$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition

$JAR_PATH = Join-Path $SCRIPT_DIR "TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar"

$INSTALL_DIR = "C:\Program Files\TestCoreCLI"
$BIN_DIR = "$env:USERPROFILE\bin"

if (-Not (Test-Path $JAR_PATH)) {
    Write-Host "Помилка: JAR файл не знайдено за адресою $JAR_PATH"
    exit 1
}

if (-Not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR
}

Copy-Item -Path $JAR_PATH -Destination $INSTALL_DIR

$scriptContent = @"
# Скрипт для запуску TestCoreCLI
\$JAR_PATH = '$INSTALL_DIR\TestCoreCLI-1.0-SNAPSHOT.jar'

if (-Not (Test-Path \$JAR_PATH)) {
    Write-Host 'Помилка: JAR файл не знайдено за адресою \$JAR_PATH'
    exit 1
}

java -jar \$JAR_PATH \$args
"@

if (-Not (Test-Path $BIN_DIR)) {
    New-Item -ItemType Directory -Path $BIN_DIR
}

$scriptPath = "$BIN_DIR\testcorecli.ps1"
$scriptContent | Out-File -FilePath $scriptPath -Force

$env:Path += ";$BIN_DIR"

Write-Host "TestCoreCLI успішно встановлено!"
Write-Host "Тепер ви можете викликати 'testcorecli' з будь-якого місця в PowerShell."
Write-Host "Використовуйте команду: testcorecli download_java_template anatolii_project"
