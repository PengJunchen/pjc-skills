# Fix mount configuration for WSL
Write-Host "=== Fixing WSL Mount Configuration ===" -ForegroundColor Green

# Step 1: Disable auto-mount and enable selective mounting
Write-Host "Step 1: Configuring selective mount..." -ForegroundColor Cyan

# Create wsl.conf with proper configuration
wsl -d OpenUbuntu -u root bash -c "echo '[automount]' > /etc/wsl.conf"
wsl -d OpenUbuntu -u root bash -c "echo 'enabled = false' >> /etc/wsl.conf"
wsl -d OpenUbuntu -u root bash -c "echo 'mountFsTab = true' >> /etc/wsl.conf"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ wsl.conf configured successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to configure wsl.conf" -ForegroundColor Red
}

# Step 2: Create mount points for C and E drives
Write-Host "Step 2: Creating mount points..." -ForegroundColor Cyan

wsl -d OpenUbuntu -u root bash -c "mkdir -p /mnt/c"
wsl -d OpenUbuntu -u root bash -c "mkdir -p /mnt/e"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Mount points created successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to create mount points" -ForegroundColor Red
}

# Step 3: Update fstab to mount C and E drives
Write-Host "Step 3: Updating fstab..." -ForegroundColor Cyan

# Clear existing fstab entries for Windows drives
wsl -d OpenUbuntu -u root bash -c "grep -v 'C:' /etc/fstab | grep -v 'E:' > /etc/fstab.tmp && mv /etc/fstab.tmp /etc/fstab"

# Add C and E drives to fstab
wsl -d OpenUbuntu -u root bash -c "echo 'C: /mnt/c drvfs defaults 0 0' >> /etc/fstab"
wsl -d OpenUbuntu -u root bash -c "echo 'E: /mnt/e drvfs defaults 0 0' >> /etc/fstab"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ fstab updated successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to update fstab" -ForegroundColor Red
}

# Step 4: Mount specific directory
Write-Host "Step 4: Mounting specific directory..." -ForegroundColor Cyan

# Define source and target directories
$sourceDir = "/mnt/e/Work/202603AgentSkills/test"
$targetDir = "/home/test"

# Create target mount point
wsl -d OpenUbuntu -u root bash -c "mkdir -p '$targetDir'"

# Mount directory
wsl -d OpenUbuntu -u root bash -c "mount --bind '$sourceDir' '$targetDir'"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Successfully mounted $sourceDir to $targetDir" -ForegroundColor Green
    
    # Add to fstab for persistent mount
    wsl -d OpenUbuntu -u root bash -c "grep -q '$targetDir' /etc/fstab || echo '$sourceDir $targetDir none bind 0 0' >> /etc/fstab"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Added to /etc/fstab for persistent mount" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to add to /etc/fstab" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Failed to mount directory" -ForegroundColor Red
    # List available directories
    Write-Host "Available directories in /mnt:" -ForegroundColor Yellow
    wsl -d OpenUbuntu -u root bash -c "ls -la /mnt"
}

# Step 5: Restart WSL to apply changes
Write-Host "Step 5: Restarting WSL..." -ForegroundColor Cyan
wsl --shutdown
Start-Sleep -Seconds 3
# Start OpenUbuntu again
wsl -d OpenUbuntu -u root echo "OpenUbuntu restarted"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ WSL restarted successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to restart WSL" -ForegroundColor Red
}

# Step 6: Verify mounts
Write-Host "Step 6: Verifying mounts..." -ForegroundColor Cyan

wsl -d OpenUbuntu -u root bash -c "mount | grep -E 'C:|E:'"
Write-Host ""
wsl -d OpenUbuntu -u root bash -c "ls -la /mnt"
Write-Host ""
wsl -d OpenUbuntu -u root bash -c "if [ -d '$targetDir' ]; then echo 'Target directory exists: $targetDir'; ls -la '$targetDir'; else echo 'Target directory does not exist: $targetDir'; fi"

Write-Host ""
Write-Host "=== Mount Configuration Fix Complete ===" -ForegroundColor Green
Write-Host "All necessary drives and directories have been configured for mounting." -ForegroundColor Cyan
Write-Host "You can now access your Windows drives and specific directories in WSL." -ForegroundColor Cyan
