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
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordReverseHistory Ctrl+r
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
$ENV:STARSHIP_CONFIG = "C:\Users\cwp\.config\starship.toml"
function Invoke-Starship-TransientFunction {
  &starship module character
}
Invoke-Expression (&starship init powershell)

Enable-TransientPrompt

# # -----------------------------------------------
# #region vscode python
# #version: 0.1.1

# if (-not $env:VSCODE_PYTHON_AUTOACTIVATE_GUARD) {

#     $env:VSCODE_PYTHON_AUTOACTIVATE_GUARD = '1'

#     if (($env:TERM_PROGRAM -eq 'vscode') -and ($null -ne $env:VSCODE_PYTHON_PWSH_ACTIVATE)) {

#         try {

#             Invoke-Expression $env:VSCODE_PYTHON_PWSH_ACTIVATE

#         } catch {

#             $psVersion = $PSVersionTable.PSVersion.Major

#             Write-Error "Failed to activate Python environment (PowerShell $psVersion): $_" -ErrorAction Continue

#         }

#     }

# }
# #endregion vscode python
