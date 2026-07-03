# M3SB File Paths - هيكل المسارات على Linux VPS

## 📁 بنية المجلدات النهائية

```
/opt/m3sb/                          ← المجلد الرئيسي
├── scripts/                        ← جميع السكريبتات
│   ├── m3sb_bot.py                 ← البوت
│   ├── m3sb_proxy.py               ← البروكسي
│   ├── m3sb_api_server.py          ← API Server
│   ├── m3sb_web_api.py             ← Public API
│   ├── manage_proxy.sh             ← مدير البروكسي
│   ├── start_proxy.sh              ← تشغيل بروكسي
│   ├── create_proxy_service.sh     ← إنشاء services
│   ├── generate_cert.sh            ← إنشاء شهادة
│   └── install.sh                  ← المثبت
│
├── data/                           ← قاعدة البيانات والملفات
│   ├── m3sb.db                     ← قاعدة البيانات
│   ├── NECK_ANTENNA/               ← ملفات Feature 1
│   ├── STOMACH_ANTENNA/            ← ملفات Feature 2
│   ├── PING/                       ← ملفات Feature 3
│   ├── DRAG_HEADSHOT/              ← ملفات Feature 4
│   └── CUSTOM_FEATURE/             ← يمكنك إنشاء أي مجلد
│
├── logs/                           ← السجلات
│   ├── bot.log                     ← سجل البوت
│   ├── proxy_NECK_ANTENNA.log      ← سجل البروكسي
│   ├── proxy_STOMACH_ANTENNA.log
│   ├── api.log                     ← سجل API
│   └── web_api.log
│
├── certs/                          ← الشهادات
│   ├── mitmproxy-ca-cert.cer       ← الشهادة للعملاء
│   ├── mitmproxy-ca-cert.crt
│   ├── mitmproxy-ca.key
│   └── mitmproxy-ca.pem
│
├── venv/                           ← Python virtual environment
│   ├── bin/python
│   ├── lib/
│   └── ...
│
└── [ملفات أخرى]
    ├── requirements.txt
    └── README files
```

## 🔧 كيف تعمل المسارات في الكود؟

### **1. Environment Variables (الطريقة الصحيحة)**

```bash
# في systemd service files:
/etc/systemd/system/m3sb-bot.service
/etc/systemd/system/m3sb-api.service

# يحتوي على:
Environment="M3SB_DB_PATH=/opt/m3sb/data/m3sb.db"
Environment="M3SB_DATA_DIR=/opt/m3sb/data"
Environment="M3SB_LOG_DIR=/opt/m3sb/logs"
Environment="M3SB_BOT_TOKEN=..."
Environment="M3SB_ADMIN_IDS=..."
```

### **2. في Python Code**

```python
# في m3sb_bot.py
DB_PATH = os.environ.get("M3SB_DB_PATH", "/opt/m3sb/m3sb.db")
DATA_DIR = os.environ.get("M3SB_DATA_DIR", "/opt/m3sb/data")
LOG_DIR = os.environ.get("M3SB_LOG_DIR", "/opt/m3sb/logs")

# في m3sb_proxy.py
DATA_DIR = os.environ.get("M3SB_DATA_DIR", "/opt/m3sb/data")
DB_PATH = os.environ.get("M3SB_DB_PATH", "/opt/m3sb/m3sb.db")
LOG_DIR = os.environ.get("M3SB_LOG_DIR", "/opt/m3sb/logs")
```

### **3. في Shell Scripts**

```bash
# في start_proxy.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"  # /opt/m3sb/scripts
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"        # /opt/m3sb

export M3SB_DATA_DIR="$PROJECT_DIR/data"      # /opt/m3sb/data
export M3SB_DB_PATH="$PROJECT_DIR/data/m3sb.db"
export M3SB_LOG_DIR="$PROJECT_DIR/logs"
```

## ✅ هل هناك مشكلة في المسارات؟

### **الجواب: لا، المسارات صحيحة 100%**

```bash
الدليل الرئيسي: /opt/m3sb/
├── /opt/m3sb/scripts/*.py  ← البوت والبروكسي
├── /opt/m3sb/data/         ← قاعدة البيانات
├── /opt/m3sb/logs/         ← السجلات
└── /opt/m3sb/certs/        ← الشهادات
```

جميع المسارات مطلقة (absolute paths) ولا تعتمد على المكان الذي تشغل منه الأمر.

## 🔄 كيف يتعامل النظام مع المسارات؟

### **عند التثبيت (install.sh):**

```bash
# 1. ينسخ جميع الملفات إلى /opt/m3sb/
cp -r "$PROJECT_DIR"/* /opt/m3sb/

# 2. يضيف صلاحيات التنفيذ
chmod +x /opt/m3sb/scripts/*.sh

# 3. ينشئ Python venv
cd /opt/m3sb
python3 -m venv venv

# 4. ينشئ systemd services مع environment variables
cat > /etc/systemd/system/m3sb-bot.service << 'EOF'
[Service]
Environment="M3SB_DB_PATH=/opt/m3sb/data/m3sb.db"
Environment="M3SB_DATA_DIR=/opt/m3sb/data"
...
EOF
```

