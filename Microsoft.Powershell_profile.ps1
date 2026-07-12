# UTF-8 Console
$utf8 = [System.Text.UTF8Encoding]::new($false)

[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8

$OutputEncoding = $utf8

# --------------Terminal-Icons------------
$script:TerminalIconsLoaded = $false

function global:Ensure-TerminalIcons {
    if (-not $script:TerminalIconsLoaded) {
        Import-Module Terminal-Icons
        $script:TerminalIconsLoaded = $true
    }
}

# Register-EngineEvent PowerShell.OnIdle `
#     -MaxTriggerCount 1 `
#     -Action { Ensure-TerminalIcons } | Out-Null
# ----------------------------------------

# ---------------PSReadLine-------------
$script:PSReadLineSet = $false

function global:Ensure-PSReadLine {
    if (-not $script:PSReadLineSet) {
        $script:PSReadLineSet = $true
        Set-PSReadLineOption `
        -PredictionSource History `
        -PredictionViewStyle InlineView `
        -HistorySearchCursorMovesToEnd `
        -MaximumHistoryCount 500
        
        Set-PSReadLineOption -Colors @{
        Command            = "`e[93m"
        Comment            = "`e[32m"
        ContinuationPrompt = "`e[37m"
        Default            = "`e[37m"
        Emphasis           = "`e[96m"
        Error              = "`e[91m"
        InlinePrediction   = "`e[97;2;3m"
        Keyword            = "`e[92m"
        ListPrediction     = "`e[33m"
        ListPredictionSelected = "`e[48;5;238m"
        ListPredictionTooltip  = "`e[97;2;3m"
        Member             = "`e[37m"
        Number             = "`e[97m"
        Operator           = "`e[34m"
        Parameter          = "`e[37;2m"
        Selection          = "`e[30;47m"
        String             = "`e[36m"
        Type               = "`e[37m"
        Variable           = "`e[92m"
        }
        # set Tab menu completion and Intellisense
        Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete 
        
        # set Ctrl+d exit PowerShell
        Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit
    }
}
# Register-EngineEvent PowerShell.OnIdle `
#     -MaxTriggerCount 1 `
#     -Action { Ensure-PSReadLine} | Out-Null
# -----------------------------------------

# ------------PSFzf------------------------
$script:PSFzfLoaded = $false

function global:Ensure-PSFzf {
    if (-not $script:PSFzfLoaded) {
        $env:_PSFZF_FZF_DEFAULT_OPTS="--height=100% --layout=reverse --border --popup " 
        # $env:FZF_DEFAULT_OPTS="--height=100% --layout=reverse --border --popup "
        $env:FZF_CTRL_T_OPTS = "--preview 'pwsh -NoProfile -File $HOME\.config\fzf\preview.ps1 {} ' --preview-window wrap"
        $env:FZF_ALT_C_OPTS = "--preview 'eza --tree --color=always {}' --preview-window wrap"
        $env:FZF_CTRL_T_COMMAND = "fd --hidden --exclude .git "
        $env:FZF_ALT_C_COMMAND = "fd --type d"
        Import-Module PSFzf
        # replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
        Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
        $script:PSFzfLoaded = $true
    }
}

# Register-EngineEvent PowerShell.OnIdle `
#     -MaxTriggerCount 1 `
#     -Action { Ensure-PSFzf} | Out-Null
# ------------------------------------------

# -------------zoxide----------------------
$script:ZoxideLoaded = $false

function global:Ensure-Zoxide {
    if (-not $script:ZoxideLoaded) {
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
        $env:_ZO_MAXAGE=1000
        $script:ZoxideLoaded = $true

    }
}

# Register-EngineEvent PowerShell.OnIdle `
#     -MaxTriggerCount 1 `
#     -Action { Ensure-Zoxide } | Out-Null
# -----------------------------------------

# ----------Register----------------------
$global:IdleTasks = @(
    {Ensure-PSReadLine}
    {Ensure-PSFzf} 
    {Ensure-Zoxide}
    {Ensure-TerminalIcons} 
)

Register-EngineEvent PowerShell.OnIdle `
    -MaxTriggerCount 1 `
    -Action {
        foreach ($task in $global:IdleTasks) {
            & $task
        }
    } | Out-Null
# -----------------------------------------

# --------------alias----------------------
function za { zoxide add @args }
function zq { zoxide query @args }
function zr { zoxide remove @args }
# 使用 ll 查看目录
function ll {
    Get-ChildItem
}

# touch alias
function touch {
    param([string]$Path)

    try {
        (Get-Item -LiteralPath $Path).LastWriteTime = Get-Date
    }
    catch {
        New-Item -ItemType File -Path $Path | Out-Null
    }
}
# ----------------------------------------------

# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# -------------- starship config ----------------
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
function Invoke-Starship-TransientFunction {
  &starship module character
}
Invoke-Expression (&starship init powershell)

Enable-TransientPrompt

