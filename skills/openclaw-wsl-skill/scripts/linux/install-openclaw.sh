#!/bin/bash
set -e

# Install OpenClaw in Ubuntu
echo "=== Installing OpenClaw in Ubuntu ==="

# Update package list
echo "Updating package list..."
apt update

# Install basic dependencies
echo "Installing basic dependencies (curl, gnupg, jq)..."
apt install -y curl gnupg jq

# Install Node.js if not installed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js 22.x..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt install -y nodejs
fi

# Verify Node.js and npm
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# Install OpenClaw
echo "Installing OpenClaw..."
npm install -g openclaw

# Determine target user and home directory
TARGET_USER="ubuntu"
if ! id "$TARGET_USER" &>/dev/null; then
    TARGET_USER="root"
fi
USER_HOME=$(eval echo "~$TARGET_USER")

# Create OpenClaw configuration directory
echo "Creating OpenClaw configuration directory for $TARGET_USER at $USER_HOME/.openclaw ..."
mkdir -p "$USER_HOME/.openclaw"

# Create or update configuration
echo "Configuring OpenClaw..."
CONFIG_FILE="$USER_HOME/.openclaw/openclaw.json"
# Added mode: local and auth: token because bind: lan requires authentication for safety
# Use a default token that can be changed later
NEW_CONFIG='{"gateway":{"mode":"local","bind":"lan","auth":{"mode":"token","token":"openclaw-wsl-token"},"controlUi":{"allowedOrigins":["*"]}}}'

if [ -f "$CONFIG_FILE" ]; then
    echo "Merging with existing configuration..."
    # Use jq to merge the gateway config into existing file, preserving other fields
    jq -s '.[0] * .[1]' "$CONFIG_FILE" <(echo "$NEW_CONFIG") > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
else
    echo "Creating new configuration..."
    echo "$NEW_CONFIG" > "$CONFIG_FILE"
fi

# Set proper permissions
echo "Setting permissions..."
chown -R "$TARGET_USER:$TARGET_USER" "$USER_HOME/.openclaw"
chmod 600 "$CONFIG_FILE"
chmod 700 "$USER_HOME/.openclaw/"

# Start OpenClaw gateway
echo "Starting OpenClaw gateway as $TARGET_USER ..."
# Using login shell (-i) to ensure $PATH and Node.js environment are fully loaded
# We use 'openclaw gateway' (foreground command) with nohup for stability in WSL
LOG_FILE="/tmp/openclaw.log"
echo "Starting as background process (nohup)... Logs: $LOG_FILE"

# Clean up any existing background gateway process for this user
sudo -u "$TARGET_USER" pkill -f "openclaw gateway" || true

# Use a login shell to execute the background command
sudo -u "$TARGET_USER" -i bash -c "nohup openclaw gateway > $LOG_FILE 2>&1 &"

# Wait a bit and verify
sleep 5
if sudo -u "$TARGET_USER" pgrep -f "openclaw gateway" > /dev/null; then
    echo "✓ OpenClaw gateway started in background"
else
    echo "Warning: Background start might have failed. Checking logs..."
    if [ -f "$LOG_FILE" ]; then
        tail -n 10 "$LOG_FILE"
    fi
    
    # Fallback to explicit path if needed
    CLAW_PATH=$(sudo -u "$TARGET_USER" -i npm prefix -g)/bin/openclaw
    if [ -f "$CLAW_PATH" ]; then
        echo "Trying explicit path: $CLAW_PATH"
        sudo -u "$TARGET_USER" -i bash -c "nohup $CLAW_PATH gateway > $LOG_FILE 2>&1 &"
        sleep 3
        if sudo -u "$TARGET_USER" pgrep -f "$CLAW_PATH gateway" > /dev/null; then
            echo "✓ OpenClaw gateway started in background (explicit path)"
        else
            echo "Error: Failed to start OpenClaw gateway automatically."
            echo "You can start it manually by running: wsl -d OpenUbuntu -u $TARGET_USER -i openclaw gateway"
        fi
    fi
fi

# Get IP address
echo "Getting OpenUbuntu IP address..."
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "=== Installation completed ==="
echo "OpenClaw is now installed and running"
echo "You can access the dashboard at: http://$IP_ADDRESS:18789"
echo "Or try: http://localhost:18789"
