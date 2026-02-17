# Dotfiles

Cross-platform terminal setup with history search, syntax highlighting, and ys theme.

## One-liner Install

**macOS / Linux:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/onatakduman/dotfiles/master/install.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/onatakduman/dotfiles/master/install.ps1 | iex
```

## What's Included

- **ys theme** on all platforms
- **History search** - type and see matching past commands as a list
- **Syntax highlighting** and **autosuggestions**
- Machine-specific config via `~/.zshrc.local` or `~/.powershell.local.ps1`

## Manual Install

```bash
git clone https://github.com/onatakduman/dotfiles.git ~/dotfiles
# macOS / Linux
~/dotfiles/install.sh
# Windows
powershell -File $env:USERPROFILE\dotfiles\install.ps1
```
