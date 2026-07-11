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

        # 设置 Tab 为菜单补全和 Intellisense
        Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete 
        
        # 设置 Ctrl+d 为退出 PowerShell
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
        # $env:_PSFZF_FZF_DEFAULT_OPTS can't toogle preview when press Ctrl+t
        # $env:_PSFZF_FZF_DEFAULT_OPTS="--height=100% --layout=reverse --border --popup " 
        $env:FZF_DEFAULT_OPTS="--height=100% --layout=reverse --border --popup "
        $env:FZF_CTRL_T_OPTS = "--preview 'pwsh -NoProfile -File $HOME\.config\fzf\preview.ps1 {} ' --preview-window wrap"
        $env:FZF_ALT_C_OPTS = "--preview 'eza --tree --color=always {}' --preview-window wrap"
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
        $script:ZoxideLoaded = $true
    }
}

# Register-EngineEvent PowerShell.OnIdle `
#     -MaxTriggerCount 1 `
#     -Action { Ensure-Zoxide } | Out-Null
# -----------------------------------------

# ----------Register----------------------
$global:IdleTasks = @(
    {Ensure-TerminalIcons} 
    {Ensure-PSFzf} 
    {Ensure-PSReadLine} 
    {Ensure-Zoxide}
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
# Invoke-Expression (& { (zoxide init powershell | Out-String) })

# -------------- starship config ----------------
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
function Invoke-Starship-TransientFunction {
  &starship module character
}
Invoke-Expression (&starship init powershell)

Enable-TransientPrompt

