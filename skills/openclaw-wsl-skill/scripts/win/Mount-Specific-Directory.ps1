param(
    [string]$SourceDir = $null,
    [string]$TargetDir = $null,
    [switch]$Persistent = $false,
    [bool]$Confirm = $true
)

# Mount specific directory in WSL
Write-Host "=== Mounting specific directory in WSL ===" -ForegroundColor Green

# Ask user if they want to mount a specific directory
if ($Confirm -and $null -eq $SourceDir -and $null -eq $TargetDir) {
    $mountDir = Read-Host "Do you want to mount a specific Windows directory? (Y/N)"
    if ($mountDir -eq "Y" -or $mountDir -eq "y") {
        # Get source and target directories
        $SourceDir = Read-Host "Enter source directory path (e.g., /mnt/c/Projects)"
        $TargetDir = Read-Host "Enter target mount point (e.g., /home/openubuntu/projects)"
        $persistentStr = Read-Host "Do you want persistent mount (survives reboot)? (Y/N)"
        if ($persistentStr -eq "Y" -or $persistentStr -eq "y") { $Persistent = $true }
    }
} else {
    $mountDir = "Y"
}

if ($mountDir -eq "Y" -or $mountDir -eq "y") {
    if (-not [string]::IsNullOrEmpty($SourceDir) -and -not [string]::IsNullOrEmpty($TargetDir)) {
        # Directly execute commands in WSL
        Write-Host "Running mount commands for $SourceDir -> $TargetDir..." -ForegroundColor Cyan
        
        # Check if source directory exists
        wsl -d OpenUbuntu -u root bash -c "if [ -d '$SourceDir' ]; then echo 'Source directory exists'; else echo 'Source directory does not exist'; exit 1; fi"
        
        if ($LASTEXITCODE -eq 0) {
            # Create target mount point
            wsl -d OpenUbuntu -u root bash -c "mkdir -p '$TargetDir'"
            
            # Mount directory
            wsl -d OpenUbuntu -u root bash -c "mount --bind '$SourceDir' '$TargetDir'"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Successfully mounted $SourceDir to $TargetDir" -ForegroundColor Green
                
                # If persistent mount is requested
                if ($Persistent) {
                    # Check if mount already exists in fstab
                    wsl -d OpenUbuntu -u root bash -c "grep -q '$TargetDir' /etc/fstab"
                    if ($LASTEXITCODE -ne 0) {
                        # Add to fstab
                        wsl -d OpenUbuntu -u root bash -c "echo '$SourceDir $TargetDir none bind 0 0' >> /etc/fstab"
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "✓ Added to /etc/fstab for persistent mount" -ForegroundColor Green
                        } else {
                            Write-Host "✗ Failed to add to /etc/fstab" -ForegroundColor Red
                        }
                    } else {
                        Write-Host "✓ Mount point already exists in /etc/fstab" -ForegroundColor Green
                    }
                }
            } else {
                Write-Host "✗ Failed to mount directory" -ForegroundColor Red
            }
        } else {
            Write-Host "✗ Error: Source directory $SourceDir does not exist" -ForegroundColor Red
        }
        
        Write-Host "✓ Directory mount completed" -ForegroundColor Green
    } else {
        Write-Host "✗ Source or target directory not specified" -ForegroundColor Red
    }
} else {
    Write-Host "✓ Skipping directory mount" -ForegroundColor Green
}

Write-Host "=== Directory mount completed ===" -ForegroundColor Green
