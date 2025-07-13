# -----------------------------
# --- Opt-Out Telemetry -------
# -----------------------------

[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::User)

# -----------------------------
# --- Symlink -----------------
# -----------------------------

if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType SymbolicLink -Target "$PWD\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
}

# -----------------------------
# --- Install Dependencies ----
# -----------------------------

if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser -AllowClobber -ErrorAction SilentlyContinue *> $null
}

$pkgs = @(
    "7zip.7zip",
    "junegunn.fzf",
    "ajeetdsouza.zoxide",
    "JanDeDobbeleer.OhMyPosh"
)

foreach ($p in $pkgs) {
    if (-not (winget list --id $p | Select-String $p)) {
        winget install --id $p --accept-source-agreements --accept-package-agreements --silent *> $null
    }
}

# -----------------------------
# --- OhMyPosh Theme ----------
# -----------------------------

$theme = "$HOME\Documents\PowerShell\cobalt2.omp.json"
if (-not (Test-Path $theme)) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cobalt2.omp.json" `
                      -OutFile $theme -UseBasicParsing *> $null
}