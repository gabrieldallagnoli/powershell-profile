# =============================
# SETUP DO AMBIENTE POWERSHELL
# =============================

# === VARIÁVEIS ===
$repoProfile = "$PWD\Microsoft.PowerShell_profile.ps1"
$profilePath = $PROFILE
$poshThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json"
$poshThemeDestDir = "$HOME\Documents\PowerShell"
$poshThemeDestFile = Join-Path $poshThemeDestDir "oh-my-posh.json"

# === COPIANDO O PERFIL ===
Write-Host "📄 Copiando perfil PowerShell..."
Copy-Item -Path $repoProfile -Destination $profilePath -Force
Write-Host "✅ Perfil copiado para: $profilePath"

# === MÓDULOS POWERSHELL ===
Write-Host "`n📦 Instalando módulos do PowerShell..."
Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
Install-Module -Name oh-my-posh -Repository PSGallery -Force -Scope CurrentUser
Write-Host "✅ Terminal-Icons e oh-my-posh instalados."

# === BAIXANDO TEMA OH-MY-POSH ===
Write-Host "`n⬇️ Baixando tema oh-my-posh..."
if (-not (Test-Path $poshThemeDestDir)) {
    New-Item -ItemType Directory -Path $poshThemeDestDir | Out-Null
}
Invoke-WebRequest -Uri $poshThemeUrl -OutFile $poshThemeDestFile -UseBasicParsing
Write-Host "✅ Tema salvo em: $poshThemeDestFile"

# === PROGRAMAS COM WINGET ===
Write-Host "`n🧰 Instalando ferramentas com winget..."
$apps = @(
    "7zip.7zip",
    "ajeetdsouza.zoxide",
    "junegunn.fzf"
)

foreach ($app in $apps) {
    Write-Host "➡️ Instalando $app..."
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
}
Write-Host "✅ Instalações concluídas."

# === FINAL ===
Write-Host "`n✅ Setup finalizado. Reinicie o terminal ou execute 'pwsh' para aplicar as mudanças."