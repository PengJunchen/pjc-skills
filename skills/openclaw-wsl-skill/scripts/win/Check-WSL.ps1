# Check if WSL is enabled
Write-Host "=== Checking WSL status ===" -ForegroundColor Green

# Check if WSL is installed
try {
    $wslStatus = wsl --status
    Write-Host "✓ WSL is installed" -ForegroundColor Green
    Write-Host "WSL status: $wslStatus" -ForegroundColor Cyan
} catch {
    Write-Host "✗ WSL is not installed or not enabled" -ForegroundColor Red
    Write-Host "Please enable WSL by running 'wsl --install' in PowerShell as administrator" -ForegroundColor Yellow
    exit 1
}

# Check WSL version
try {
    $wslVersion = wsl --version | Select-String -Pattern "WSL version:"
    if ($wslVersion) {
        Write-Host "✓ WSL 2 is installed" -ForegroundColor Green
    } else {
        Write-Host "✗ WSL 1 is installed, upgrading to WSL 2 is recommended" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Could not check WSL version" -ForegroundColor Red
}

Write-Host "=== WSL check completed ===" -ForegroundColor Green