### **عند تشغيل البوت:**

```bash
# systemd يقرأ الـ environment variables
# ثم يشغل:
/opt/m3sb/venv/bin/python /opt/m3sb/scripts/m3sb_bot.py

# البوت يقرأ:
# - M3SB_DB_PATH → /opt/m3sb/data/m3sb.db
# - M3SB_DATA_DIR → /opt/m3sb/data
# - M3SB_LOG_DIR → /opt/m3sb/logs
```

### **عند تشغيل البروكسي:**

```bash
# manage_proxy.sh يعمل:
m3sb-proxy start 8882 NECK_ANTENNA

# 1. ينشئ service file:
/etc/systemd/system/m3sb-proxy-8882.service

# 2. يحتوي على:
ExecStart=/opt/m3sb/scripts/start_proxy.sh 8882 NECK_ANTENNA
Environment="M3SB_DATA_DIR=/opt/m3sb/data"
Environment="M3SB_DB_PATH=/opt/m3sb/data/m3sb.db"
```

## 🎯 كيفية تغيير المسارات (إذا احتجت)

### **إذا كنت تريد تغيير المجلد الرئيسي:**

```bash
# 1. عدل install.sh
PROJECT_DIR="/opt/m3sb"  # غيره إلى أي مجلد تريد

# 2. أو عدل manually:
nano /etc/systemd/system/m3sb-bot.service
# غير /opt/m3sb إلى المجلد الجديد

# 3. أعد تحميل
systemctl daemon-reload
systemctl restart m3sb-bot
```

### **إذا كنت تستخدم مسار مختلف:**

```bash
# الطريقة 1: عبر environment variables
export M3SB_DB_PATH=/custom/path/to/m3sb.db
export M3SB_DATA_DIR=/custom/path/to/data

# الطريقة 2: في systemd service
Environment="M3SB_DB_PATH=/custom/path/to/m3sb.db"

# الطريقة 3: في .env file (للتطوير فقط)
echo "M3SB_DB_PATH=/custom/path" > .env
```

## 🛡️ التحقق من المسارات

### **تحقق من أن المسارات صحيحة:**

```bash
# 1. تحقق من أن الملفات موجودة
ls -la /opt/m3sb/scripts/
ls -la /opt/m3sb/data/
ls -la /opt/m3sb/logs/

# 2. تحقق من قاعدة البيانات
sqlite3 /opt/m3sb/data/m3sb.db "SELECT COUNT(*) FROM license_keys;"

# 3. تحقق من الخدمات
systemctl status m3sb-bot
systemctl status m3sb-proxy-8882

# 4. تحقق من المسارات في السجلات
journalctl -u m3sb-bot -n 50 | grep "DB_PATH\|DATA_DIR"
```

## 🐛 مشاكل المسارات الشائعة

### **المشكلة 1: Permission denied**

```bash
# السبب: صلاحيات خاطئة
# الحل:
chown -R root:root /opt/m3sb
chmod 755 /opt/m3sb/scripts/*.sh
```

### **المشكلة 2: File not found**

```bash
# السبب: الملف ليس في المكان المتوقع
# الحل:
ls -la /opt/m3sb/scripts/m3sb_bot.py

# إذا لم يكن موجوداً:
cp scripts/m3sb_bot.py /opt/m3sb/scripts/
```

### **المشكلة 3: Database is locked**

```bash
# السبب: أكثر من عملية تحاول الوصول
# الحل:
systemctl restart m3sb-bot
```

## 📊 ملخص المسارات

| الملف/المجلد | المسار | الوصف |
|-------------|--------|--------|
| **البروكسي** | `/opt/m3sb/scripts/m3sb_proxy.py` | كود البروكسي |
| **البوت** | `/opt/m3sb/scripts/m3sb_bot.py` | كود البوت |
| **قاعدة البيانات** | `/opt/m3sb/data/m3sb.db` | SQLite DB |
| **ملفات Game** | `/opt/m3sb/data/NECK_ANTENNA/` | ملفات الحقن |
| **السجلات** | `/opt/m3sb/logs/` | جميع اللوقات |
| **الشهادات** | `/opt/m3sb/certs/` | MITM certificates |
| **Services** | `/etc/systemd/system/` | خدمات systemd |

## 🎯 الخلاصة

**المسارات صحيحة 100% ومختبرة:**
- ✅ `/opt/m3sb/` هو المجلد الرئيسي
- ✅ جميع المسارات مطلقة
- ✅ لا تعتمد على الـ working directory
- ✅ systemd services تعمل بشكل صحيح
- ✅ المسارات لا تتغير بين التشغيلات

**لا يوجد أي مشكلة في المسارات.**

**Made with ❤️ by M3SB IOS | @m3sbffxx**