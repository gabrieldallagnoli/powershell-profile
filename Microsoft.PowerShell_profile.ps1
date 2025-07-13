# -----------------------------
# --- Funções Unix-Like -------
# -----------------------------

function su {
    if ($args.Count -gt 0) {
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $($args -join ' ')"
    } else {
        Start-Process wt -Verb runAs
    }
}

function xt($f) {
    $full = Get-Item -Path $f -ErrorAction SilentlyContinue
    & "C:\Program Files\7-Zip\7z.exe" x "$($full.FullName)" -o"$pwd" -y *> $null 2>&1
}

function grep($r, $d) { if ($d) { Get-ChildItem $d | Select-String $r } else { $input | Select-String $r } }
function sed($f, $find, $repl) { (Get-Content $f).replace($find, $repl) | Set-Content $f }
function export($name, $value) { set-item -force -path "env:$name" -value $value; }
function which($n) { Get-Command $n | Select-Object -ExpandProperty Definition }
function pkill($n) { Get-Process $n -ErrorAction SilentlyContinue | Stop-Process }
function pgrep($n) { Get-Process $n }
function head($p, $n = 10) { Get-Content $p -Head $n }
function tail($p, $n = 10, [switch]$f = $false) { Get-Content $p -Tail $n -Wait:$f }
function touch($f) { "" | Out-File $f -Encoding ASCII }
function winutil { Invoke-RestMethod https://christitus.com/win | Invoke-Expression }
function mkz { param($d) mkdir $d -Force; z $d }

function trash($path) {
    $full = (Resolve-Path $path -ErrorAction Stop).Path
    if (-not (Test-Path $full)) { return }
    $item = Get-Item $full -ErrorAction Stop
    $parent = if ($item.PSIsContainer) { $item.Parent.FullName } else { $item.DirectoryName }
    $shell = New-Object -ComObject 'Shell.Application'
    $shellItem = $shell.NameSpace($parent).ParseName($item.Name)
    if ($shellItem) { $shellItem.InvokeVerb('delete') }
}

function purge {
    foreach ($arg in $args) {
        $items = Get-ChildItem -Path $arg -Force -ErrorAction SilentlyContinue -Recurse:$false

        if ($items) {
            foreach ($item in $items) {
                Remove-Item -LiteralPath $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
            }
        } else {
            if (Test-Path $arg) {
                Remove-Item -LiteralPath $arg -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
    }
}

function ll { Get-ChildItem | Format-Table -AutoSize }
function la { Get-ChildItem -Force | Format-Table -AutoSize }
function .. { z .. }
function ... { z ../.. }
function .... { z ../../.. }
function ..... { z ../../../.. }

# -----------------------------
# --- Aliases -----------------
# -----------------------------

Set-Alias ls ll
Set-Alias cl clear
Set-Alias rm purge  
Set-Alias rmv trash 
Set-Alias cat bat    
Set-Alias mk mkdir 

Remove-Alias -Force sl
Remove-Alias -Force gc
Remove-Alias -Force gp
Remove-Alias -Force gu
Remove-Alias -Force gl
Remove-Alias -Force gi

# -----------------------------
# --- WinGet Aliases ----------
# -----------------------------

function wi {
    if ($args.Count -eq 0) {
        return
    }
    winget install $args
}

function ws {
    if ($args.Count -eq 0) {
        return
    }
    winget search $args
}

function wr {
    if ($args.Count -eq 0) {
        return
    }
    winget uninstall $args
}

function wu {
    if ($args.Count -eq 0) {
        winget update --all
    } else {
        winget update $args
    }
}

function wl { winget list }

# -----------------------------
# --- Git Aliases -------------
# -----------------------------

function zyg { 
    git add -A 
    git commit -m "$args"
    git push          
}

# -----------------------------
# --- Definições do Prompt ----
# -----------------------------

$PSReadLineOptions = @{
    EditMode = 'Windows'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    PredictionSource = 'HistoryAndPlugin'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
    MaximumHistoryCount = 10000
    Colors = @{
        Command    = '#87CEEB'
        Parameter  = '#98FB98'
        Operator   = '#FFB6C1'
        Variable   = '#DDA0DD'
        String     = '#FFDAB9'
        Number     = '#B0E0E6'
        Type       = '#F0E68C'
        Comment    = '#D3D3D3'
        Keyword    = '#8367c7'
        Error      = '#FF6347'
    }
}
Set-PSReadLineOption @PSReadLineOptions
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sens = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    return -not ($sens | Where-Object { $line -match $_ })
}

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord 'Ctrl+e' -ScriptBlock { explorer . }
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

# -----------------------------
# --- Módulos Externos --------
# -----------------------------

oh-my-posh init pwsh --config $HOME\Documents\PowerShell\cobalt2.omp.json | Invoke-Expression
Import-Module -Name Terminal-Icons
Invoke-Expression (& { (zoxide init powershell | Out-String) })