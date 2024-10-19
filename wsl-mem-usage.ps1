param(
    [switch]$FreeMemory,
    [switch]$ShowUsage,
    [switch]$OptimizeVHD
)

function Free-WSL2Memory {
    Write-Host "Freeing WSL 2 memory..."
    wsl --shutdown
    Write-Host "WSL 2 has been shut down. Memory should now be released back to Windows."
}

function Show-WSL2MemoryUsage {
    Write-Host "Checking WSL 2 memory usage..."
    $wslusage = wsl -- free -h
    Write-Host "WSL 2 Memory Usage:"
    Write-Host $wslusage
}

function Optimize-WSL2VHD {
    Write-Host "Optimizing WSL 2 VHD..."
    $vhdPath = "$env:LOCALAPPDATA\Packages\*\LocalState\ext4.vhdx"
    if (Test-Path $vhdPath) {
        Optimize-VHD -Path $vhdPath -Mode Full
        Write-Host "WSL 2 VHD has been optimized."
    } else {
        Write-Host "WSL 2 VHD not found. Make sure WSL 2 is installed and you have run it at least once."
    }
}

if ($FreeMemory) {
    Free-WSL2Memory
}

if ($ShowUsage) {
    Show-WSL2MemoryUsage
}

if ($OptimizeVHD) {
    Optimize-WSL2VHD
}

if (-not ($FreeMemory -or $ShowUsage -or $OptimizeVHD)) {
    Write-Host "Usage: .\wsl2_memory_management.ps1 [-FreeMemory] [-ShowUsage] [-OptimizeVHD]"
    Write-Host "  -FreeMemory: Shuts down WSL 2 to free memory"
    Write-Host "  -ShowUsage: Displays current WSL 2 memory usage"
    Write-Host "  -OptimizeVHD: Optimizes the WSL 2 VHD to reclaim disk space"
}
