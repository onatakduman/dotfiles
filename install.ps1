# Dotfiles Windows Setup (PowerShell)

$ErrorActionPreference = "Stop"
$DotfilesRepo = "https://github.com/onatakduman/dotfiles.git"
$DotfilesDir = "$env:USERPROFILE\dotfiles"

function Info($msg)  { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Ok($msg)    { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "========================================="
Write-Host "  Dotfiles Windows Setup"
Write-Host "========================================="
Write-Host ""

# --- ExecutionPolicy ---
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq "Restricted") {
    Info "Setting ExecutionPolicy..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Ok "ExecutionPolicy: RemoteSigned"
}

# --- winget check ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Warn "winget not found. Install App Installer from Microsoft Store."
    exit 1
}

# --- Install Git ---
if (Get-Command git -ErrorAction SilentlyContinue) {
    Ok "Git already installed"
} else {
    Info "Installing Git..."
    winget install Git.Git -s winget --accept-source-agreements --accept-package-agreements
    $env:PATH += ";C:\Program Files\Git\cmd"
    Ok "Git installed"
}

# --- Clone repo ---
if (Test-Path "$DotfilesDir\.git") {
    Info "Dotfiles exist, updating..."
    git -C $DotfilesDir pull --ff-only
    Ok "Dotfiles updated"
} else {
    if (Test-Path $DotfilesDir) {
        Warn "$DotfilesDir exists but is not a git repo, backing up..."
        Move-Item $DotfilesDir "$DotfilesDir.bak"
    }
    Info "Downloading dotfiles..."
    git clone --depth 1 $DotfilesRepo $DotfilesDir
    Ok "Dotfiles downloaded: $DotfilesDir"
}

# --- Install Oh My Posh ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Ok "Oh My Posh already installed"
} else {
    Info "Installing Oh My Posh..."
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
    Ok "Oh My Posh installed"
}

# --- Install Nerd Font ---
Info "Checking Nerd Font..."
$fontInstalled = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "Meslo" }
if (-not $fontInstalled) {
    $fontInstalled = Get-ChildItem "C:\Windows\Fonts" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "Meslo" }
}
if ($fontInstalled) {
    Ok "Nerd Font already installed"
} else {
    Info "Installing MesloLGS Nerd Font..."
    oh-my-posh font install meslo
    Ok "Font installed. Set 'MesloLGS Nerd Font' in your terminal settings."
}

# --- PowerShell profile symlink ---
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Info "Profile directory created: $profileDir"
}

$source = Join-Path $DotfilesDir "powershell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $PROFILE) {
    $existing = Get-Item $PROFILE
    if ($existing.LinkType -eq "SymbolicLink") {
        Remove-Item $PROFILE
    } else {
        $backup = "$PROFILE.bak"
        Move-Item $PROFILE $backup
        Warn "Existing profile backed up: $backup"
    }
}

New-Item -ItemType SymbolicLink -Path $PROFILE -Target $source | Out-Null
Ok "Profile linked: $PROFILE -> $source"

Write-Host ""
Write-Host "========================================="
Ok "Setup complete! Restart PowerShell."
Write-Host "========================================="
Write-Host ""
Write-Host "Note: Set terminal font to 'MesloLGS Nerd Font'."
Write-Host "For machine-specific config: $env:USERPROFILE\.powershell.local.ps1"
Write-Host ""
