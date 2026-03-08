# Oh My Posh
oh-my-posh init pwsh --config "$env:USERPROFILE\dotfiles\powershell\ohmyposh.omp.json" | Invoke-Expression

# PSReadLine - History list (matching past commands while typing)
$psrlVersion = (Get-Module PSReadLine).Version
if ($psrlVersion -ge [version]"2.2.0") {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}
Set-PSReadLineOption -HistoryNoDuplicates:$true
Set-PSReadLineOption -MaximumHistoryCount 10000

# Tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Machine-specific config
$localProfile = "$env:USERPROFILE\.powershell.local.ps1"
if (Test-Path $localProfile) { . $localProfile }
