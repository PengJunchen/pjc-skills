#!/bin/bash

# Create or modify wsl.conf file
echo "Disabling Windows commands in WSL..."
sudo bash -c "cat > /etc/wsl.conf << EOF
[interop]
# Disable Windows commands
enabled = false
# Disable Windows path integration
appendWindowsPath = false
EOF"

echo "Windows commands have been disabled"
echo "Please run \"wsl --shutdown\" in Windows to apply changes"

