# SSH Tunneling - كيف يعمل مع M3SB Proxy

## 🎯 الفكرة الأساسية

```
┌─────────────┐      SSH Tunnel      ┌─────────────┐
│  Your Phone │ ←─────────────────── │  Linux VPS  │
│  (Client)   │   Port 8882/22       │  (Server)   │
└─────────────┘                      └──────┬──────┘
                                              │
                                              │ mitmdump
                                              │ Port 8882
                                              │
                                      ┌──────▼──────┐
                                      │ Game Server │
                                      │ (Free Fire) │
                                      └─────────────┘
```

## 📱 كيف يتصل العميل (اللاعب)؟

### الطريقة 1: SSH Tunneling (الأكثر أماناً)

**اللاعب يشغل سكريبت على جهازه:**
```bash
# على Linux/Mac/Windows (with OpenSSH)
ssh -L 8882:127.0.0.1:8882 root@your-vps-ip -N

# الآن اللاعب يضع في اللعبة:
Proxy: 127.0.0.1
Port: 8882
```

**لماذا هذا ممتاز؟**
- ✅ اللاعب لا يرى IP الحقيقي للـ VPS (حماية)
- ✅ الاتصال مشفر via SSH
- ✅ لا يحتاج فتح منافذ على الجدار الناري
- ✅ يتخلص من مشاكل الـ ISP blocking

### الطريقة 2:直接的 Connection (للخوادم)

**إذا كنت تدير خوادم:**
```bash
# الخادم يتصل مباشرة
ssh -L 8882:127.0.0.1:8882 root@your-vps-ip -N

# أو يضع الـ VPS في VPN
wg-quick up wg0  # WireGuard
```

## 🔧 إعداد SSH Tunneling للعملاء

### على Android:

**استخدم Termux:**
```bash
# 1. ثبت Termux
# 2. ثبت openssh
pkg install openssh

# 3. اتصل بالـ VPS مع tunneling
ssh -L 8882:127.0.0.1:8882 root@your-vps-ip -N

# 4. ضع إعدادات البروكسي:
Proxy host: 127.0.0.1
Port: 8882
```

**أو استخدم方案:**
```bash
# viele Apps propose built-in SSH tunneling
# مثل:
# - ProxyDroid
# - SSH Tunnel
# - Auto Proxy
```

### على iOS:

**استخدم Shortcuts + SSH:**
```bash
# 1. ثبت تطبيق SSH Shortcuts
# 2. أنشئ shortcut:
#    - ssh root@your-vps-ip
#    - -L 8882:127.0.0.1:8882
#    - -N

# 3. شغل الـ shortcut
# 4. استخدم Proxy في اللعبة
```

**أو استخدم Apps:**
```bash
# - Shadowrocket (الأفضل)
# - Quantumult X
# - Potatso

# إعداد في التطبيق:
# Type: SSH
# Server: your-vps-ip
# Port: 22
# Username: root
# Password: / أو مفتاح
# Local Port: 8882
# Remote Port: 8882
```

### على Windows:

**استخدم PuTTY:**
```
1. افتح PuTTY
2. أدخل:
   - Host: your-vps-ip
   - Port: 22
3. Connection → SSH → Tunnels
4. أضف:
   - Source port: 8882
   - Destination: 127.0.0.1:8882
5. Session → Save
6. Open
```

**أو استخدم OpenSSH (Windows 10+):**
```powershell
ssh -L 8882:127.0.0.1:8882 root@your-vps-ip -N
```

## 🚀 تطبيق عملي

### السيناريو 1: لاعب واحد

```bash
# على VPS:
m3sb-proxy start 8882 NECK_ANTENNA

# على هاتف اللاعب:
ssh -L 8882:127.0.0.1:8882 root@vps-ip -N

# في اللعبة:
Proxy: 127.0.0.1:8882
```

### السيناريو 2: لاعبين متعددين

```bash
# على VPS - أنشئ بوابة لكل لاعب
m3sb-proxy start 8882 NECK_ANTENNA  # للاعب 1
m3sb-proxy start 8883 STOMACH_ANTENNA  # للاعب 2
m3sb-proxy start 8884 PING  # للاعب 3

# كل لاعب يشير إلى منفذ مختلف
# اللاعب 1:
ssh -L 8882:127.0.0.1:8882 root@vps-ip -N
Proxy: 127.0.0.1:8882

# اللاعب 2:
ssh -L 8883:127.0.0.1:8883 root@vps-ip -N
Proxy: 127.0.0.1:8883

# الخ
```

