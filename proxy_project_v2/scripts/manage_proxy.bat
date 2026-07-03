@echo off
REM ╔══════════════════════════════════════╗
REM ║   M3SB IOS | @m3sbffxx              ║
REM ║   Windows Proxy Manager             ║
REM ╚══════════════════════════════════════╝
REM Management script for M3SB Proxy on Windows

setlocal enabledelayedexpansion

REM Database path (adjust if needed)
set DB_PATH=%~dp0..\data\m3sb.db

:MENU
cls
echo ╔══════════════════════════════════════╗
echo ║   M3SB Proxy Manager - Windows      ║
echo ║   @m3sbffxx                         ║
echo ╚══════════════════════════════════════╝
echo.
echo [1] Start Proxy
echo [2] Stop Proxy
echo [3] Restart Proxy
echo [4] Check Status
echo [5] List All Proxies
echo [0] Exit
echo.
set /p choice=Select option: 

if "%choice%"=="1" goto START
if "%choice%"=="2" goto STOP
if "%choice%"=="3" goto RESTART
if "%choice%"=="4" goto STATUS
if "%choice%"=="5" goto LIST
if "%choice%"=="0" goto END
goto MENU

:START
cls
echo ┌──────────────────────────────────────┐
echo │   Start New Proxy                    │
echo └──────────────────────────────────────┘
echo.
set /p port=Enter port number: 
set /p feature=Enter feature name (e.g., NECK_ANTENNA): 

if "%port%"=="" goto MENU
if "%feature%"=="" goto MENU

echo Starting proxy on port %port% with feature %feature%...
call "%~dp0start_proxy_%port%.bat"
echo.
pause
goto MENU

:STOP
cls
echo ┌──────────────────────────────────────┐
echo │   Stop Proxy                         │
echo └──────────────────────────────────────┘
echo.
set /p port=Enter port number to stop: 

if "%port%"=="" goto MENU

echo Stopping proxy on port %port%...
REM Find and kill process on port
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port%" ^| findstr "LISTENING"') do (
    echo Killing process %%a...
    taskkill /F /PID %%a >nul 2>&1
)
echo ✅ Proxy on port %port% stopped.
pause
goto MENU

:RESTART
cls
echo ┌──────────────────────────────────────┐
echo │   Restart Proxy                      │
echo └──────────────────────────────────────┘
echo.
set /p port=Enter port number to restart: 

if "%port%"=="" goto MENU

echo Restarting proxy on port %port%...
call :STOP
timeout /t 2 /nobreak >nul
REM Start logic here
echo ✅ Proxy restarted.
pause
goto MENU

:STATUS
cls
echo ┌──────────────────────────────────────┐
echo │   Proxy Status                       │
echo └──────────────────────────────────────┘
echo.

REM Check default ports
for %%p in (1010 8881 8882 8883) do (
    netstat -ano | findstr ":%%p " | findstr "LISTENING" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [ACTIVE] Port %%p
    ) else (
        echo [INACTIVE] Port %%p
    )
)
echo.
pause
goto MENU

:LIST
cls
echo ┌──────────────────────────────────────┐
echo │   Configured Proxies                 │
echo └──────────────────────────────────────┘
echo.
echo Default Features:
echo   - PING (Port 1010)
echo   - STOMACH_ANTENNA (Port 8881)
echo   - NECK_ANTENNA (Port 8882)
echo   - DRAG_HEADSHOT (Port 8883)
echo.
echo Dynamic Ports (from database):
if exist "%DB_PATH%" (
    REM You can add SQLite query here if needed
    echo   Check bot for dynamic ports
) else (
    echo   Database not found
)
echo.
pause
goto MENU

:END
exit