#!/bin/bash
# ╔══════════════════════════════════════╗
# ║   M3SB IOS | @m3sbffxx              ║
# ║   Free Project For All               ║
# ╚══════════════════════════════════════╝
# Management script for M3SB Proxy on Linux VPS
# Usage: ./manage_proxy.sh <action> [port] [feature]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SYSTEMD_DIR="/etc/systemd/system"
DATA_DIR="$PROJECT_DIR/data"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$DATA_DIR" "$LOG_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Database path
DB_PATH="$DATA_DIR/m3sb.db"

# Function to get all proxy ports from database
get_proxy_ports() {
    if [ -f "$DB_PATH" ]; then
        sqlite3 "$DB_PATH" "SELECT port, feature, status FROM proxy_ports ORDER BY port;" 2>/dev/null
    fi
}

# Function to check if a port is in use
is_port_in_use() {
    local port=$1
    if command -v ss &> /dev/null; then
        ss -tlnp | grep -q ":$port "
    elif command -v netstat &> /dev/null; then
        netstat -tlnp 2>/dev/null | grep -q ":$port "
    else
        # Fallback: try to bind to the port
        timeout 1 bash -c "echo > /dev/tcp/0.0.0.0/$port" 2>/dev/null && return 1 || return 0
    fi
}

# Function to create systemd service
create_systemd_service() {
    local port=$1
    local feature=$2
    local service_name="m3sb-proxy-${port}"

    cat > "/tmp/${service_name}.service" << EOF
[Unit]
Description=M3SB Proxy - Port ${port} (${feature})
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${PROJECT_DIR}
Environment="M3SB_ACTIVE_FEATURE=${feature}"
Environment="M3SB_DB_PATH=${DB_PATH}"
Environment="M3SB_DATA_DIR=${DATA_DIR}"
Environment="M3SB_LOG_DIR=${LOG_DIR}"
ExecStart=${SCRIPT_DIR}/start_proxy.sh ${port} ${feature}
Restart=always
RestartSec=5
StandardOutput=append:${LOG_DIR}/proxy_${feature}.log
StandardError=append:${LOG_DIR}/proxy_${feature}.log

[Install]
WantedBy=multi-user.target
EOF

    cp "/tmp/${service_name}.service" "${SYSTEMD_DIR}/${service_name}.service"
    rm "/tmp/${service_name}.service"
    systemctl daemon-reload
}

# Function to start a proxy
start_proxy() {
    local port=$1
    local feature=$2
    local service_name="m3sb-proxy-${port}"

    if [ -z "$port" ] || [ -z "$feature" ]; then
        echo -e "${RED}Usage: $0 start <port> <feature>${NC}"
        exit 1
    fi

    # Check if port is already in use
    if systemctl is-active --quiet "$service_name" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Proxy on port $port is already running.${NC}"
        return
    fi

    # Create systemd service
    create_systemd_service "$port" "$feature"

    # Start the service
    systemctl enable "$service_name" 2>/dev/null
    systemctl start "$service_name"

    sleep 2
    if systemctl is-active --quiet "$service_name"; then
        echo -e "${GREEN}✅ Proxy started on port $port (${feature})${NC}"
        # Save to database
        sqlite3 "$DB_PATH" "INSERT OR REPLACE INTO proxy_ports (port, feature, status, created_at) VALUES ($port, '$feature', 'active', datetime('now'));" 2>/dev/null
    else
        echo -e "${RED}❌ Failed to start proxy on port $port${NC}"
        systemctl status "$service_name" --no-pager 2>&1 | tail -5
    fi
}

# Function to stop a proxy
stop_proxy() {
    local port=$1
    local service_name="m3sb-proxy-${port}"

    if [ -z "$port" ]; then
        echo -e "${RED}Usage: $0 stop <port>${NC}"
        exit 1
    fi

    systemctl stop "$service_name" 2>/dev/null
    systemctl disable "$service_name" 2>/dev/null
    rm -f "${SYSTEMD_DIR}/${service_name}.service" 2>/dev/null
    systemctl daemon-reload

    # Update database
    sqlite3 "$DB_PATH" "UPDATE proxy_ports SET status='stopped' WHERE port=$port;" 2>/dev/null

    echo -e "${GREEN}✅ Proxy on port $port stopped${NC}"
}

