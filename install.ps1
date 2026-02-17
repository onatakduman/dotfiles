# Dotfiles Windows Kurulumu (PowerShell)
# Yonetici olarak calistirin: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

$ErrorActionPreference = "Stop"
$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Info($msg)  { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Ok($msg)    { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "========================================="
Write-Host "  Dotfiles Windows Kurulumu"
Write-Host "========================================="
Write-Host ""

# --- winget kontrol ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Warn "winget bulunamadi. Microsoft Store'dan App Installer'i kurun."
    exit 1
}

# --- Oh My Posh kurulumu ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Ok "Oh My Posh zaten kurulu"
} else {
    Info "Oh My Posh kuruluyor..."
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
    Ok "Oh My Posh kuruldu"
}

# --- Nerd Font kurulumu ---
Info "Nerd Font kontrol ediliyor..."
$fontInstalled = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "Meslo" }
if (-not $fontInstalled) {
    $fontInstalled = Get-ChildItem "C:\Windows\Fonts" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "Meslo" }
}
if ($fontInstalled) {
    Ok "Nerd Font zaten kurulu"
} else {
    Info "MesloLGS Nerd Font kuruluyor..."
    oh-my-posh font install meslo
    Ok "Font kuruldu. Terminal ayarlarindan 'MesloLGS Nerd Font' secin."
}

# --- PowerShell profil symlink ---
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Info "Profil dizini olusturuldu: $profileDir"
}

$source = Join-Path $DotfilesDir "powershell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $PROFILE) {
    $existing = Get-Item $PROFILE
    if ($existing.LinkType -eq "SymbolicLink") {
        Remove-Item $PROFILE
    } else {
        $backup = "$PROFILE.bak"
        Move-Item $PROFILE $backup
        Warn "Mevcut profil yedeklendi: $backup"
    }
}

New-Item -ItemType SymbolicLink -Path $PROFILE -Target $source | Out-Null
Ok "Profil baglandi: $PROFILE -> $source"

Write-Host ""
Write-Host "========================================="
Ok "Kurulum tamamlandi! PowerShell'i yeniden acin."
Write-Host "========================================="
Write-Host ""
Write-Host "Not: Terminal fontunu 'MesloLGS Nerd Font' olarak degistirin."
Write-Host "Makineye ozel ayarlar icin: $env:USERPROFILE\.powershell.local.ps1"
Write-Host ""
