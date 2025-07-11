# =============================
#    SETUP AMBIENTE POWERSHELL
# =============================

# === TELEMETRIA ===
[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::User)

# === VARIÁVEIS ===
$repoProfile = "$PWD\Microsoft.PowerShell_profile.ps1"
$themeURL    = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json"
$themeDir    = "$HOME\Documents\PowerShell"
$themeFile   = Join-Path $themeDir "oh-my-posh.json"
$apps        = @("7zip.7zip", "ajeetdsouza.zoxide", "junegunn.fzf")

# === PERFIL ===
if (-not (Test-Path (Split-Path $PROFILE))) {
    New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force | Out-Null
}
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