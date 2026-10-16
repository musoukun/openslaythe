# 画面キャプチャ: .\tools\shot.ps1 combat  (map / combat / settings / new_run / 空=タイトル)
# 全画面の見た目: .\tools\shot.ps1 combat -fullscreen  (モニタの解像度のまま全画面で撮る)
param([string]$mode = "", [int]$frames = 40, [switch]$fullscreen)
$name = if ($mode) { $mode -replace "[^A-Za-z0-9_-]", "_" } else { "title" }
if ($fullscreen) { $name += "_fullscreen" }
$out = Join-Path $env:TEMP ("openslay_shots\" + $name + "_" + (Get-Date -Format "HHmmss"))
New-Item -ItemType Directory -Force $out | Out-Null
# --write-movie は基準サイズ (1200x700) で書き出すので、全画面は --shot で実寸のまま保存する
$gargs = @("--path", "$PSScriptRoot\..")
$user = @()
if ($fullscreen) { $gargs += "--fullscreen"; $user += "--shot=$out\shot.png" }
else { $gargs += @("--write-movie", "$out\f.png", "--fixed-fps", "10", "--quit-after", "$frames") }
if ($mode) { $user += "--auto=$mode" }
if ($user) { $gargs += @("--") + $user }
godot @gargs 2>&1 | Select-String -Pattern "SCRIPT ERROR|ERROR:" | Where-Object { $_ -notmatch "resources still in use" }
Get-ChildItem "$out\*.png" | Sort-Object Name | Select-Object -Last 1 -ExpandProperty FullName
