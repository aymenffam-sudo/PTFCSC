# M3SB Proxy - إعداد عملي على Linux VPS

## 📝 الخطوات الكاملة للتشغيل

### 1️⃣ **البدء على VPS (بعد التثبيت)**

```bash
# الاتصال بـ VPS
ssh root@your-vps-ip

# الانتقال للمجلد
cd /opt/m3sb

# التأكد من أن الملفات موجودة
ls -la
```

### 2️⃣ **إعداد البوت**

```bash
# تعديل ملف الخدمة
nano /etc/systemd/system/m3sb-bot.service
```

استبدل:
- `YOUR_BOT_TOKEN` ← التوكن الحقيقي من @BotFather
- `YOUR_ADMIN_IDS` ← معرفك من @userinfobot

```bash
# حفظ: Ctrl+O، Enter
# الخروج: Ctrl+X

# إعادة تحميل systemd
systemctl daemon-reload

# تشغيل البوت
systemctl enable --now m3sb-bot

# التحقق من العمل
systemctl status m3sb-bot
```

### 3️⃣ **إعداد API Server**

```bash
# تشغيل API
systemctl enable --now m3sb-api

# التحقق
systemctl status m3sb-api
```

### 4️⃣ **إضافة بوابات البروكسي**

```bash
# الطريقة 1: عبر البوت (الأسهل)
# - افتح البوت
# - Proxy Control
# - حدد البوابة

# الطريقة 2: عبر_command line
m3sb-proxy start 8882 NECK_ANTENNA
m3sb-proxy start 8883 DRAG_HEADSHOT

# التحقق من الحالة
m3sb-proxy status
```

### 5️⃣ **إعداد SSH Tunneling (الخطوة الأهم!)**

الآن لكي تعمل، المستخدمين يحتاجون إلى:

#### **الخيار 1: SSH Tunneling للخوادم**

**على Linux/Mac:**
```bash
# توجيه Port 8882 عبر SSH
ssh -L 8882:127.0.0.1:8882 root@your-vps-ip -N

# أو لعدة منافذ
ssh -L 8882:127.0.0.1:8882 -L 8883:127.0.0.1:8883 root@your-vps-ip -N
```

**على Windows (PuTTY):**
```
1. افتح PuTTY
2. أدخل IP الخادم و Port 22
3. Connection → SSH → Tunnels
4. أضف:
   - Source port: 8882
   - Destination: 127.0.0.1:8882
   - اضغط "Add"
5. كرر لبقية المنافذ
6. Connect
```

#### **الخيار 2: إعداد Shared Proxy للجميع**

**استخدم mitmdump مباشرة:**
```bash
# على VPS، شغل proxy عام
mitmdump -p 8080 --set proxyauth=M3SB:M3SB --ssl-insecure -s /opt/m3sb/scripts/m3sb_proxy.py

# الآن المستخدمين يستخدمون:
# IP: your-vps-ip
# Port: 8080
# Username: M3SB
# Password: M3SB
```

### 6️⃣ **إعداد Firewall (UFW)**

```bash
# السماح بالمنافذ المطلوبة
ufw allow 22/tcp      # SSH
ufw allow 8080/tcp    # API
ufw allow 8881/tcp    # Proxy
ufw allow 8882/tcp    # Proxy
ufw allow 8883/tcp    # Proxy
ufw allow 1010/tcp    # Proxy

# تفعيل الجدار الناري
ufw enable

# التحقق من الحالة
ufw status
```

### 7️⃣ **إعداد Key Pinning على الهاتف**

لكي يعمل البروكسي على Android/iOS:

**على Android:**
```bash
1. تثبيت MITMProxy CA certificate
   - URL: http://your-vps-ip:8080/cert
   - أو انقل cert/mitmproxy-ca-cert.cer للهاتف

2. إعداد Proxy في الشبكة:
   - Settings → Wi-Fi → Long press network → Modify
   - Advanced → Proxy → Manual
   - Proxy hostname: your-vps-ip
   - Proxy port: 8080 (أو 8882)
   - Save

3. تثبيت Custom Client إذا لزم الأمر
```

**على iOS:**
```bash
1. Settings → Wi-Fi → info icon → HTTP Proxy → Manual
2. Server: your-vps-ip
3. Port: 8080
4. Save
5. Install certificate from http://your-vps-ip:8080/cert
6. Settings → General → About → Certificate Trust Settings
```

