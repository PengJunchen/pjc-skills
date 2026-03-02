#!/usr/bin/env pwsh

param(
    [string]$HttpProxy = $null,
    [string]$HttpsProxy = $null,
    [switch]$NoProxy = $false
)

# WSL Environment Preparation Script
# This script prepares the WSL environment and creates OpenUbuntu distribution

Write-Host "=== OpenClaw WSL Environment Preparation ==="
Write-Host ""

# Step 0: Configure proxy for installation process
Write-Host "Step 0: Configuring proxy for installation..."

if (-not $NoProxy -and ($HttpProxy -or $HttpsProxy)) {
    # Use provided proxy settings
    Write-Host "Setting Windows environment variables for proxy..." -ForegroundColor Cyan
    if ($HttpProxy) {
        [Environment]::SetEnvironmentVariable("HTTP_PROXY", $HttpProxy, "Process")
        [Environment]::SetEnvironmentVariable("http_proxy", $HttpProxy, "Process")
    }
    if ($HttpsProxy) {
        [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $HttpsProxy, "Process")
        [Environment]::SetEnvironmentVariable("https_proxy", $HttpsProxy, "Process")
    }
    Write-Host "✓ Proxy environment variables set" -ForegroundColor Green
} elseif (-not $NoProxy -and -not ($HttpProxy -or $HttpsProxy) -and [Environment]::GetEnvironmentVariable("HTTP_PROXY", "Process")) {
    # Use existing environment proxy
    Write-Host "✓ Using existing proxy settings from environment" -ForegroundColor Green
} else {
    Write-Host "✓ Skipping proxy configuration for installation" -ForegroundColor Green
}
Write-Host ""

# Step 1: Check WSL
Write-Host "Step 1: Checking WSL..."
& "$PSScriptRoot\win\Check-WSL.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "WSL check failed. Exiting." -ForegroundColor Red
    exit 1
}
Write-Host "WSL check completed successfully."
Write-Host ""

# Step 2: Check and create OpenUbuntu
Write-Host "Step 2: Checking and creating OpenUbuntu..."
& "$PSScriptRoot\win\Check-Create-Ubuntu.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "OpenUbuntu creation failed. Exiting." -ForegroundColor Red
    exit 1
}
Write-Host "OpenUbuntu check and creation completed successfully."
Write-Host ""

# Final instructions
Write-Host "=== Environment Preparation Complete ==="
Write-Host ""
Write-Host "OpenUbuntu WSL distribution has been created successfully."
Write-Host ""
Write-Host "Next step: Run the configuration script to install and configure OpenClaw:"
Write-Host ".\configure.ps1"
Write-Host ""

