#!/bin/bash

JAR_PATH="$(pwd)TestCoreCLI-1.0-SNAPSHOT.jar"

INSTALL_DIR="/usr/local/testcorecli"
BIN_DIR="/usr/local/bin"

if [ ! -f "$JAR_PATH" ]; then
    echo "Помилка: JAR файл не знайдено за адресою $JAR_PATH"
    exit 1
fi

if [ ! -d "$INSTALL_DIR" ]; then
    sudo mkdir -p "$INSTALL_DIR"
fi

sudo cp "$JAR_PATH" "$INSTALL_DIR/TestCoreCLI-1.0-SNAPSHOT.jar"

echo "#!/bin/bash

JAR_PATH=\"$INSTALL_DIR/TestCoreCLI-1.0-SNAPSHOT.jar\"

if [ ! -f \"\$JAR_PATH\" ]; then
    echo \"Помилка: JAR файл не знайдено за адресою \$JAR_PATH\"
    exit 1
fi

java -jar \"\$JAR_PATH\" \"\$@\"
" | sudo tee "$BIN_DIR/testcorecli" > /dev/null

sudo chmod +x "$BIN_DIR/testcorecli"

echo "TestCoreCLI встановлено! Тепер ви можете викликати 'testcorecli' з будь-якого місця."
