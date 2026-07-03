@echo off
title M3SB Proxy - Port 8881 (Stomach Antenna)
cd /d "%~dp0.."
set M3SB_ACTIVE_FEATURE=STOMACH_ANTENNA
set M3SB_DB_PATH=%CD%\data\m3sb.db
set M3SB_DATA_DIR=%CD%\data
set M3SB_LOG_DIR=%CD%\logs
mitmdump -p 8881 --set proxyauth=M3SB:M3SB --set block_global=false --ssl-insecure -s scripts\m3sb_proxy.py
pause