#!/usr/bin/env bash
set -e

# Check for Java installation
if ! command -v java &>/dev/null; then
  echo "Java is required to run the BFG Repo-Cleaner. Please install Java (Java 8 or newer)." >&2
  exit 1
fi

BFG_VERSION="1.14.0"
BFG_JAR_URL="https://repo1.maven.org/maven2/com/madgag/bfg/${BFG_VERSION}/bfg-${BFG_VERSION}.jar"
INSTALL_DIR="/usr/local/bin"
BFG_JAR_PATH="${INSTALL_DIR}/bfg.jar"
BFG_SCRIPT_PATH="${INSTALL_DIR}/bfg"

echo "Installing BFG Repo-Cleaner version ${BFG_VERSION}..."

# Download the BFG jar if it doesn't already exist
if [ ! -f "${BFG_JAR_PATH}" ]; then
  echo "Downloading BFG jar from ${BFG_JAR_URL}..."
  curl -L -o "${BFG_JAR_PATH}" "${BFG_JAR_URL}"
fi

# Create a wrapper script for easy execution
echo "Creating wrapper script at ${BFG_SCRIPT_PATH}..."
cat <<'EOF' >"${BFG_SCRIPT_PATH}"
#!/usr/bin/env bash
java -jar /usr/local/bin/bfg.jar "$@"
EOF

chmod +x "${BFG_SCRIPT_PATH}"
echo "BFG Repo-Cleaner installation completed."
