param([string[]]$files, [int]$loadwait = 6)
# Opens each file in the QB64 IDE (C:\qb64\qb64.exe), jumps to the end (Ctrl+End), saves
# (Alt, F, S) and exits (Alt, F, X). The IDE formats the code it can parse when it saves.
# Ctrl+End is sent as real key events: the IDE ignores the modifiers of SendKeys.
Add-Type @"
using System; using System.Runtime.InteropServices;
public class IdeKeys { [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra); }
"@
$ws = New-Object -ComObject WScript.Shell
function Combo($mod, $vk, $ext) {
  $f = 0; if ($ext) { $f = 1 }
  [IdeKeys]::keybd_event($mod, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 60
  [IdeKeys]::keybd_event($vk, 0, $f, [UIntPtr]::Zero); Start-Sleep -Milliseconds 60
  [IdeKeys]::keybd_event($vk, 0, $f -bor 2, [UIntPtr]::Zero); Start-Sleep -Milliseconds 60
  [IdeKeys]::keybd_event($mod, 0, 2, [UIntPtr]::Zero); Start-Sleep -Milliseconds 300
}
function MenuKeys($k) {
  $ws.SendKeys("%"); Start-Sleep -Milliseconds 700
  $ws.SendKeys("f"); Start-Sleep -Milliseconds 700
  $ws.SendKeys($k); Start-Sleep -Seconds 2
}
foreach ($f in $files) {
  $full = $f; if (-not [IO.Path]::IsPathRooted($f)) { $full = Join-Path (Split-Path $PSScriptRoot -Parent) $f }
  $p = Start-Process -FilePath "C:\qb64\qb64.exe" -ArgumentList "`"$full`"" -WorkingDirectory "C:\qb64" -PassThru
  Start-Sleep -Seconds $loadwait
  [void]$ws.AppActivate($p.Id); Start-Sleep -Milliseconds 400
  Combo 0x11 0x23 $true; Start-Sleep -Milliseconds 800 # Ctrl+End
  [void]$ws.AppActivate($p.Id); Start-Sleep -Milliseconds 300
  MenuKeys "s" # File, Save
  [void]$ws.AppActivate($p.Id); Start-Sleep -Milliseconds 300
  MenuKeys "x" # File, Exit
  $p.Refresh()
  if (-not $p.HasExited) { Stop-Process -Id $p.Id -Confirm:$false; "$f : the IDE did not exit, stopped" } else { "$f : done" }
}
