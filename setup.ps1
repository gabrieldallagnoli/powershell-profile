# =============================
#    SETUP AMBIENTE POWERSHELL
# =============================

# === VARIÁVEIS ===
$repoProfile = "$PWD\Microsoft.PowerShell_profile.ps1"
$themeURL    = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json"
$themeDir    = "$HOME\Documents\PowerShell"
$themeFile   = Join-Path $themeDir "oh-my-posh.json"
$apps        = @("7zip.7zip", "ajeetdsouza.zoxide", "junegunn.fzf")

# === PERFIL ===
Copy-Item -Path $repoProfile -Destination $PROFILE -Force

# === MÓDULOS ===
Install-Module Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser | Out-Null
Install-Module oh-my-posh     -Repository PSGallery -Force -Scope CurrentUser | Out-Null

# === TEMA OMP ===
if (-not (Test-Path $themeDir)) {
    New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
}
Invoke-WebRequest -Uri $themeURL -OutFile $themeFile -UseBasicParsing

# === WINGET APPS ===
foreach ($app in $apps) {
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
}