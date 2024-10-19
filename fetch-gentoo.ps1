if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator. Right-click on PowerShell and select 'Run as Administrator'."
    Exit
}

if (-NOT (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled') {
    Write-Host "Enabling WSL..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Write-Host "WSL enabled. Please restart your computer and run this script again."
    Exit
}

$url = "https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/current-stage3-amd64-openrc/stage3-amd64-openrc-20230507T170545Z.tar.xz"
$output = "stage3-amd64-openrc-20230507T170545Z.tar.xz"
Write-Host "Downloading Gentoo stage3 tarball..."
Invoke-WebRequest -Uri $url -OutFile $output

New-Item -Path "gentoo" -ItemType Directory

Write-Host "Extracting Gentoo tarball..."
if (Get-Command "7z" -ErrorAction SilentlyContinue) {
    7z x $output -ogentoo
} else {
    Write-Error "7-Zip is not installed. Please install 7-Zip and run this script again."
    Exit
}

Write-Host "Importing Gentoo into WSL..."
wsl --import Gentoo gentoo $output

Remove-Item $output
Remove-Item -Path "gentoo" -Recurse

Write-Host "Gentoo has been set up in WSL. You can now start it by running 'wsl -d Gentoo'"