# Function to restart a proxy
restart_proxy() {
    local port=$1
    local service_name="m3sb-proxy-${port}"

    if [ -z "$port" ]; then
        echo -e "${RED}Usage: $0 restart <port>${NC}"
        exit 1
    fi

    systemctl restart "$service_name" 2>/dev/null
    sleep 2
    if systemctl is-active --quiet "$service_name"; then
        echo -e "${GREEN}✅ Proxy on port $port restarted${NC}"
    else
        echo -e "${RED}❌ Failed to restart proxy on port $port${NC}"
    fi
}

# Function to show status
show_status() {
    local port=$1

    if [ -n "$port" ]; then
        local service_name="m3sb-proxy-${port}"
        if systemctl is-active --quiet "$service_name" 2>/dev/null; then
            echo -e "${GREEN}🟢 Port $port: ACTIVE${NC}"
            systemctl status "$service_name" --no-pager 2>&1 | head -10
        else
            echo -e "${RED}🔴 Port $port: INACTIVE${NC}"
        fi
    else
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo -e "${CYAN}   M3SB Proxy Status - All Ports${NC}"
        echo -e "${CYAN}═══════════════════════════════════════${NC}"

        # Get ports from database
        local ports=$(sqlite3 "$DB_PATH" "SELECT port, feature, status FROM proxy_ports ORDER BY port;" 2>/dev/null)

        if [ -z "$ports" ]; then
            echo -e "${YELLOW}No proxy ports configured.${NC}"
        else
            echo "$ports" | while IFS='|' read -r p f s; do
                local service_name="m3sb-proxy-${p}"
                if systemctl is-active --quiet "$service_name" 2>/dev/null; then
                    echo -e "${GREEN}🟢 Port $p | $f | ACTIVE${NC}"
                else
                    echo -e "${RED}🔴 Port $p | $f | INACTIVE${NC}"
                fi
            done
        fi

        # Also show running mitmdump processes not in DB
        local running_ports=$(ps aux | grep mitmdump | grep -v grep | grep -oP '\-p \K\d+' | sort -u)
        if [ -n "$running_ports" ]; then
            for rp in $running_ports; do
                local in_db=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM proxy_ports WHERE port=$rp;" 2>/dev/null)
                if [ "$in_db" -eq 0 ]; then
                    echo -e "${YELLOW}🟡 Port $rp | UNKNOWN | RUNNING (not in DB)${NC}"
                fi
            done
        fi

        echo ""
        echo -e "${CYAN}Total running: $(systemctl list-units --type=service --state=running 2>/dev/null | grep -c 'm3sb-proxy')${NC}"
    fi
}

# Function to list all available features
list_features() {
    echo -e "${CYAN}Available Features:${NC}"
    echo "  PING"
    echo "  NECK_ANTENNA"
    echo "  STOMACH_ANTENNA"
    echo "  DRAG_HEADSHOT"
    echo ""
    echo -e "${YELLOW}You can also create custom features by adding files to:${NC}"
    echo "  $DATA_DIR/<FEATURE_NAME>/"
}

# Main command handler
case "${1:-help}" in
    start)
        start_proxy "$2" "$3"
        ;;
    stop)
        stop_proxy "$2"
        ;;
    restart)
        restart_proxy "$2"
        ;;
    status)
        show_status "$2"
        ;;
    list|ls)
        list_features
        ;;
    help|*)
        echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║   M3SB Proxy Manager for Linux      ║${NC}"
        echo -e "${CYAN}║   @m3sbffxx                         ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Usage:${NC}"
        echo "  $0 start <port> <feature>   - Start a proxy on a port"
        echo "  $0 stop <port>              - Stop a proxy"
        echo "  $0 restart <port>           - Restart a proxy"
        echo "  $0 status [port]            - Show proxy status"
        echo "  $0 list                     - List available features"
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo "  $0 start 8882 NECK_ANTENNA"
        echo "  $0 start 1010 PING"
        echo "  $0 stop 8882"
        echo "  $0 status"
        echo "  $0 status 8882"
        echo ""
        echo -e "${YELLOW}Dynamic Ports:${NC}"
        echo "  You can use ANY port number (1024-65535) with ANY feature."
        echo "  Example: $0 start 9999 CUSTOM_FEATURE"
        ;;
esac