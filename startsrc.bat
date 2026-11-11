@echo off
rem Builds the QB64 port of Wolfenstein 3-D from source and starts it (v1.4 shareware), see startsrc.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0startsrc.ps1" %*
if errorlevel 1 pause
