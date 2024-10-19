param(
    [switch]$Setup,
    [switch]$Teardown,
    [string]$DistroName = "Ubuntu"
)

$networkAdapterName = "Parallels 4150 NIC"
$bridgeName = "WSL2Bridge"
$wslConfigPath = "$env:USERPROFILE\.wslconfig"

function Test-AdminPrivileges {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Setup-BridgedNetwork {
    Write-Host "Setting up bridged network for WSL2..."

    New-VMSwitch -Name $bridgeName -NetAdapterName $networkAdapterName -AllowManagementOS $true

    $bridgeIP = "192.168.1.10"
    New-NetIPAddress -IPAddress $bridgeIP -PrefixLength 24 -InterfaceAlias "vEthernet ($bridgeName)"

    $wslConfig = @"
[wsl2]
networkingMode=bridged
vmSwitch=$bridgeName
"@
    Set-Content -Path $wslConfigPath -Value $wslConfig

    wsl --shutdown
    wsl -d $DistroName -u root ip addr add 192.168.1.100/24 dev eth0
    wsl -d $DistroName -u root ip route add default via 192.168.1.1

    Write-Host "Bridged network setup complete. WSL2 instance '$DistroName' should now have a bridged network connection."
}

function Teardown-BridgedNetwork {
    Write-Host "Tearing down bridged network for WSL2..."

    Remove-VMSwitch -Name $bridgeName -Force
    Remove-Item -Path $wslConfigPath -Force -ErrorAction SilentlyContinue

    wsl --shutdown

    Write-Host "Bridged network teardown complete. WSL2 networking has been reset to default settings."
}

if (-not (Test-AdminPrivileges)) {
    Write-Host "This script requires administrator privileges. Please run PowerShell as an administrator."
    exit
}

if ($Setup) {
    Setup-BridgedNetwork
} elseif ($Teardown) {
    Teardown-BridgedNetwork
} else {
    Write-Host "Usage: .\wsl2_parallels_network_bridge.ps1 [-Setup] [-Teardown] [-DistroName <name>]"
    Write-Host "  -Setup: Set up bridged networking for WSL2"
    Write-Host "  -Teardown: Remove bridged networking and reset to default"
    Write-Host "  -DistroName: Specify the WSL2 distribution name (default: Ubuntu)"
}
