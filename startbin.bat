@echo off
rem Downloads and starts the QB64 port of Wolfenstein 3-D (v1.4 shareware), see startbin.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0startbin.ps1" %*
if errorlevel 1 pause