### السيناريو 3: Reseller Panel

```bash
# الـ Reseller يشتري مفتاح منك
# ينشئ مفتاح بوت له
# هو يدير اللاعبين لديه

# في البوت:
# - يضيف Reseller
# - Reseller ينشئ مفاتيح
# - كل لاعب له SSH tunnel خاص
```

## 🔐 الأمان

### 1. **استخدم SSH Keys (بدلاً من كلمة المرور)**

```bash
# على VPS
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# على العميل
ssh-keygen -t ed25519
ssh-copy-id root@your-vps-ip

# الآن اتصل بدون كلمة مرور
ssh -L 8882:127.0.0.1:8882 root@vps-ip -N
```

### 2. **غير Port SSH الافتراضي**

```bash
# على VPS
nano /etc/ssh/sshd_config

# غير Port 22 إلى Port آخر
Port 2222

# أعد تحميل
systemctl restart sshd
```

### 3. **استخدم Fail2ban**

```bash
# تثبيت
apt install fail2ban

# سيحمي من Brute force attacks
```

## 📊 المراقبة

### من السيرفر:

```bash
# تحقق من الاتصالات النشطة
who  # من يتصل عبر SSH

# تحقق من العمليات
ps aux | grep mitmdump

# تحقق من المنافذ
ss -tlnp | grep -E '8882|8883|8884'
```

### من العميل:

```bash
# تحقق من Tunnel
netstat -an | grep 8882

# أو
ss -tlnp | grep 8882
```

## 🐛 استكشاف الأخطاء

### المشكلة: Port 8882 غير متاح

```bash
# على VPS - تحقق
ss -tlnp | grep 8882

# إذا لم يعمل:
systemctl restart m3sb-proxy-8882

# تحقق من السجلات
journalctl -u m3sb-proxy-8882 -f
```

### المشكلة: SSH refusing connection

```bash
# تحقق من خدمة SSH
systemctl status sshd

# تحقق من الجدار الناري
ufw status

# تحقق من Port
ss -tlnp | grep 22
```

### المشكلة: Tunnel يعمل لكن اللعبة لا تتصل

```bash
# تحقق من IP المسموح
sqlite3 /opt/m3sb/data/m3sb.db "SELECT * FROM allowed_ips WHERE ip='client-ip';"

# أضف الـ IP إذا لم يكن موجوداً
# عبر البوت أو:
sqlite3 /opt/m3sb/data/m3sb.db "INSERT INTO allowed_ips (ip, expires_at, key_used, status) VALUES ('client-ip', 9999999999, 'KEY_CODE', 'active');"
```

## 💡 نصائح احترافية

### 1. **استخدم Systemd Service للعملاء**

```bash
# أنشئ ملف على VPS للتحكم
cat > /etc/systemd/system/m3sb-client@.service << 'EOF'
[Unit]
Description=M3SB Client Tunnel for %i
After=network.target

[Service]
Type=simple
User=client-user
ExecStart=/usr/bin/ssh -L %i:127.0.0.1:%i root@your-vps-ip -N
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# تشغيل لعميل محدد
systemctl start m3sb-client@8882
```

### 2. **استخدم VPN كبديل**

```bash
# إذا كنت تريد privacy أقوى
# استخدم WireGuard:

# على VPS
apt install wireguard

# أنشئ config
wg-quick up wg0

# الآن يمكن توجيه جميع المنافذ
# عبر VPN
```

### 3. **تحسين الأداء**

```bash
# على VPS - استخدم:
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216

# يزيد سرعة الاتصال
```

## 📞 للعملاء - تعليمات سريعة

### **بعد شراء المفتاح:**

```bash
1. تواصل مع البائع
2. ستحصل على:
   - VPS IP
   - Token
   - Bot link

3. افتح البوت
4. أرسل المفتاح
5. أدخل IP الخاص بك
6. شغل:
   ssh -L 8882:127.0.0.1:8882 root@vps-ip -N
7. Genesys في اللعبة
```

### **التكوين في اللعبة:**

```
Proxy Settings:
- Host: 127.0.0.1
- Port: 8882
- (لا يحتاج username/password لل tunneling)
```

---

**الخلاصة:**
- SSH tunneling = أمن + خصوصية + مرونة
- العميل لا يحتاج إلى أي برامج خاصة
- فقط OpenSSH
- يعمل على جميع الأنظمة

**Made with ❤️ by M3SB IOS | @m3sbffxx**