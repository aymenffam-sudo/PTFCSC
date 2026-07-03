#!/bin/bash
# ╔══════════════════════════════════════╗
# ║   M3SB IOS | @m3sbffxx              ║
# ║   Non-Root Installer for VPS        ║
# ╚══════════════════════════════════════╝
# Installation script WITHOUT root access

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   M3SB Proxy - User Installer        ║${NC}"
echo -e "${CYAN}║   (No Root Required)                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# Check if NOT root
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  You are root! Please run as normal user for this script.${NC}"
    echo -e "${YELLOW}   Or use install.sh for root installation.${NC}"
    exit 1
fi

# Get VPS info
echo -e "${YELLOW}📋 System Info:${NC}"
echo "User: $(whoami)"
echo "Home: $HOME"
echo ""

# Set directories (in user home)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_DIR="$HOME/m3sb"
DATA_DIR="$INSTALL_DIR/data"
LOG_DIR="$INSTALL_DIR/logs"
CERT_DIR="$INSTALL_DIR/certs"
VENV_DIR="$INSTALL_DIR/venv"

echo -e "${YELLOW}[1/7] Creating directories...${NC}"
mkdir -p "$DATA_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$CERT_DIR"

# Copy files
echo -e "${YELLOW}[2/7] Copying project files...${NC}"
cp -r "$PROJECT_DIR"/* "$INSTALL_DIR/"

# Install Python
echo -e "${YELLOW}[3/7] Checking Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 not found. Please install it first:${NC}"
    echo "   sudo apt install python3 python3-pip"
    exit 1
fi

# Create venv
echo -e "${YELLOW}[4/7] Creating virtual environment...${NC}"
cd "$INSTALL_DIR"
python3 -m venv "$VENV_DIR" || {
    echo -e "${RED}❌ Failed to create venv. Trying without venv...${NC}"
    VENV_DIR=""
}

# Install dependencies
echo -e "${YELLOW}[5/7] Installing Python packages...${NC}"
if [ -n "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
fi
pip install --quiet mitmproxy==10.3.0 python-telegram-bot==20.7 requests==2.31.0 2>/dev/null || {
    echo -e "${RED}❌ Failed to install packages. Try:${NC}"
    echo "   pip3 install mitmproxy python-telegram-bot requests"
}

# Setup database
echo -e "${YELLOW}[6/7] Initializing database...${NC}"
python3 -c "
import sqlite3
conn = sqlite3.connect('$DATA_DIR/m3sb.db')
conn.executescript('''
CREATE TABLE IF NOT EXISTS allowed_ips (ip TEXT PRIMARY KEY, expires_at INTEGER DEFAULT 0, key_used TEXT, status TEXT DEFAULT 'active', created_at TEXT DEFAULT (datetime('now')));
CREATE TABLE IF NOT EXISTS license_keys (key_code TEXT PRIMARY KEY, duration_sec INTEGER DEFAULT 2592000, status TEXT DEFAULT 'unused', created_by TEXT DEFAULT 'owner', used_by_ip TEXT, used_by_uid TEXT, used_at TEXT, created_at TEXT DEFAULT (datetime('now')));
CREATE TABLE IF NOT EXISTS resellers (telegram_id TEXT PRIMARY KEY, username TEXT, added_by TEXT, expires_at INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')));
CREATE TABLE IF NOT EXISTS proxy_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp TEXT DEFAULT (datetime('now')), client_ip TEXT, url TEXT, action TEXT, feature TEXT, status_code INTEGER);
CREATE TABLE IF NOT EXISTS api_keys (api_key TEXT PRIMARY KEY, name TEXT, created_by TEXT, created_at TEXT DEFAULT (datetime('now')), last_used TEXT, status TEXT DEFAULT 'active');
CREATE TABLE IF NOT EXISTS bot_visitors (telegram_id TEXT PRIMARY KEY, username TEXT, first_name TEXT, first_seen TEXT DEFAULT (datetime('now')), last_seen TEXT DEFAULT (datetime('now')));
CREATE TABLE IF NOT EXISTS proxy_ports (port INTEGER PRIMARY KEY, feature TEXT NOT NULL, status TEXT DEFAULT 'active', created_at TEXT DEFAULT (datetime('now')));
''')
conn.commit()
print('✅ Database initialized')
conn.close()
"

# Create default ports
python3 -c "
import sqlite3
conn = sqlite3.connect('$DATA_DIR/m3sb.db')
for port, feature in [(1010, 'PING'), (8881, 'STOMACH_ANTENNA'), (8882, 'NECK_ANTENNA'), (8883, 'DRAG_HEADSHOT')]:
    conn.execute('INSERT OR IGNORE INTO proxy_ports (port, feature, status) VALUES (?, ?, \"active\")', (port, feature))
conn.commit()
conn.close()
"

# Create startup scripts
echo -e "${YELLOW}[7/7] Creating startup scripts...${NC}"

cat > "$INSTALL_DIR/start_bot.sh" << EOF
#!/bin/bash
cd $INSTALL_DIR
source venv/bin/activate 2>/dev/null || true
python3 scripts/m3sb_bot.py
EOF
chmod +x "$INSTALL_DIR/start_bot.sh"

cat > "$INSTALL_DIR/start_api.sh" << EOF
#!/bin/bash
cd $INSTALL_DIR
source venv/bin/activate 2>/dev/null || true
python3 scripts/m3sb_api_server.py
EOF
chmod +x "$INSTALL_DIR/start_api.sh"

cat > "$INSTALL_DIR/start_proxy_user.sh" << EOF
#!/bin/bash
# User-level proxy (no root required)
PORT=\$1
FEATURE=\$2
if [ -z "\$PORT" ] || [ -z "\$FEATURE" ]; then
    echo "Usage: \$0 <port> <feature>"
    exit 1
fi
cd $INSTALL_DIR
source venv/bin/activate 2>/dev/null || true
export M3SB_ACTIVE_FEATURE="\$FEATURE"
export M3SB_DB_PATH="$DATA_DIR/m3sb.db"
export M3SB_DATA_DIR="$DATA_DIR"
export M3SB_LOG_DIR="$LOG_DIR"
mitmdump -p "\$PORT" --set proxyauth=M3SB:M3SB --set block_global=false --ssl-insecure -s scripts/m3sb_proxy.py
EOF
chmod +x "$INSTALL_DIR/start_proxy_user.sh"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📂 Installation directory:${NC}"
echo -e "   $INSTALL_DIR"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "1. Edit bot token:"
echo -e "   nano $INSTALL_DIR/.env"
echo ""
echo -e "2. Start the bot:"
echo -e "   $INSTALL_DIR/start_bot.sh"
echo ""
echo -e "3. Start API (in another terminal):"
echo -e "   $INSTALL_DIR/start_api.sh"
echo ""
echo -e "4. Start a proxy (in another terminal):"
echo -e "   $INSTALL_DIR/start_proxy_user.sh 8882 NECK_ANTENNA"
echo ""
echo -e "${CYAN}💡 For auto-restart, use tmux or screen:${NC}"
echo -e "   apt install tmux"
echo -e "   tmux new -s bot"
echo -e "   $INSTALL_DIR/start_bot.sh"
echo -e "   ${CYAN}(Ctrl+B then D to detach)${NC}"
echo ""
echo -e "${GREEN}✅ Done!${NC}"