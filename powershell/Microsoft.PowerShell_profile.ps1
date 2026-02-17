# Oh My Posh
oh-my-posh init pwsh --config "$env:USERPROFILE\dotfiles\powershell\ohmyposh.omp.json" | Invoke-Expression

# PSReadLine - History listesi (yazarken eslesen gecmis komutlar)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates:$true
Set-PSReadLineOption -MaximumHistoryCount 10000

# Tab ile tamamlama
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Makineye ozel ayarlar
$localProfile = "$env:USERPROFILE\.powershell.local.ps1"
if (Test-Path $localProfile) { . $localProfile }
