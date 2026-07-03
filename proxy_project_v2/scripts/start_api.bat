@echo off
title M3SB API Server
cd /d "%~dp0.."
set M3SB_API_PORT=8080
set M3SB_DB_PATH=%CD%\data\m3sb.db
set M3SB_DATA_DIR=%CD%\data
set M3SB_LOG_DIR=%CD%\logs
set M3SB_AUTH_KEY=M3SB_PROXY
set M3SB_ACTIVE_FEATURE=NECK_ANTENNA
python scripts\m3sb_api_server.py
pause