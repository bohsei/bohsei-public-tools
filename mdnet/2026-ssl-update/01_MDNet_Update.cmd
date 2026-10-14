@echo off
setlocal EnableExtensions
title MD-Net 2026 SSL Certificate Update
echo.
echo ===========================================================
echo  MD-Net SSL Certificate Update - Bohsei / 2026
echo ===========================================================
echo.
echo IMPORTANT: Finish all orders and close the MD-Net client.
echo.
set "SCRIPT_URL=https://raw.githubusercontent.com/bohsei/bohsei-public-tools/e0e8861e1c71388b9c99da254680ad991bad3c36/mdnet/2026-ssl-update/MDNet_2026_Update.ps1"
set "EXPECTED_SHA256=11EF40FE4F813245BB96DF8F475F9F8427E60D9C0D2F6FE84D9227508AD6D94D"
set "SCRIPT_PATH=%TEMP%\Bohsei_MDNet_2026_Update_%RANDOM%%RANDOM%.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Invoke-WebRequest -Uri '%SCRIPT_URL%' -UseBasicParsing -OutFile '%SCRIPT_PATH%'; $h=(Get-FileHash -LiteralPath '%SCRIPT_PATH%' -Algorithm SHA256).Hash; if($h -ne '%EXPECTED_SHA256%'){throw 'Downloaded script hash mismatch'}" 
if errorlevel 1 goto download_failed
echo Update script validated.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -Mode Update
set "RC=%ERRORLEVEL%"
if exist "%SCRIPT_PATH%" del /q "%SCRIPT_PATH%"
echo.
echo Exit code: %RC%
echo Please record the result and contact System Administration if it is not successful.
pause
exit /b %RC%
:download_failed
echo.
echo Download or SHA-256 verification failed. Nothing was updated.
if exist "%SCRIPT_PATH%" del /q "%SCRIPT_PATH%"
pause
exit /b 1
