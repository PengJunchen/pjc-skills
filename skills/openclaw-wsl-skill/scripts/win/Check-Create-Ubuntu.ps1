# Check and create OpenUbuntu WSL distribution
Write-Host "=== Checking and creating OpenUbuntu WSL distribution ===" -ForegroundColor Green

# Check if OpenUbuntu already exists
try {
    $distros = wsl --list --quiet
    if ($distros -contains "OpenUbuntu") {
        Write-Host "✓ OpenUbuntu already exists" -ForegroundColor Green
    } else {
        Write-Host "✗ OpenUbuntu does not exist, creating..." -ForegroundColor Yellow
        
        # Create OpenUbuntu distribution
        Write-Host "Creating OpenUbuntu..." -ForegroundColor Cyan
        wsl --install -d Ubuntu --name OpenUbuntu
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ OpenUbuntu created successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to create OpenUbuntu" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "✗ Error checking/creating OpenUbuntu: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Start OpenUbuntu to ensure it's running
Write-Host "Starting OpenUbuntu..." -ForegroundColor Cyan
try {
    wsl -d OpenUbuntu -e echo "OpenUbuntu started"
    Write-Host "✓ OpenUbuntu is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to start OpenUbuntu" -ForegroundColor Red
    exit 1
}

# Get OpenUbuntu IP address
try {
    $ipAddress = wsl -d OpenUbuntu -e ip addr show eth0 | Select-String -Pattern 'inet\s+(\d+\.\d+\.\d+\.\d+)'
    if ($ipAddress) {
        $ip = $ipAddress.Matches.Groups[1].Value
        Write-Host "✓ OpenUbuntu IP address: $ip" -ForegroundColor Green
    } else {
        Write-Host "✗ Could not get OpenUbuntu IP address" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error getting IP address: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== OpenUbuntu check/create completed ===" -ForegroundColor Green
