#!/usr/bin/env pwsh

param(
    [switch]$DisableWindowsCmd = $false,
    [switch]$DisableAutoMount = $false,
    [switch]$ConfigureProxy = $false,
    [string]$HttpProxy = $null,
    [string]$HttpsProxy = $null,
    [switch]$SkipInstall = $false
)

# Configuration script for OpenClaw on WSL
# This script configures OpenUbuntu and installs OpenClaw
# Run this script after OpenUbuntu has been created

Write-Host "=== OpenClaw WSL Configuration ==="
Write-Host ""

# Check if OpenUbuntu exists
Write-Host "Step 1: Checking OpenUbuntu..."
try {
    $distros = wsl --list --quiet
    if ($distros -contains "OpenUbuntu") {
        Write-Host "✓ OpenUbuntu exists" -ForegroundColor Green
    } else {
        Write-Host "✗ OpenUbuntu does not exist. Please run install.ps1 first." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Error checking OpenUbuntu: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 2: Disable Windows commands in WSL
if ($DisableWindowsCmd) {
    Write-Host "Step 2: Disabling Windows commands in WSL..."
    & "$PSScriptRoot\win\Disable-Windows-Command.ps1" -Confirm:$false
    Write-Host "Windows commands configuration completed."
} else {
    Write-Host "Step 2: Skipping Windows command disable" -ForegroundColor Gray
}
Write-Host ""

# Step 3: Configure auto-mount settings
if ($DisableAutoMount) {
    Write-Host "Step 3: Configuring auto-mount settings..."
    & "$PSScriptRoot\win\Disable-Auto-Mount.ps1" -Confirm:$false
    Write-Host "Auto-mount configuration completed."
} else {
    Write-Host "Step 3: Skipping auto-mount configuration" -ForegroundColor Gray
}
Write-Host ""

# Step 4: Configure proxy
if ($ConfigureProxy -or $HttpProxy -or $HttpsProxy) {
    Write-Host "Step 4: Configuring proxy..."
    & "$PSScriptRoot\win\Configure-Proxy.ps1" -HttpProxy $HttpProxy -HttpsProxy $HttpsProxy
    Write-Host "Proxy configuration completed."
} else {
    Write-Host "Step 4: Skipping proxy configuration" -ForegroundColor Gray
}
Write-Host ""

# Step 5: Install OpenClaw
if (-not $SkipInstall) {
    Write-Host "Step 5: Installing OpenClaw..."
    # Run the Ubuntu script through WSL
    try {
        $scriptPath = "$PSScriptRoot\linux\install-openclaw.sh"
        # Read the script and pipe it to WSL bash, ensuring line endings are handled correctly
        Get-Content $scriptPath -Raw | wsl -d OpenUbuntu -u root bash -c "tr -d '\r' | bash"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "OpenClaw installation completed successfully." -ForegroundColor Green
        } else {
            Write-Host "OpenClaw installation failed." -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "Error installing OpenClaw: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Step 5: Skipping OpenClaw installation" -ForegroundColor Gray
}
Write-Host ""

# Step 6: Get OpenUbuntu IP address
Write-Host "Step 6: Getting OpenUbuntu IP address..."
try {
    $ubuntuIp = wsl -d OpenUbuntu -u root bash -c "hostname -I | awk '{print `$1}'"
    # 清理IP地址字符串，移除可能的空白字符
    $ubuntuIp = $ubuntuIp.Trim()
    if ($ubuntuIp) {
        Write-Host "OpenUbuntu IP address: $ubuntuIp" -ForegroundColor Green
    } else {
        Write-Host "Could not get OpenUbuntu IP address" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error getting IP address: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Final instructions
Write-Host "=== Configuration Complete ==="
Write-Host ""
Write-Host "OpenClaw is now installed and configured for LAN access."
if ($ubuntuIp) {
    Write-Host "You can access OpenClaw from Windows using: http://$($ubuntuIp):18789" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "To start OpenClaw manually, run: wsl -d OpenUbuntu -u root openclaw gateway"
Write-Host ""
