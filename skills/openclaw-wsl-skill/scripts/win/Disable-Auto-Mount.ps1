param(
    [bool]$Confirm = $true,
    [int]$Option = 1
)

# Disable auto-mount in WSL
Write-Host "=== Disabling auto-mount in WSL ===" -ForegroundColor Green

# Ask user if they want to disable auto-mount
if ($Confirm) {
    $disableAutoMount = Read-Host "Do you want to disable auto-mount of Windows drives? (Y/N)"
} else {
    $disableAutoMount = "Y"
}

if ($disableAutoMount -eq "Y" -or $disableAutoMount -eq "y") {
    # Ask for configuration option
    if ($Confirm) {
        Write-Host "Please select configuration option:" -ForegroundColor Cyan
        Write-Host "1. Completely disable auto-mount (no Windows drives mounted)"
        Write-Host "2. Selective mount (only mount C drive)"
        $optionStr = Read-Host "Please enter option number (1/2)"
        $option = [int]$optionStr
    }
    
    if ($option -eq 1) {
        # Completely disable auto-mount
        Write-Host "Running disable commands..." -ForegroundColor Cyan
        
        # Create wsl.conf file using echo commands
        wsl -d OpenUbuntu -u root bash -c "echo '[automount]' > /etc/wsl.conf"
        wsl -d OpenUbuntu -u root bash -c "echo '# Disable all Windows drives auto-mount' >> /etc/wsl.conf"
        wsl -d OpenUbuntu -u root bash -c "echo 'enabled = false' >> /etc/wsl.conf"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Auto-mount has been completely disabled" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to disable auto-mount" -ForegroundColor Red
        }
    } elseif ($option -eq 2) {
        # Selective mount
        Write-Host "Running selective mount commands..." -ForegroundColor Cyan
        
        # Create wsl.conf file using echo commands
        wsl -d OpenUbuntu -u root bash -c "echo '[automount]' > /etc/wsl.conf"
        wsl -d OpenUbuntu -u root bash -c "echo '# Disable auto-mount all drives' >> /etc/wsl.conf"
        wsl -d OpenUbuntu -u root bash -c "echo 'enabled = false' >> /etc/wsl.conf"
        wsl -d OpenUbuntu -u root bash -c "echo '# Enable fstab processing' >> /etc/wsl.conf"
        wsl -d OpenUbuntu -u root bash -c "echo 'mountFsTab = true' >> /etc/wsl.conf"
        
        # Create mount point
        wsl -d OpenUbuntu -u root bash -c 'mkdir -p /mnt/c'
        
        # Edit fstab
        wsl -d OpenUbuntu -u root bash -c 'cat > /etc/fstab << EOF
C: /mnt/c drvfs defaults 0 0
EOF'
        
        # Test mount
        wsl -d OpenUbuntu -u root bash -c 'mount -a'
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Selective mount configured (only C drive)" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to mount C drive" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ Invalid option, skipping" -ForegroundColor Red
        exit
    }
    
    Write-Host "✓ Auto-mount configuration completed" -ForegroundColor Green
    Write-Host "Please run 'wsl --shutdown' to apply changes" -ForegroundColor Yellow
} else {
    Write-Host "✓ Skipping auto-mount disable" -ForegroundColor Green
}

Write-Host "=== Auto-mount disable completed ===" -ForegroundColor Green
