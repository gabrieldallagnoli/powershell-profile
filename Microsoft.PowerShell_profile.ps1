# =============================
#     MÓDULOS EXTERNOS
# =============================

# Ícones bonitos no terminal
Import-Module -Name Terminal-Icons


# =============================
#     FUNÇÕES ESTILO UNIX
# =============================

# Executa terminal como admin, opcionalmente com comando
function sudo {
    if ($args.Count -gt 0) {
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $($args -join ' ')"
    } else {
        Start-Process wt -Verb runAs
    }
}
Set-Alias su sudo

# Recarrega o perfil do PowerShell
function reload { & $profile }

# Atualiza o perfil do GitHub, só se mudou
function update {
    try {
        $url = "https://raw.githubusercontent.com/gabrieldallagnoli/powershell-profile/refs/heads/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/profile.ps1" -ErrorAction Stop
        $newhash = Get-FileHash "$env:temp/profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item "$env:temp/profile.ps1" $PROFILE -Force
        }
    } catch {
        Write-Host "Falha ao atualizar o perfil" -ForegroundColor Red
    } finally {
        Remove-Item "$env:temp/profile.ps1" -ErrorAction SilentlyContinue
        reload
    }
}

# Extrai arquivos com 7zip
function extract($f) {
    $full = Get-Item -Path $f -ErrorAction SilentlyContinue
    & "C:\Program Files\7-Zip\7z.exe" x "$($full.FullName)" -o"$pwd" -y *> $null 2>&1
}

# Procura padrão em arquivos
function grep($r, $d) {
    if ($d) { Get-ChildItem $d | Select-String $r } else { $input | Select-String $r }
}

# Substitui texto em arquivo (simples)
function sed($f, $find, $repl) {
    (Get-Content $f).replace($find, $repl) | Set-Content $f
}

# Define variável de ambiente (estilo export do Unix)
function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}

# Mostra o caminho de um comando
function which($n) { Get-Command $n | Select-Object -ExpandProperty Definition }

# Encerra processo(s) pelo nome
function pkill($n) { Get-Process $n -ErrorAction SilentlyContinue | Stop-Process }

# Lista processos com nome
function pgrep($n) { Get-Process $n }

# Mostra as primeiras linhas de um arquivo
function head($p, $n = 10) { Get-Content $p -Head $n }

# Mostra as últimas linhas de um arquivo (com follow opcional)
function tail($p, $n = 10, [switch]$f = $false) { Get-Content $p -Tail $n -Wait:$f }

# Cria arquivo vazio
function touch($f) { "" | Out-File $f -Encoding ASCII }

# Utilitários de configuração do Windows por Chris Titus
function winutil { Invoke-RestMethod https://christitus.com/win | Invoke-Expression }

# Cria diretório e entra nele via zoxide
function mkz { param($d) mkdir $d -Force; z $d }

# Envia item para lixeira (modo visual, estilo GUI)
function trash($path) {
    $full = (Resolve-Path $path -ErrorAction Stop).Path
    if (-not (Test-Path $full)) { return }
    $item = Get-Item $full -ErrorAction Stop
    $parent = if ($item.PSIsContainer) { $item.Parent.FullName } else { $item.DirectoryName }
    $shell = New-Object -ComObject 'Shell.Application'
    $shellItem = $shell.NameSpace($parent).ParseName($item.Name)
    if ($shellItem) { $shellItem.InvokeVerb('delete') }
}

# Adiciona, comita e envia alterações
function zyg {
    git add -A
    git commit -m "$args"
    git push
}


# =============================
#     WINGET ALIASES
# =============================

# Instala um aplicativo. Ex: wi nome-do-app
function wi {
    if ($args.Count -eq 0) {
        return
    }
    winget install --id $args
}

# Pesquisa aplicativo. Ex: ws nome-do-app
function ws {
    if ($args.Count -eq 0) {
        return
    }
    winget search $args
}

# Atualiza todos ou um app. Ex: wu ou wu nome-do-app
function wu {
    if ($args.Count -eq 0) {
        winget upgrade --all
    } else {
        winget upgrade $args
    }
}

# Lista todos os apps instalados
function wl {
    winget list
}

# Remove app. Ex: wr nome-do-app
function wr {
    if ($args.Count -eq 0) {
        return
    }
    winget uninstall $args
}


# =============================
#     UTILITÁRIAS GERAIS
# =============================

# Exporta minha pasta de projetos
export "projects" "C:\TheWall\GitHub"

# Atalho para editar o perfil rapidamente
function edit {
    code $env:projects\powershell-profile
}

# Remove recursivamente (sem confirmação)
function purge {
    foreach ($arg in $args) {
        Remove-Item -LiteralPath $arg -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# Lista limpa (sem ocultos)
function ll { Get-ChildItem | Format-Table -AutoSize }

# Lista detalhada (com ocultos)
function la { Get-ChildItem -Force | Format-Table -AutoSize }

# Copia para a área de transferência
function cpy { Set-Clipboard $args[0] }

# Cola da área de transferência
function pst { Get-Clipboard }

# Sobe um nível com zoxide
function .. { z .. }

# Sobe dois níveis com zoxide
function ... { z ../.. }

# Sobe três níveis com zoxide
function .... { z ../../.. }

# Sobe quatro níveis com zoxide
function ..... { z ../../../.. }

# Visualizar funções do perfil
function help { bat $PROFILE }


# =============================
#     ALIASES
# =============================

Set-Alias cl clear       # Limpar terminal
Set-Alias ls ll          # ls → lista simples
Set-Alias rm purge       # rm → remove
Set-Alias rmv trash      # rmv  → lixeira
Set-Alias cat bat        # cat → usa bat (requer bat instalado)
Set-Alias mk mkdir       # mk → mkdir
Set-Alias xt extract     # xt → extrator


# =============================
#     HISTÓRICO E PREVISÃO
# =============================

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

# Não salva comandos com dados sensíveis no histórico
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sens = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    return -not ($sens | Where-Object { $line -match $_ })
}


# =============================
#     ATALHOS DE TECLADO
# =============================

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord 'Ctrl+e' -ScriptBlock { explorer . }
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo


# =============================
#     AUTOCOMPLETE CUSTOM
# =============================

# Autocomplete para comandos populares
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $customCompletions = @{
        'git'    = @('status', 'add', 'commit', 'push', 'pull', 'clone', 'checkout')
        'npm'    = @('install', 'start', 'run', 'test', 'build')
        'deno'   = @('run', 'compile', 'bundle', 'test', 'lint', 'fmt', 'cache', 'info', 'doc', 'upgrade')
        'winget' = @('install', 'search', 'update', 'list', 'uninstall')
    }
    $command = $commandAst.CommandElements[0].Value
    if ($customCompletions.ContainsKey($command)) {
        $customCompletions[$command] | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
Register-ArgumentCompleter -Native -CommandName git, npm, deno, winget -ScriptBlock $scriptblock

# Autocomplete para dotnet
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock


# =============================
#     OH-MY-POSH e Zoxide
# =============================

# Prompt com tema personalizado (Nord ou outro)
oh-my-posh init pwsh --config $HOME/Documents/PowerShell/oh-my-posh.json | Invoke-Expression

# Navegação inteligente com zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
