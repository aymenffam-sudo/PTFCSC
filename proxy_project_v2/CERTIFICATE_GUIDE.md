# Certificate Guide - شهادة MITMProxy

## 📋 لماذا نحتاج شهادة؟

```
الجهاز ←──────────────────┐
                          │
اللعبة (Free Fire)        │          بدون شهادة:
                          │          ┌─────────────┐
    ┌─────────────────────┤          │   ERROR      │
    │  HTTPS Traffic      │          │  Connection  │
    │  (مشفر)            │          │  Not Secure │
    └─────────────────────┤          └─────────────┘
                          │
                      mitmdump
                          │
    ┌─────────────────────┤
    │  mitmproxy-ca-cert  │          مع الشهادة:
    │  (يفك التشفير)      │          ┌─────────────┐
    └─────────────────────┤          │ ✅ فك التشفير│
                          │          │ ✅ اعتراض    │
Internet ←─────────────────┘          │ ✅ تعديل     │
```

## 🔐 كيف تعمل الشهادة

```
1. mitmdump generates CA certificate
2. العميل يثبت الشهادة على جهازه
3. عند فتح HTTPS connections:
   - mitmdump يوقع كـ "Man-in-the-Middle"
   - يقرأ البيانات المشفرة
   - يعدلها
   - يعيدها للعميل
```

## 📱 إنشاء الشهادة

### الطريقة 1: تلقائية (موصى بها)

```bash
# على VPS - بعد التثبيت
cd /opt/m3sb

# تشغيل mitmdump مرة واحدة لإنشاء الشهادة
mitmdump --set console_eventlog_verbosity=error &
MITMPID=$!
sleep 3

# الشهادة تم إنشاؤها تلقائياً في:
ls -la ~/.mitmproxy/

# يجب أن ترى:
# - mitmproxy-ca-cert.pem
# - mitmproxy-ca-cert.cer
# - mitmproxy-ca-crt

# إيقاف mitmdump
kill $MITMPID
```

### الطريقة 2: يدوية

```bash
# إنشاء مجلد
mkdir -p /opt/m3sb/certs
cd /opt/m3sb/certs

# توليد شهادة CA
openssl genrsa -out mitmproxy-ca.key 2048

# إنشاء certificate
openssl req -x509 -new -nodes -key mitmproxy-ca.key -days 3650 \
  -out mitmproxy-ca-cert.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=M3SB Proxy CA"

# تحويل إلى .cer (للأندرويد)
openssl x509 -in mitmproxy-ca-cert.crt -outform der -out mitmproxy-ca-cert.cer

# نسخ للمجلد العام
cp mitmproxy-ca-cert.cer /opt/m3sb/certs/
```

## 📲 تثبيت الشهادة على الأجهزة

### **على Android (10+):**

```bash
الطريقة 1: عبر Wi-Fi Analyzer
1. حمل تطبيق "WiFi Analyzer" أو "HTTP Injector"
2. افتح التطبيق
3. اذهب لـ Tools → Certificate Installer
4. اختر الشهادة mitmproxy-ca-cert.cer
5. اتبع التعليمات

الطريقة 2: يدوياً
1. انقل الشهادة للهاتف:
   adb push mitmproxy-ca-cert.cer /sdcard/Download/

2. على الهاتف:
   Settings → Security → Encryption & Credentials
   → Install a certificate → CA certificate
   → اختر الملف

3. اسمح_bypass لـ:
   Settings → Network & Internet → Advanced → 
   Install certificates → Allow
```

### **على iOS (14+):**

```bash
الطريقة 1: عبر Email
1. أرسل الشهادة لنفسك بالإيميل
2. افتح الإيميل على iPhone
3. اضغط على الملف
4. Settings → Profile Downloaded
5. Install → Install (أدخل رمز)
6. Settings → General → About → Certificate Trust Settings
7. فعل الشهادة

الطريقة 2: عبر Website
1. ضع الشهادة على خادم ويب:
   http://your-vps-ip:8080/cert

2. على iPhone:
   Safari → افتح الرابط
   Allow → Download Profile
3. اتبع نفس الخطوات أعلاه
```

### **على Windows:**

```bash
الطريقة 1: عبر المتصفح
1. انقل الشهادة للجهاز
2. اضغط مرتين على الملف
3. Install Certificate
4. Current User → Place all certificates in:
   Trusted Root Certification Authorities
5. Finish

الطريقة 2: عبر PowerShell
certutil -addstore -f "Root" mitmproxy-ca-cert.cer
```

### **على Mac:**

```bash
التثبيت:
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain \
  mitmproxy-ca-cert.crt

التحقق:
sudo security find-certificate -a -c "M3SB" /Library/Keychains/System.keychain
```

## 🔧 مشاركة الشهادة مع العملاء

### **الخيار 1: عبر HTTP (الأسهل)**

```bash
# على VPS - أنشئ مجلد للشهادة
mkdir -p /var/www/html/cert
cp /opt/m3sb/certs/mitmproxy-ca-cert.cer /var/www/html/cert/

# تأكد من أن Apache/Nginx يعمل
systemctl status nginx

# الآن العملاء يمكنهم التحميل:
# http://your-vps-ip/cert/mitmproxy-ca-cert.cer
```

