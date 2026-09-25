# 画面キャプチャ: .\tools\shot.ps1 combat  (map / combat / 空=タイトル)
param([string]$mode = "", [int]$frames = 40)
$name = if ($mode) { $mode -replace "[^A-Za-z0-9_-]", "_" } else { "title" }
$out = Join-Path $env:TEMP ("openslay_shots\" + $name + "_" + (Get-Date -Format "HHmmss"))
New-Item -ItemType Directory -Force $out | Out-Null
$gargs = @("--path", "$PSScriptRoot\..", "--write-movie", "$out\f.png", "--fixed-fps", "10", "--quit-after", "$frames")
if ($mode) { $gargs += @("--", "--auto=$mode") }
godot @gargs 2>&1 | Select-String -Pattern "SCRIPT ERROR|ERROR:" | Where-Object { $_ -notmatch "resources still in use" }
Get-ChildItem "$out\*.png" | Sort-Object Name | Select-Object -Last 1 -ExpandProperty FullName
