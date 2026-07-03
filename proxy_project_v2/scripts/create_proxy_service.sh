#!/bin/bash
# ╔══════════════════════════════════════╗
# ║   M3SB IOS | @m3sbffxx              ║
# ║   Create systemd service for proxy  ║
# ╚══════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SYSTEMD_DIR="/etc/systemd/system"

PORT=$1
FEATURE=$2

if [ -z "$PORT" ] || [ -z "$FEATURE" ]; then
    echo "Usage: $0 <port> <feature>"
    echo "Example: $0 8882 NECK_ANTENNA"
    exit 1
fi

SERVICE_NAME="m3sb-proxy-${PORT}"

# Create systemd service file
cat > "${SYSTEMD_DIR}/${SERVICE_NAME}.service" << EOF
[Unit]
Description=M3SB Proxy - Port ${PORT} (${FEATURE})
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${PROJECT_DIR}
Environment="M3SB_ACTIVE_FEATURE=${FEATURE}"
Environment="M3SB_DB_PATH=${PROJECT_DIR}/data/m3sb.db"
Environment="M3SB_DATA_DIR=${PROJECT_DIR}/data"
Environment="M3SB_LOG_DIR=${PROJECT_DIR}/logs"
ExecStart=${SCRIPT_DIR}/start_proxy.sh ${PORT} ${FEATURE}
Restart=always
RestartSec=5
StandardOutput=append:${PROJECT_DIR}/logs/proxy_${FEATURE}.log
StandardError=append:${PROJECT_DIR}/logs/proxy_${FEATURE}.log

[Install]
WantedBy=multi-user.target
EOF

# Update database
sqlite3 "${PROJECT_DIR}/data/m3sb.db" \
    "INSERT OR REPLACE INTO proxy_ports (port, feature, status, created_at) VALUES (${PORT}, '${FEATURE}', 'active', datetime('now'));"

# Reload systemd
systemctl daemon-reload

echo "✅ Created systemd service: ${SERVICE_NAME}.service"
echo "✅ Updated database with port ${PORT} (${FEATURE})"
echo ""
echo "To start the proxy:"
echo "  systemctl enable --now ${SERVICE_NAME}"
echo ""
echo "To check status:"
echo "  systemctl status ${SERVICE_NAME}"