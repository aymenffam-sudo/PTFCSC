@echo off
title M3SB Telegram Bot
cd /d "%~dp0.."
set M3SB_BOT_TOKEN=8604553795:AAGu5-Gd4ArPPbbaP34BK1NJDkl8SkwS-jA
set M3SB_DB_PATH=%CD%\data\m3sb.db
set M3SB_ADMIN_IDS=6676819684
set M3SB_LOG_DIR=%CD%\logs
set M3SB_DATA_DIR=%CD%\data
set M3SB_API_PORT=8080
set M3SB_AUTH_KEY=M3SB_PROXY
set M3SB_ACTIVE_FEATURE=NECK_ANTENNA
python scripts\m3sb_bot.py
pause