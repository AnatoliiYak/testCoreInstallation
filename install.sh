#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR_PATH="$SCRIPT_DIR/TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar"
GUI_JAR_PATH="$SCRIPT_DIR/TetCoreGui.jar"
INSTALL_DIR="$SCRIPT_DIR"
BIN_DIR="$HOME/bin"

if [ ! -f "$JAR_PATH" ]; then
  echo "Error: CLI JAR file not found at $JAR_PATH"
  exit 1
fi

if [ ! -f "$GUI_JAR_PATH" ]; then
  echo "Error: GUI JAR file not found at $GUI_JAR_PATH"
  exit 1
fi

mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/testcorecli" <<EOF
#!/bin/bash
JAR_PATH="$INSTALL_DIR/TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar"

if [ ! -f "\$JAR_PATH" ]; then
  echo "Error: JAR file not found at \$JAR_PATH"
  exit 1
fi

java -jar "\$JAR_PATH" "\$@"
EOF

cat > "$BIN_DIR/testcoregui" <<EOF
#!/bin/bash
JAR_PATH="$INSTALL_DIR/TetCoreGui.jar"

if [ ! -f "\$JAR_PATH" ]; then
  echo "Error: JAR file not found at \$JAR_PATH"
  exit 1
fi

java -jar "\$JAR_PATH"
EOF

chmod +x "$BIN_DIR/testcorecli" "$BIN_DIR/testcoregui"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.bashrc"
  export PATH="$PATH:$BIN_DIR"
  echo "Added $BIN_DIR to PATH (you may need to restart the terminal)"
fi

echo "TestCoreCLI installed successfully to $BIN_DIR/testcorecli"
echo "TestCoreGUI installed successfully to $BIN_DIR/testcoregui"
