#!/bin/bash

HTTP_PROXY="http://127.0.0.1:7890"
HTTPS_PROXY="http://127.0.0.1:7890"
NO_PROXY="localhost,127.0.0.1"

# Add proxy settings to bashrc
echo "Configuring proxy settings..."
cat >> ~/.bashrc << EOF

# Proxy settings
export http_proxy="$HTTP_PROXY"
export https_proxy="$HTTPS_PROXY"
export no_proxy="$NO_PROXY"
export HTTP_PROXY="$HTTP_PROXY"
export HTTPS_PROXY="$HTTPS_PROXY"
export NO_PROXY="$NO_PROXY"
EOF

# Apply settings
source ~/.bashrc

echo "Proxy settings configured"
echo "HTTP proxy: $HTTP_PROXY"
echo "HTTPS proxy: $HTTPS_PROXY"
echo "No proxy: $NO_PROXY"

