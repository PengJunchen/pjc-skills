param(
    [bool]$Confirm = $true
)

# Disable Windows commands in WSL
Write-Host "=== Disabling Windows commands in WSL ===" -ForegroundColor Green

# Ask user if they want to disable Windows commands
if ($Confirm) {
    $disableWindowsCmd = Read-Host "Do you want to disable Windows commands in WSL? (Y/N)"
} else {
    $disableWindowsCmd = "Y"
}

if ($disableWindowsCmd -eq "Y" -or $disableWindowsCmd -eq "y") {
    # Directly execute commands in WSL
    Write-Host "Running disable commands..." -ForegroundColor Cyan
    
    # Create wsl.conf file using echo commands
    wsl -d OpenUbuntu -u root bash -c "echo '[interop]' > /etc/wsl.conf"
    wsl -d OpenUbuntu -u root bash -c "echo '# Disable Windows commands' >> /etc/wsl.conf"
    wsl -d OpenUbuntu -u root bash -c "echo 'enabled = false' >> /etc/wsl.conf"
    wsl -d OpenUbuntu -u root bash -c "echo '# Disable Windows path integration' >> /etc/wsl.conf"
    wsl -d OpenUbuntu -u root bash -c "echo 'appendWindowsPath = false' >> /etc/wsl.conf"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Windows commands disabled" -ForegroundColor Green
        Write-Host "Please run 'wsl --shutdown' to apply changes" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Failed to disable Windows commands" -ForegroundColor Red
    }
} else {
    Write-Host "✓ Skipping Windows command disable" -ForegroundColor Green
}

Write-Host "=== Windows command disable completed ===" -ForegroundColor Green
