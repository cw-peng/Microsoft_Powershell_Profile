param($file)

if (Test-Path $file -PathType Leaf) {
    bat --color=always --style=numbers  $file
}
elseif (Test-Path $file -PathType Container) {
    eza --tree --color=always $file
}
else {
    Write-Host $file
}