### **الخيار 2: عبر Telegram Bot**

```python
# في m3sb_bot.py - أضف هذا الcommand:

async def cert_cmd(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    """Send certificate to user"""
    with open('/opt/m3sb/certs/mitmproxy-ca-cert.cer', 'rb') as f:
        cert_data = f.read()
    await update.message.reply_document(
        document=cert_data,
        filename='mitmproxy-ca-cert.cer',
        caption='🔐 *M3SB Certificate*\n\nInstall this certificate on your device to use the proxy.',
        parse_mode='Markdown'
    )
```

### **الخيار 3: عبر QR Code**

```bash
# تثبيت الأدوات
apt install qrencode

# إنشاء QR Code يحتوي على الرابط
qrencode -o cert_qr.png \
  "http://your-vps-ip/cert/mitmproxy-ca-cert.cer"

# الآن العملاء يمسحون الكود
```

## ✅ التحقق من التثبيت

### **على Android:**

```bash
# 1. افتح المتصفح
# 2. ادخل على:
http://mitm.it

# أو
http://your-vps-ip:8080/cert

# 3. إذا ظهر "Connection is secure" →cellent!

# 4. تحقق من أن الشهادة نشطة:
Settings → Security → Trusted Credentials
  → يجب أن ترى "M3SB Proxy CA"
```

### **على iOS:**

```bash
# Test in Safari:
http://mitm.it

# إذا ظهر "Connection is secure" →cellent!
```

### **على Windows:**

```bash
# افتح PowerShell:
certutil -store Root | findstr "M3SB"

# يجب أن يظهر:
# Subject: CN=M3SB Proxy CA
# Issuer: CN=M3SB Proxy CA
```

## 🔄 تجديد الشهادة

```bash
# عند انتهاء صلاحية الشهادة:

# 1. احذف القديمة
rm -rf ~/.mitmproxy/

# 2. أعد تشغيل mitmdump مرة واحدة
systemctl restart m3sb-proxy-8882

# 3. أرسل الشهادة الجديدة للعملاء
# 4. طلب منهم إعادة التثبيت
```

## 🛡️ أمان الشهادة

### **1. احفظها بأمان:**
```bash
chmod 600 /opt/m3sb/certs/mitmproxy-ca-key.pem
chown root:root /opt/m3sb/certs/*

# لا تشارك المفتاح الخاص مع أحد!
```

### **2. راقب الاستخدام:**
```bash
# تحقق من أن الشهادة مثبتة فقط على الأجهزة المسموحة
sqlite3 /opt/m3sb/data/m3sb.db \
  "SELECT ip, COUNT(*) FROM proxy_logs GROUP BY ip ORDER BY COUNT(*) DESC;"
```

### **3. غيرها بانتظام:**
```bash
# كل 6 أشهر
# أو عند شك في تسريبها

# احذف من الأجهزة القديمة
# أنشئ شهادة جديدة
# وزع على العملاء
```

## ❌ مشاكل شائعة

### **المشكلة 1: NET::ERR_CERT_AUTHORITY_INVALID**

```bash
# السبب: الشهادة غير مثبتة عبر Android system

# الحل:
1. ثبت من Settings → Security → Install from storage
2. لا تستخدم Chrome
3. استخدم متصفح آخر أو app game مباشرة
```

### **المشكلة 2: Connection is not private**

```bash
# على iOS:
1. Settings → General → About → Certificate Trust Settings
2. فعل الشهادة

# على Android:
1. Settings → Security → Trusted Credentials
2. تأكد من وجود الشهادة
```

### **المشكلة 3: شهادة منتهية الصلاحية**

```bash
# تحقق من التواريخ:
openssl x509 -in mitmproxy-ca-cert.crt -noout -dates

# إذا كانت منتهية:
# أنشئ شهادة جديدة
# أعد توزيعها على العملاء
```

## 📊 معلومات الشهادة

```bash
# عرض تفاصيل الشهادة الحالية:
openssl x509 -in /opt/m3sb/certs/mitmproxy-ca-cert.crt -text -noout

# ستظهر:
# - Subject: CN=M3SB Proxy CA
# - Issuer: CN=M3SB Proxy CA
# - Validity: من ... إلى ...
# - Serial Number
```

## 💡 نصائح مهمة

1. **لا تشارك الشهادة علنًا** - فقط للعملاء المسجلين
2. **غيّرها دورياً** - كل 3-6 أشهر
3. **راقب الاستخدام** - تحقق من الأجهزة التي ثبتتها
4. **احفظ نسخة احتياطية** - في حال فُقدت
5. **استخدم أسماء مخصصة** - لا تستخدم "M3SB Proxy" العام

---

## 🎯 الخطوات السريعة (لعميل جديد):

```
1. تواصل مع البائع
2. ارسل له رسالة: "أحتاج الشهادة"
3. سيرسل لك الملف
4. ثبتها على جهازك
5. أعد تشغيل اللعبة
6. ✅ يعمل!
```

---

**ملاحظة:** بدون شهادة، البروكسي لن يعمل على الألعاب التي تستخدم HTTPS. الشهادة ضرورية 100%.

**Made with ❤️ by M3SB IOS | @m3sbffxx**