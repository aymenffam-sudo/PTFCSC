#!/bin/bash
# ╔══════════════════════════════════════╗
# ║   M3SB IOS | @m3sbffxx              ║
# ║   Generate MITMProxy Certificate     ║
# ╚══════════════════════════════════════╝

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   M3SB Certificate Generator         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CERT_DIR="$PROJECT_DIR/certs"

# Create certs directory
mkdir -p "$CERT_DIR"

echo -e "${YELLOW}🔐 Generating MITMProxy CA Certificate...${NC}"
echo ""

# Method 1: Using mitmdump (automatic)
echo -e "${CYAN}[1/2] Trying automatic generation via mitmdump...${NC}"

# Check if mitmdump is installed
if command -v mitmdump &> /dev/null; then
    # Run mitmdump briefly to generate cert
    timeout 5 mitmdump --set console_eventlog_verbosity=error 2>/dev/null || true
    
    # Check if cert was generated in default location
    if [ -f "$HOME/.mitmproxy/mitmproxy-ca-cert.cer" ]; then
        echo -e "${GREEN}✅ Certificate generated automatically${NC}"
        
        # Copy to project certs directory
        cp "$HOME/.mitmproxy/mitmproxy-ca-cert.cer" "$CERT_DIR/mitmproxy-ca-cert.cer"
        cp "$HOME/.mitmproxy/mitmproxy-ca-crt.pem" "$CERT_DIR/mitmproxy-ca-crt.pem" 2>/dev/null || true
        cp "$HOME/.mitmproxy/mitmproxy-ca.pem" "$CERT_DIR/mitmproxy-ca.pem" 2>/dev/null || true
        
        echo -e "${GREEN}✅ Certificate copied to: $CERT_DIR${NC}"
    else
        echo -e "${YELLOW}⚠️  Auto-generation failed, using manual method...${NC}"
        USE_MANUAL=1
    fi
else
    echo -e "${YELLOW}⚠️  mitmdump not found, using manual method...${NC}"
    USE_MANUAL=1
fi

# Method 2: Manual generation with OpenSSL
if [ "$USE_MANUAL" = "1" ]; then
    echo -e "${CYAN}[2/2] Generating certificate manually with OpenSSL...${NC}"
    
    # Check if openssl is installed
    if ! command -v openssl &> /dev/null; then
        echo -e "${RED}❌ OpenSSL not found. Installing...${NC}"
        apt-get update -qq
        apt-get install -y -qq openssl
    fi
    
    # Generate private key
    echo -e "${YELLOW}Generating private key...${NC}"
    openssl genrsa -out "$CERT_DIR/mitmproxy-ca.key" 2048
    
    # Generate certificate
    echo -e "${YELLOW}Generating certificate...${NC}"
    openssl req -x509 -new -nodes -key "$CERT_DIR/mitmproxy-ca.key" \
        -days 3650 \
        -out "$CERT_DIR/mitmproxy-ca-cert.crt" \
        -subj "/C=US/ST=State/L=City/O=M3SB/OU=Proxy/CN=M3SB Proxy CA"
    
    # Convert to .cer format (for Android)
    echo -e "${YELLOW}Converting to .cer format...${NC}"
    openssl x509 -in "$CERT_DIR/mitmproxy-ca-cert.crt" \
        -outform der \
        -out "$CERT_DIR/mitmproxy-ca-cert.cer"
    
    echo -e "${GREEN}✅ Certificate generated manually${NC}"
fi

# Set permissions
chmod 600 "$CERT_DIR"/*
chown -R root:root "$CERT_DIR"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Certificate Generated Successfully! ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📁 Certificate location:${NC}"
echo -e "   $CERT_DIR/mitmproxy-ca-cert.cer"
echo ""
echo -e "${CYAN}📋 Certificate files created:${NC}"
ls -lah "$CERT_DIR/"
echo ""
echo -e "${YELLOW}📲 Next steps:${NC}"
echo -e "1. Share this certificate with your clients:"
echo -e "   ${CYAN}$CERT_DIR/mitmproxy-ca-cert.cer${NC}"
echo ""
echo -e "2. Clients should install it on their device"
echo -e "   (See CERTIFICATE_GUIDE.md for instructions)"
echo ""
echo -e "3. Or serve it via HTTP:"
echo -e "   ${CYAN}cp $CERT_DIR/mitmproxy-ca-cert.cer /var/www/html/cert/${NC}"
echo -e "   ${CYAN}Then clients download from: http://your-vps-ip/cert/mitmproxy-ca-cert.cer${NC}"
echo ""
echo -e "${GREEN}✅ Done!${NC}"