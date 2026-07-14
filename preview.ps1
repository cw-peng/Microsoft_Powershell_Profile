# ============================================================
# fzf preview script for PowerShell
#
# Required tools:
# $requiredTools = @(gcc sysinternals chafa mediainfo 7zip file bat eza fd fzf)
# scoop install $requiredTools
#
# gcc -> objdump
# sysinternals -> sigcheck
# chafa -> image preview
# mediainfo -> media metadata
# 7zip -> archive listing
# file -> file type detection
# bat -> text preview
# eza -> directory preview
# fd/fzf -> file search and selection
#
# ============================================================

param($file)


$item = Get-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue

if (-not $item) {
    exit
}


# ============================================================
# Directory
# ============================================================

if ($item.PSIsContainer) {

    eza --tree --color=always $file
    exit

}


$ext = $item.Extension.ToLowerInvariant()


# ============================================================
# Executable / Dynamic Library
# ============================================================

switch -Regex ($ext) {

    '\.(exe|dll|sys)$' {


        Write-Host "=== File Info ===" -ForegroundColor Cyan

        sigcheck $file 2>$null


        Write-Host "`n=== PE Header ===" -ForegroundColor Cyan

        objdump -f $file 2>$null


        Write-Host "`n=== Sections ===" -ForegroundColor Cyan

        objdump -h $file 2>$null |
            Select-Object -First 25


        Write-Host "`n=== Imports ===" -ForegroundColor Cyan

        objdump -p $file 2>$null |
            Select-String "DLL Name"


        break

    }


    # ========================================================
    # Image
    # ========================================================

    '\.(png|jpg|jpeg|gif|bmp|webp|avif|tiff)$' {

    chafa --format symbols --colors truecolor  --dither none $file

    break
    }


    # ========================================================
    # Audio / Video
    # ========================================================

    '\.(mp3|flac|wav|ogg|m4a|aac|mp4|mkv|avi|webm|mov|wmv)$' {


        mediainfo $file

        break

    }


    # ========================================================
    # Archive
    # ========================================================

    '\.(zip|7z|rar|tar|gz|bz2|xz)$' {


        7z l $file

        break

    }


    # ========================================================
    # Text / Source Code
    # ========================================================

    '\.(txt|md|json|xml|ini|conf|cfg|toml|yaml|yml|
        ps1|bat|cmd|
        py|c|cpp|h|hpp|cc|cxx|
        rs|go|java|js|ts|tsx|jsx)$' {


        bat --color=always --style=numbers $file

        break

    }


    # ========================================================
    # Unknown
    # ========================================================

    default {


        Write-Host "=== File ===" -ForegroundColor Cyan
        Write-Host $file


        Write-Host "`n=== Type ===" -ForegroundColor Cyan

        $item | Format-List Name,Length,Extension,CreationTime,LastWriteTime


    }

}
