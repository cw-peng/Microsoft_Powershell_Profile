# Terminal-Icons
$script:TerminalIconsLoaded = $false

function Ensure-TerminalIcons {
    if (-not $script:TerminalIconsLoaded) {
        Import-Module Terminal-Icons
        $script:TerminalIconsLoaded = $true
    }
}

Register-EngineEvent PowerShell.OnIdle `
    -MaxTriggerCount 1 `
    -Action { Ensure-TerminalIcons } | Out-Null

# ---------------PSReadLine-------------
$script:PSReadLineSet = $false

function Ensure-PSReadLine {
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
Register-EngineEvent PowerShell.OnIdle `
    -MaxTriggerCount 1 `
    -Action { Ensure-PSReadLine} | Out-Null
# -----------------------------------------

# ------------PSFzf------------------------
$script:PSFzfLoaded = $false

function Ensure-PSFzf {
    if (-not $script:PSFzfLoaded) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordReverseHistory Ctrl+r
        $script:PSFzfLoaded = $true
    }
}

Register-EngineEvent PowerShell.OnIdle `
    -MaxTriggerCount 1 `
    -Action { Ensure-PSFzf} | Out-Null
# ------------------------------------------


# --------------alias----------------------
# 使用 ll 查看目录
function ll {
    Get-ChildItem
}

# rm -rf alias
function rmrf ($dir_path){
  Remove-Item -Recurse -Force $dir_path
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

# -------------- starship config ----------------
$ENV:STARSHIP_CONFIG = "C:\Users\cwp\.config\starship.toml"
function Invoke-Starship-TransientFunction {
  &starship module character
}
Invoke-Expression (&starship init powershell)

Enable-TransientPrompt
# -----------------------------------------------
