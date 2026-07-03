@echo off
title M3SB Proxy - Port 8883 (Drag Headshot)
cd /d "%~dp0.."
set M3SB_ACTIVE_FEATURE=DRAG_HEADSHOT
set M3SB_DB_PATH=%CD%\data\m3sb.db
set M3SB_DATA_DIR=%CD%\data
set M3SB_LOG_DIR=%CD%\logs
mitmdump -p 8883 --set proxyauth=M3SB:M3SB --set block_global=false --ssl-insecure -s scripts\m3sb_proxy.py
pause