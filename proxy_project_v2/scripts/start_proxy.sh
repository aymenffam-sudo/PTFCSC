#!/bin/bash
# ╔══════════════════════════════════════╗
# ║   M3SB IOS | @m3sbffxx              ║
# ║   Free Project For All               ║
# ╚══════════════════════════════════════╝
# Usage: ./start_proxy.sh <port> <feature>
# Example: ./start_proxy.sh 8882 NECK_ANTENNA

PORT=$1
FEATURE=$2

if [ -z "$PORT" ] || [ -z "$FEATURE" ]; then
    echo "Usage: $0 <port> <feature>"
    echo "Example: $0 8882 NECK_ANTENNA"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

export M3SB_ACTIVE_FEATURE="$FEATURE"
export M3SB_DB_PATH="$PROJECT_DIR/data/m3sb.db"
export M3SB_DATA_DIR="$PROJECT_DIR/data"
export M3SB_LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$M3SB_LOG_DIR"

echo "[M3SB] Starting proxy on port $PORT with feature $FEATURE"
mitmdump -p "$PORT" \
    --set proxyauth=M3SB:M3SB \
    --set block_global=false \
    --ssl-insecure \
    -s "$SCRIPT_DIR/m3sb_proxy.py" 2>&1 | tee -a "$M3SB_LOG_DIR/proxy_${FEATURE}.log"