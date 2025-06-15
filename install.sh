#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR_PATH="$SCRIPT_DIR/TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar"
GUI_JAR_PATH="$SCRIPT_DIR/TetCoreGui.jar"
INSTALL_DIR="$SCRIPT_DIR"
BIN_DIR="$HOME/bin"
JAVAFX_DIR="$SCRIPT_DIR/javafx"

# --- Java installation if missing ---
if ! command -v java &>/dev/null || ! command -v javac &>/dev/null; then
  echo "Java not found. Installing OpenJDK 17..."
  sudo apt update
  sudo apt install -y openjdk-17-jdk
  echo "Java installed successfully."
else
  echo "Java is already installed: $(java -version 2>&1 | head -n 1)"
fi

# --- Check for required JAR files ---
if [ ! -f "$JAR_PATH" ]; then
  echo "Error: CLI JAR file not found at $JAR_PATH"
  exit 1
fi

if [ ! -f "$GUI_JAR_PATH" ]; then
  echo "Error: GUI JAR file not found at $GUI_JAR_PATH"
  exit 1
fi

# --- Download and extract JavaFX if missing ---
if [ ! -d "$JAVAFX_DIR" ]; then
  echo "JavaFX not found. Downloading..."
  JAVAFX_URL="https://download2.gluonhq.com/openjfx/21.0.2/openjfx-21.0.2_linux-x64_bin-sdk.zip"
  ZIP_PATH="$SCRIPT_DIR/javafx.zip"

  curl -L "$JAVAFX_URL" -o "$ZIP_PATH"
  unzip "$ZIP_PATH" -d "$SCRIPT_DIR"
  rm "$ZIP_PATH"

  # Rename extracted folder to "javafx"
  FX_EXTRACTED=$(find "$SCRIPT_DIR" -maxdepth 1 -type d -name "javafx-sdk*")
  mv "$FX_EXTRACTED" "$JAVAFX_DIR"

  echo "JavaFX downloaded and extracted to $JAVAFX_DIR"
fi

# --- Ensure bin directory exists ---
mkdir -p "$BIN_DIR"

# --- CLI launcher ---
cat > "$BIN_DIR/testcorecli" <<EOF
#!/bin/bash
JAR_PATH="$INSTALL_DIR/TestCoreCLI-1.0-SNAPSHOT-jar-with-dependencies.jar"

if [ ! -f "\$JAR_PATH" ]; then
  echo "Error: JAR file not found at \$JAR_PATH"
  exit 1
fi

java -jar "\$JAR_PATH" "\$@"
EOF

# --- GUI launcher ---
cat > "$BIN_DIR/testcoregui" <<EOF
#!/bin/bash
JAR_PATH="$INSTALL_DIR/TetCoreGui.jar"
JAVAFX_LIB="$INSTALL_DIR/javafx/lib"

if [ ! -f "\$JAR_PATH" ]; then
  echo "Error: JAR file not found at \$JAR_PATH"
  exit 1
fi

if [ ! -d "\$JAVAFX_LIB" ]; then
  echo "Error: JavaFX library not found at \$JAVAFX_LIB"
  exit 1
fi

java --module-path "\$JAVAFX_LIB" --add-modules javafx.controls,javafx.fxml -jar "\$JAR_PATH"
EOF

# --- Make launchers executable ---
chmod +x "$BIN_DIR/testcorecli" "$BIN_DIR/testcoregui"

# --- Add bin directory to PATH if not already ---
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.bashrc"
  export PATH="$PATH:$BIN_DIR"
  echo "Added $BIN_DIR to PATH (you may need to restart the terminal)"
fi

echo "TestCoreCLI installed successfully to $BIN_DIR/testcorecli"
echo "TestCoreGUI installed successfully to $BIN_DIR/testcoregui"
