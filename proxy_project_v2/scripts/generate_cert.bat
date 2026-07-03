@echo off
title Generate mitmproxy Certificate
echo ========================================
echo  M3SB - Generate mitmproxy Certificate
echo ========================================
echo.

set MITMPROXY_HOME=%USERPROFILE%\.mitmproxy
set CERT_SOURCE=%MITMPROXY_HOME%\mitmproxy-ca-cert.cer
set CERT_DEST=%~dp0..\certs\mitmproxy-ca-cert.cer

echo [1/3] Creating .mitmproxy directory...
if not exist "%MITMPROXY_HOME%" mkdir "%MITMPROXY_HOME%"

echo [2/3] Running mitmdump to generate certificate...
echo.
echo     A window will appear briefly.
echo     Wait 5 seconds, then close it.
echo.
pause
start /wait mitmdump -p 10001 --set block_global=false
timeout /t 3 /nobreak >nul

echo [3/3] Copying certificate to project...
if exist "%CERT_SOURCE%" (
    copy /Y "%CERT_SOURCE%" "%CERT_DEST%" >nul
    echo.
    echo ========================================
    echo  SUCCESS! Certificate generated.
    echo ========================================
    echo.
    echo Source: %CERT_SOURCE%
    echo Dest  : %CERT_DEST%
    echo.
    echo Install this certificate on your device:
    echo   1. Copy the .cer file to your phone
    echo   2. Install it as a trusted certificate
    echo.
) else (
    echo.
    echo ========================================
    echo  ERROR: Certificate not found!
    ========================================
    echo.
    echo Mitmproxy may not have generated the cert.
    echo Try running mitmdump manually:
    echo   mitmdump -p 10001
    echo.
)
pause