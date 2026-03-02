param(
    [string]$HttpProxy = $null,
    [string]$HttpsProxy = $null,
    [string]$NoProxy = "localhost,127.0.0.1"
)

# Configure proxy settings in WSL
Write-Host "=== Configuring proxy settings in WSL ===" -ForegroundColor Green

# Ask user if they want to configure proxy
if ($null -eq $HttpProxy -and $null -eq $HttpsProxy) {
    $configureProxy = Read-Host "Do you want to configure proxy settings? (Y/N)"
    if ($configureProxy -eq "Y" -or $configureProxy -eq "y") {
        $HttpProxy = Read-Host "Enter HTTP proxy (e.g., http://proxy:8080)"
        $HttpsProxy = Read-Host "Enter HTTPS proxy (e.g., http://proxy:8080)"
        $NoProxy = Read-Host "Enter no-proxy domains (e.g., localhost,127.0.0.1)"
    }
} else {
    $configureProxy = "Y"
}

if ($configureProxy -eq "Y" -or $configureProxy -eq "y") {
    # Directly execute commands in WSL
    Write-Host "Running proxy configuration commands..." -ForegroundColor Cyan
    
    # Add proxy settings to bashrc
    wsl -d OpenUbuntu -u root bash -c "echo '' >> ~/.bashrc"
    wsl -d OpenUbuntu -u root bash -c "echo '# Proxy settings' >> ~/.bashrc"
    wsl -d OpenUbuntu -u root bash -c "echo 'export http_proxy=\"$HttpProxy\"' >> ~/.bashrc"
    wsl -d OpenUbuntu -u root bash -c "echo 'export https_proxy=\"$HttpsProxy\"' >> ~/.bashrc"
    wsl -d OpenUbuntu -u root bash -c "echo 'export no_proxy=\"$NoProxy\"' >> ~/.bashrc"
    wsl -d OpenUbuntu -u root bash -c "echo 'export HTTP_PROXY=\"$HttpProxy\"' >> ~/.bashrc"
    wsl -d OpenUbuntu -u root bash -c "echo 'export HTTPS_PROXY=\"$HttpsProxy\"' >> ~/.bashrc"
    wsl -d OpenUbuntu -u root bash -c "echo 'export NO_PROXY=\"$NoProxy\"' >> ~/.bashrc"
    
    # Apply settings
    wsl -d OpenUbuntu -u root bash -c "source ~/.bashrc"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Proxy configuration completed" -ForegroundColor Green
        Write-Host "HTTP proxy: $HttpProxy" -ForegroundColor Cyan
        Write-Host "HTTPS proxy: $HttpsProxy" -ForegroundColor Cyan
        Write-Host "No proxy: $NoProxy" -ForegroundColor Cyan
    } else {
        Write-Host "✗ Failed to configure proxy" -ForegroundColor Red
    }
} else {
    Write-Host "✓ Skipping proxy configuration" -ForegroundColor Green
}

Write-Host "=== Proxy configuration completed ===" -ForegroundColor Green