## 🎮 دليل المستخدم النهائي

### للعميل (اللاعب):

#### 1. **الحصول على مفتاح**
- تواصل مع البائع
- ستحصل على: `M3SB-IOS-XXXXX-XXXXX-XXXXX`

#### 2. **تفعيل المفتاح**
```bash
# افتح البوت على تيليجرام
# أرسل المفتاح
# البوت سيطلب IP address
# أدخل IP الخاص بك
# ✅ تم التفعيل!
```

#### 3. **الاتصال بالبروكسي**

**على Android:**
```bash
1. تثبيت ProxyPin أو類似 app
2. أضف proxy:
   - Host: your-vps-ip
   - Port: 8882 (أو البوابة المحددة)
   - Username: M3SB
   - Password: M3SB
3. تفعيل ProxyPin
4. افتح اللعبة
```

**على iOS:**
```bash
1. تثبيت Proxy Panel (مثل Proxyman)
2. أضف الـ proxy
3. فعله
4. شغل اللعبة
```

## 🔍 استكشاف الأخطاء

### البوت لا يعمل؟
```bash
# تحقق من السجلات
journalctl -u m3sb-bot -f

# الأخطاء الشائعة:
# - توكن خاطئ
# - صلاحيات خاطئة
# - Python dependencies مفقودة
```

### البروكسي لا يعمل؟
```bash
# تحقق من المنفذ
ss -tlnp | grep 8882

# تحقق من الخدمة
systemctl status m3sb-proxy-8882

# تحقق من السجلات
tail -f /opt/m3sb/logs/proxy_NECK_ANTENNA.log
```

### العميل لا يتصل؟
```bash
# تحقق من الجدار الناري
ufw status

# تحقق من المنفذ من الخارج
nc -zv your-vps-ip 8882

# تأكد من أن الـ IP مسموح
sqlite3 /opt/m3sb/data/m3sb.db "SELECT * FROM allowed_ips WHERE ip='client-ip';"
```

## 📊 مراقبة النظام

```bash
# عرض جميع السجلات
tail -f /opt/m3sb/logs/bot.log
tail -f /opt/m3sb/logs/proxy_*.log
tail -f /opt/m3sb/logs/api.log

# مراقبة الأداء
htop
iotop
nethogs

# مسح قاعدة البيانات
sqlite3 /opt/m3sb/data/m3sb.db "SELECT COUNT(*) FROM proxy_logs;"
```

## 🚀 نصائح احترافية

### 1. **استخدم Nginx كـ Reverse Proxy**
```bash
# تثبيت Nginx
apt install nginx

# إعداد reverse proxy لـ API
# هذا يسمح لك باستخدام HTTPS
```

### 2. **تفعيل SSL/HTTPS**
```bash
# استخدام Let's Encrypt
certbot --nginx -d m3sbios.com

# أو استخدم Cloudflare SSL
```

### 3. **النسخ الاحتياطي التلقائي**
```bash
# إضافة cron job
crontab -e

# أضف:
0 0 * * * cp /opt/m3sb/data/m3sb.db /opt/m3sb/backups/m3sb_$(date +\%Y\%m\%d).db
```

### 4. **مراقبة Up-time**
```bash
# استخدم UptimeRobot أو خدمات مشابهة
# لمراقبة أن الخدمات تعمل
```

## 📞 الدعم السريع

### قبل الاتصال بالدعم:
1. تحقق من البوت يعمل: `systemctl status m3sb-bot`
2. تحقق من السجلات: `journalctl -u m3sb-bot -n 50`
3. تحقق من端口: `ss -tlnp | grep 8882`
4. تحقق من قاعدة البيانات: `sqlite3 /opt/m3sb/data/m3sb.db "SELECT COUNT(*) FROM allowed_ips;"`

### معلومات ضرورية عند الاتصال:
- إصدار النظام: `cat /etc/os-release`
- حالة الخدمات: `systemctl status m3sb-bot m3sb-api`
- آخر 50 سطر من البوت: `journalctl -u m3sb-bot -n 50`

---

**ملاحظة**: هذا النظام مصمم للاستخدام على VPS Linux. استخدامه على قد يكون محدوداً.

**Made with ❤️ by M3SB IOS | @m3sbffxx**