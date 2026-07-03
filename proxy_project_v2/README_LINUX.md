# M3SB Proxy - Linux VPS Installation Guide

## 📋 Project Overview

M3SB Proxy is a game proxy system for Free Fire with:
- **Dynamic Proxy Ports** - Add unlimited ports with any feature
- **Telegram Bot** - Full control via Telegram
- **License Key System** - Manage user access with time-limited keys
- **API Server** - REST API for external integrations
- **MITM Interception** - Inject game files on the fly

## 🚀 Quick Installation on VPS

### Prerequisites
- VPS running **Ubuntu 20.04+** or **Debian 10+**
- Root access
- Telegram Bot Token (from @BotFather)

### Installation Steps

1. **Upload the project** to your VPS:
   ```bash
   scp -r proxy_project_v2 root@your-vps-ip:/opt/
   ```

2. **Run the installer**:
   ```bash
   cd /opt/proxy_project_v2/scripts
   chmod +x *.sh
   bash install.sh
   ```

3. **Configure the bot**:
   ```bash
   nano /etc/systemd/system/m3sb-bot.service
   ```
   Replace:
   - `YOUR_BOT_TOKEN` with your actual bot token from @BotFather
   - `YOUR_ADMIN_IDS` with your Telegram ID (get it from @userinfobot)

4. **Start the services**:
   ```bash
   systemctl daemon-reload
   systemctl enable --now m3sb-bot
   systemctl enable --now m3sb-api
   ```

5. **Verify everything is running**:
   ```bash
   systemctl status m3sb-bot
   systemctl status m3sb-api
   journalctl -u m3sb-bot -f
   ```

## 🎮 Dynamic Proxy Management

This system supports **unlimited dynamic ports**. You can create any port with any feature!

### Adding a New Proxy Port

```bash
# Using the management command
m3sb-proxy start 9999 CUSTOM_FEATURE

# Or via the Telegram bot (Owner only):
# 1. Go to Proxy Control
# 2. The system will automatically create the port if it doesn't exist
```

### Available Features

The system comes with 4 default features:
- `PING` - Ping feature
- `NECK_ANTENNA` - Neck antenna feature
- `STOMACH_ANTENNA` - Stomach antenna feature
- `DRAG_HEADSHOT` - Drag headshot feature

**You can create custom features** by simply creating a directory:
```bash
mkdir -p /opt/m3sb/data/MY_CUSTOM_FEATURE
```

### Managing Proxies

```bash
# Start a proxy
m3sb-proxy start 8882 NECK_ANTENNA

# Stop a proxy
m3sb-proxy stop 8882

# Restart a proxy
m3sb-proxy restart 8882

# Check status of all proxies
m3sb-proxy status

# Check specific port status
m3sb-proxy status 8882

# List all features
m3sb-proxy list
```

## 🤖 Telegram Bot Commands

### Owner Commands
- `/start` - Open owner menu
- `/reset <key>` - Reset a used key
- `/check <key>` - Check key details

### User Commands
- Send your key (`M3SB-IOS-XXXXX-XXXXX-XXXXX`) to activate
- The bot will ask for your IP address

### Proxy Control (via Bot)
The bot automatically detects all active ports from the database. You can:
- Start/Stop/Restart any proxy port
- Upload new hex files to any port
- Change fileinfo files
- Toggle maintenance mode

## 📁 Project Structure

```
/opt/m3sb/
├── scripts/
│   ├── m3sb_bot.py              # Telegram bot
│   ├── m3sb_proxy.py            # MITM proxy addon
│   ├── m3sb_api_server.py       # Internal API server
│   ├── m3sb_web_api.py          # Public REST API
│   ├── manage_proxy.sh          # Proxy management CLI
│   ├── start_proxy.sh           # Start individual proxy
│   └── install.sh               # Installation script
├── data/
│   ├── m3sb.db                  # SQLite database
│   ├── NECK_ANTENNA/            # Feature files
│   ├── STOMACH_ANTENNA/
│   ├── PING/
│   └── DRAG_HEADSHOT/
├── logs/
│   ├── bot.log
│   ├── proxy_*.log
│   └── api.log
└── certs/
    └── mitmproxy-ca-cert.cer    # MITM certificate
```

## 🔧 Configuration

### Environment Variables

**For Bot (.env or systemd service):**
```env
M3SB_BOT_TOKEN=your_bot_token
M3SB_DB_PATH=/opt/m3sb/data/m3sb.db
M3SB_ADMIN_IDS=your_telegram_id
M3SB_LOG_DIR=/opt/m3sb/logs
M3SB_DATA_DIR=/opt/m3sb/data
M3SB_API_PORT=8080
M3SB_AUTH_KEY=M3SB_PROXY
M3SB_ACTIVE_FEATURE=NECK_ANTENNA
```

### Database Schema

The system uses SQLite with these main tables:
- `license_keys` - Generated license keys
- `allowed_ips` - Activated IP addresses with expiry
- `resellers` - Reseller accounts
- `proxy_ports` - Dynamic proxy port configuration
- `proxy_logs` - Request logs
- `api_keys` - API authentication keys
- `bot_visitors` - Bot user tracking

## 🛡️ Security Notes

1. **Firewall Configuration** (UFW):
   ```bash
   ufw allow 22/tcp      # SSH
   ufw allow 8080/tcp    # API Server
   ufw allow 1010/tcp    # Proxy ports
   ufw allow 8881/tcp
   ufw allow 8882/tcp
   ufw allow 8883/tcp
   # Add more ports as needed
   ufw enable
   ```

2. **Change Default Credentials**:
   - Change `M3SB_AUTH_KEY` in all services
   - Use strong API keys

3. **Keep System Updated**:
   ```bash
   apt update && apt upgrade -y
   ```

## 📊 Monitoring & Logs

### View Logs
```bash
# Bot logs
journalctl -u m3sb-bot -f

# API logs
journalctl -u m3sb-api -f

# Proxy logs
tail -f /opt/m3sb/logs/proxy_NECK_ANTENNA.log
```

### Check Proxy Status
```bash
# All proxies
m3sb-proxy status

# Specific port
m3sb-proxy status 8882
```

## 🔄 Updates & Maintenance

### Update the Bot
```bash
cd /opt/m3sb
git pull  # if using git
systemctl restart m3sb-bot
```

### Backup Database
```bash
cp /opt/m3sb/data/m3sb.db /opt/m3sb/data/m3sb.db.backup.$(date +%Y%m%d)
```

### Restore Database
```bash
systemctl stop m3sb-bot
cp m3sb.db.backup.YYYYMMDD /opt/m3sb/data/m3sb.db
systemctl start m3sb-bot
```

## 🐛 Troubleshooting

### Bot not starting?
```bash
# Check logs
journalctl -u m3sb-bot -n 50

# Common issues:
# - Wrong bot token
# - Database permissions
# - Python dependencies missing
```

### Proxy not working?
```bash
# Check if port is in use
ss -tlnp | grep :8882

# Check systemd service
systemctl status m3sb-proxy-8882

# View proxy logs
tail -f /opt/m3sb/logs/proxy_NECK_ANTENNA.log
```

### Permission errors?
```bash
chmod +x /opt/m3sb/scripts/*.sh
chown -R root:root /opt/m3sb
```

## 📞 Support

- Telegram: @m3sbffxx
- Channel: @m3sbffxx

## 📄 License

Free Project For All - @m3sbffxx

---

**Made with ❤️ by M3SB IOS | @m3sbffxx**