#!/bin/bash
# ╔══════════════════════════════════════╗
# ║   M3SB IOS | @m3sbffxx              ║
# ║   Free Project For All               ║
# ╚══════════════════════════════════════╝
# Installation script for M3SB Proxy on Linux VPS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   M3SB Proxy - Linux Installer      ║${NC}"
echo -e "${CYAN}║   @m3sbffxx                         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo -e "${RED}❌ Cannot detect OS. This script supports Debian/Ubuntu-based systems.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Detected OS: $OS $VER${NC}"

# Update system
echo -e "\n${YELLOW}[1/8] Updating system packages...${NC}"
apt-get update -qq
apt-get upgrade -y -qq

# Install dependencies
echo -e "${YELLOW}[2/8] Installing dependencies...${NC}"
apt-get install -y -qq python3 python3-pip python3-venv sqlite3 git curl wget jq

# Create user and directories
echo -e "${YELLOW}[3/8] Creating directories...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
mkdir -p /opt/m3sb
mkdir -p /opt/m3sb/data
mkdir -p /opt/m3sb/logs
mkdir -p /opt/m3sb/scripts

# Copy project files
echo -e "${YELLOW}[4/8] Copying project files...${NC}"
cp -r "$PROJECT_DIR"/* /opt/m3sb/

# Set proper permissions
chmod +x /opt/m3sb/scripts/*.sh
chown -R root:root /opt/m3sb

# Install Python dependencies
echo -e "${YELLOW}[5/8] Installing Python dependencies...${NC}"
cd /opt/m3sb
python3 -m venv venv
source venv/bin/activate
pip install --quiet mitmproxy==10.3.0 python-telegram-bot==20.7 requests==2.31.0

# Create systemd services
echo -e "${YELLOW}[6/8] Creating systemd services...${NC}"

# Bot service
cat > /etc/systemd/system/m3sb-bot.service << 'EOF'
[Unit]
Description=M3SB Telegram Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/m3sb
Environment="M3SB_BOT_TOKEN=YOUR_BOT_TOKEN"
Environment="M3SB_DB_PATH=/opt/m3sb/data/m3sb.db"
Environment="M3SB_ADMIN_IDS=YOUR_ADMIN_IDS"
Environment="M3SB_LOG_DIR=/opt/m3sb/logs"
Environment="M3SB_DATA_DIR=/opt/m3sb/data"
Environment="M3SB_API_PORT=8080"
Environment="M3SB_AUTH_KEY=M3SB_PROXY"
Environment="M3SB_ACTIVE_FEATURE=NECK_ANTENNA"
ExecStart=/opt/m3sb/venv/bin/python /opt/m3sb/scripts/m3sb_bot.py
Restart=always
RestartSec=5
StandardOutput=append:/opt/m3sb/logs/bot.log
StandardError=append:/opt/m3sb/logs/bot.log

[Install]
WantedBy=multi-user.target
EOF

# API Server service
cat > /etc/systemd/system/m3sb-api.service << 'EOF'
[Unit]
Description=M3SB API Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/m3sb
Environment="M3SB_API_PORT=8080"
Environment="M3SB_DB_PATH=/opt/m3sb/data/m3sb.db"
Environment="M3SB_DATA_DIR=/opt/m3sb/data"
Environment="M3SB_LOG_DIR=/opt/m3sb/logs"
Environment="M3SB_AUTH_KEY=M3SB_PROXY"
Environment="M3SB_ACTIVE_FEATURE=NECK_ANTENNA"
ExecStart=/opt/m3sb/venv/bin/python /opt/m3sb/scripts/m3sb_api_server.py
Restart=always
RestartSec=5
StandardOutput=append:/opt/m3sb/logs/api.log
StandardError=append:/opt/m3sb/logs/api.log

[Install]
WantedBy=multi-user.target
EOF

# Initialize database
echo -e "${YELLOW}[7/8] Initializing database...${NC}"
cd /opt/m3sb
source venv/bin/activate
python3 -c "import sqlite3; conn = sqlite3.connect('/opt/m3sb/data/m3sb.db'); conn.executescript('''CREATE TABLE IF NOT EXISTS allowed_ips (ip TEXT PRIMARY KEY, expires_at INTEGER DEFAULT 0, key_used TEXT, status TEXT DEFAULT 'active', created_at TEXT DEFAULT (datetime('now'))); CREATE TABLE IF NOT EXISTS license_keys (key_code TEXT PRIMARY KEY, duration_sec INTEGER DEFAULT 2592000, status TEXT DEFAULT 'unused', created_by TEXT DEFAULT 'owner', used_by_ip TEXT, used_by_uid TEXT, used_at TEXT, created_at TEXT DEFAULT (datetime('now'))); CREATE TABLE IF NOT EXISTS resellers (telegram_id TEXT PRIMARY KEY, username TEXT, added_by TEXT, expires_at INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now'))); CREATE TABLE IF NOT EXISTS proxy_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp TEXT DEFAULT (datetime('now')), client_ip TEXT, url TEXT, action TEXT, feature TEXT, status_code INTEGER); CREATE TABLE IF NOT EXISTS api_keys (api_key TEXT PRIMARY KEY, name TEXT, created_by TEXT, created_at TEXT DEFAULT (datetime('now')), last_used TEXT, status TEXT DEFAULT 'active'); CREATE TABLE IF NOT EXISTS bot_visitors (telegram_id TEXT PRIMARY KEY, username TEXT, first_name TEXT, first_seen TEXT DEFAULT (datetime('now')), last_seen TEXT DEFAULT (datetime('now'))); CREATE TABLE IF NOT EXISTS proxy_ports (port INTEGER PRIMARY KEY, feature TEXT NOT NULL, status TEXT DEFAULT 'active', created_at TEXT DEFAULT (datetime('now')));''); conn.commit(); print('✅ Database initialized')"

# Create default proxy ports
python3 -c "
import sqlite3
conn = sqlite3.connect('/opt/m3sb/data/m3sb.db')
for port, feature in [(1010, 'PING'), (8881, 'STOMACH_ANTENNA'), (8882, 'NECK_ANTENNA'), (8883, 'DRAG_HEADSHOT')]:
    conn.execute('INSERT OR IGNORE INTO proxy_ports (port, feature, status) VALUES (?, ?, \"active\")', (port, feature))
conn.commit()
print('✅ Default proxy ports created')
conn.close()
"

# Create symlink for manage_proxy.sh
ln -sf /opt/m3sb/scripts/manage_proxy.sh /usr/local/bin/m3sb-proxy

# Reload systemd
systemctl daemon-reload

echo -e "\n${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📋 Next steps:${NC}"
echo -e "${YELLOW}1. Edit the bot token and admin IDs:${NC}"
echo -e "   nano /etc/systemd/system/m3sb-bot.service"
echo ""
echo -e "${YELLOW}2. Reload systemd and start services:${NC}"
echo -e "   systemctl daemon-reload"
echo -e "   systemctl enable --now m3sb-bot"
echo -e "   systemctl enable --now m3sb-api"
echo ""
echo -e "${YELLOW}3. Add a dynamic proxy port:${NC}"
echo -e "   m3sb-proxy start 9999 CUSTOM_FEATURE"
echo ""
echo -e "${YELLOW}4. Important: Create feature directories:${NC}"
echo -e "   mkdir -p /opt/m3sb/data/CUSTOM_FEATURE"
echo ""
echo -e "${CYAN}🔧 Management commands:${NC}"
echo -e "   m3sb-proxy start <port> <feature>"
echo -e "   m3sb-proxy stop <port>"
echo -e "   m3sb-proxy restart <port>"
echo -e "   m3sb-proxy status"
echo -e "   m3sb-proxy list"
echo ""
echo -e "${CYAN}📂 Project location: /opt/m3sb${NC}"
echo -e "${CYAN}📂 Database: /opt/m3sb/data/m3sb.db${NC}"
echo -e "${CYAN}📂 Logs: /opt/m3sb/logs/${NC}"
echo ""
echo -e "${GREEN}✅ Installation successful!${NC}"