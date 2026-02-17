# Dotfiles

Cross-platform terminal setup with a consistent look and feel across macOS, Linux, and Windows.

## Quick Install

**macOS / Linux:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/onatakduman/dotfiles/master/install.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/onatakduman/dotfiles/master/install.ps1 | iex
```

## What's Included

### macOS / Linux — [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)

The installer sets up Zsh with [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) framework and the following plugins:

| Plugin | Description |
|---|---|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Inline suggestions from history as you type |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Real-time command syntax highlighting |
| [zsh-autocomplete](https://github.com/marlonrichert/zsh-autocomplete) | History-based dropdown list matching while you type |

### Windows — [Oh My Posh](https://github.com/JanDeDobbeleer/oh-my-posh)

The installer sets up PowerShell with [Oh My Posh](https://github.com/JanDeDobbeleer/oh-my-posh) prompt engine and configures:

- **PSReadLine ListView** — matching history commands appear as a dropdown list while you type
- **Tab completion** — menu-style tab completion
- **[MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts)** — automatically installed for icon support

### Shared across all platforms

- **[ys theme](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#ys)** — clean, minimal prompt on every OS
- **History search** — type and see matching past commands as a list (no duplicates)
- **Machine-specific config** — `~/.zshrc.local` (macOS/Linux) or `~/.powershell.local.ps1` (Windows) for paths and settings that differ per machine. These files are not tracked by git.

## Prompt Preview

```
# user @ hostname in ~/projects on git:main o [21:47:42]
$
```

## Manual Install

```bash
git clone https://github.com/onatakduman/dotfiles.git ~/dotfiles

# macOS / Linux
~/dotfiles/install.sh

# Windows (PowerShell)
powershell -File $env:USERPROFILE\dotfiles\install.ps1
```

## Supported Systems

| Platform | Shell | Framework |
|---|---|---|
| macOS | Zsh | Oh My Zsh |
| Ubuntu / Debian | Zsh | Oh My Zsh |
| Fedora / RHEL | Zsh | Oh My Zsh |
| Arch / Manjaro | Zsh | Oh My Zsh |
| Windows | PowerShell | Oh My Posh |
