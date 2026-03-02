#!/bin/bash

# Create or modify wsl.conf file
echo "Disabling auto-mount..."
sudo bash -c "cat > /etc/wsl.conf << EOF
[automount]
# Disable all Windows drives auto-mount
enabled = false
EOF"

echo "Auto-mount has been completely disabled"
echo "Please run \"wsl --shutdown\" in Windows to apply changes"

