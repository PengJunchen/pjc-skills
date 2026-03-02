---
name: "openclaw-wsl-skill"
description: "Installs and configures OpenClaw on a dedicated WSL distribution (OpenUbuntu). Invoke when user wants to set up OpenClaw on Windows/WSL."
---

# OpenClaw WSL Installer Skill

This skill provides tools and scripts to automate the installation and configuration of OpenClaw on a dedicated WSL (Windows Subsystem for Linux) distribution called `OpenUbuntu`.

## Key Features

- **WSL Preparation**: Checks for WSL and creates a dedicated `OpenUbuntu` distribution.
- **OpenClaw Installation**: Installs Node.js and OpenClaw inside the WSL environment.
- **Environment Configuration**: 
  - Disables Windows commands/path integration for better isolation.
  - Configures auto-mount settings (complete disable or selective C-drive mount).
  - Proxy configuration support for both Windows (installation) and WSL (runtime).
  - LAN access configuration (0.0.0.0).

## Usage Instructions

### 1. Environment Preparation
Run the installation script to prepare the WSL environment.
```powershell
./scripts/install.ps1
```
**Parameters:**
- `-HttpProxy <url>`: Set HTTP proxy for installation.
- `-HttpsProxy <url>`: Set HTTPS proxy for installation.
- `-NoProxy`: Explicitly skip proxy configuration.

### 2. OpenClaw Configuration
After the environment is ready, run the configuration script.
```powershell
./scripts/configure.ps1
```
**Parameters:**
- `-DisableWindowsCmd`: Disable Windows commands in WSL (recommended for isolation).
- `-DisableAutoMount`: Disable auto-mount of Windows drives.
- `-ConfigureProxy`: Enable proxy configuration in WSL.
- `-HttpProxy <url>`: Set HTTP proxy for WSL.
- `-HttpsProxy <url>`: Set HTTPS proxy for WSL.
- `-SkipInstall`: Only perform configuration, skip OpenClaw installation.

### 3. Management Commands
- **Start OpenClaw**: `wsl -d OpenUbuntu -u root openclaw gateway`
- **Stop OpenClaw**: `wsl -d OpenUbuntu -u root pkill -f openclaw`
- **Get IP Address**: `wsl -d OpenUbuntu -u root hostname -I`

## Directory Structure
- `scripts/`: Main entry scripts (`install.ps1`, `configure.ps1`).
- `scripts/win/`: Windows-side PowerShell utility scripts.
- `scripts/linux/`: Ubuntu-side Shell scripts (executed via WSL).

## Troubleshooting
- If `OpenUbuntu` creation fails, ensure WSL is enabled and updated (`wsl --update`).
- For proxy issues, ensure the URLs are correctly formatted (e.g., `http://127.0.0.1:7890`).
- LAN access requires port `18789` to be open on the Windows firewall if accessed from other machines.
