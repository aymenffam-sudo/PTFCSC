# M3SB Proxy - Cross-Platform Support (Linux + Windows)

## 📊 المخطط العام للنظام

```
┌─────────────────────────────────────────────────────────┐
│                    M3SB Proxy System                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐    ┌──────────────┐                  │
│  │   Linux VPS  │    │   Windows    │                  │
│  │   (مفضل)    │    │   (قديم)     │                  │
│  └──────┬───────┘    └──────┬───────┘                  │
│         │                   │                           │
│         └───────────┬───────┘                           │
│                     │                                   │
│          ┌──────────▼──────────┐                        │
│          │   Telegram Bot      │                        │
│          │   (يتحدث معك)       │                        │
│          └──────────┬──────────┘                        │
│                     │                                   │
│          ┌──────────▼──────────┐                        │
│          │   SQLite Database   │                        │
│          │   (يحفظ الكيوز)     │                        │
│          └─────────────────────┘                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 🎯 الميزات الأساسية

### 1. **بوابات ديناميكية (Dynamic Ports)**
- يمكنك إضافة **أي عدد من البوابات** (Ports)
- كل بوابة تستخدم **Feature** مختلفة أو مخصصة
- البوت يتحكم في جميع البوابات تلقائياً

### 2. **نظام الكيوز (License Keys)**
- إنشاء كيوز بصلاحيات مختلفة
- إدارة الـ IPs المسموح لها
- صلاحيات Resellers

### 3. **البروكسي (MITM Proxy)**
- اعتراض الملفات من اللعبة
- تعديلها على الطيران
- إرسال ملفات مخصصة للعملاء

## 🐧 Linux VPS (الطريقة المفضلة)

### لماذا Linux؟
- ✅ أكثر استقراراً (uptime 99.9%)
- ✅ موارد أقل (RAM/CPU)
- ✅ إدارة أفضل مع systemd
- ✅ سهولة التحديث والصيانة
- ✅ أمان أعلى

### التثبيت على Linux
```bash
1. ارفع المشروع إلى VPS
2. شغل install.sh
3. عدل التوكن في systemd service
4. ابدأ الخدمات
```

### إدارة البروكسي على Linux
```bash
# استخدام الأمر المباشر
m3sb-proxy start 8882 NECK_ANTENNA
m3sb-proxy stop 8882
m3sb-proxy status

# أو عبر البوت
Proxy Control -> حدد البوابة
```

## 🪟 Windows (الطريقة القديمة)

### لماذا Windows؟
- ⚠️ أقل استقراراً
- ⚠️ يحتاج موارد أكثر
- ⚠️ BAT files فقط

### التشغيل على Windows
```bash
1. شغل start_all.bat
2. أو شغل كل BAT منفصل
3. البوت يعمل بنفس الطريقة
```

### إدارة البروكسي على Windows
```bash
# استخدام manage_proxy.bat
manage_proxy.bat

# أو عبر البوت
Proxy Control -> حدد البوابة
```

## 🔄 كيف يعمل النظام عبر المنصتين؟

### 1. **قاعدة البيانات (SQLite)**
```sql
- نفس الملف m3sb.db يعمل على Linux و Windows
- لا يحتاج تثبيت خارجي
- سهل النسخ الاحتياطي
```

### 2. **البوت (Telegram Bot)**
```python
- نفس الكود يعمل على كلا المنصتين
- يكتشف النظام تلقائياً (win/linux)
- ي adjusts الوظائف حسب النظام
```

### 3. **البروكسي (MITM Proxy)**
```python
# على Linux: يستخدم systemd services
# على Windows: يستخدم BAT files

# لكن نفس الكود m3sb_proxy.py يعمل على كلا المنصتين
```

### 4. **إدارة البوابات**
```python
# على Linux:
# - manage_proxy.sh يتحكم في systemd services
# - استخدم: m3sb-proxy start/stop/restart

# على Windows:
# - manage_proxy.bat يتحكم في العمليات
# - استخدم: manage_proxy.bat من القائمة
```

## 📁 هيكل المشروع

```
proxy_project_v2/
├── scripts/
│   ├── m3sb_bot.py              # ← نفس الكود لكلا المنصتين
│   ├── m3sb_proxy.py            # ← نفس الكود لكلا المنصتين
│   ├── m3sb_api_server.py       # ← نفس الكود لكلا المنصتين
│   │
│   ├── Linux files:
│   ├── install.sh               # 📦 مثبت Linux
│   ├── manage_proxy.sh          # 🔧 مدير Linux
│   ├── start_proxy.sh           # ▶️ بدء Linux
│   ├── create_proxy_service.sh  # ⚙️ systemd service
│   │
│   └── Windows files:
│   ├── start_proxy_1010.bat     # ▶️ بدء Windows
│   ├── start_proxy_8881.bat
│   ├── start_proxy_8882.bat
│   ├── start_proxy_8883.bat
│   ├── start_all.bat            # 🚀 بدء الكل
│   ├── manage_proxy.bat         # 🔧 مدير Windows
│   └── *.bat files
│
├── data/                        # 📂 مشتركة
│   ├── m3sb.db                  # قاعدة البيانات
│   ├── NECK_ANTENNA/
│   └── ...
│
└── logs/                        # 📂 مشتركة
    └── *.log
```

## 🔀 How Bot Works Cross-Platform

```python
# في m3sb_bot.py

# 1. عند بدء البوت
def main():
    platform = sys.platform  # win32 or linux
    
    if platform.startswith("win"):
        # استخدام BAT files
        proxy_action() -> يستخدم start_proxy_XXXX.bat
    else:
        # استخدام manage_proxy.sh
        proxy_action() -> يستخدم bash manage_proxy.sh
```

## 🎮 الاستخدام اليومي

### على Linux:
```bash
# 1. إضافة بوابة جديدة
m3sb-proxy start 9999 CUSTOM_FEATURE

# 2. التحقق من الحالة
m3sb-proxy status

# 3. البوت يتكفل بالباقي
# - إنشاء الكيوز
# - تفعيل الـ IPs
# - رفع الملفات
```

### على Windows:
```bash
# 1. إضافة بوابة جديدة
# - shitfile batch script مسبقاً
# - أو عبر البوت

# 2. التحقق من الحالة
# - manage_proxy.bat

# 3. البوت يتكفل بالباقي
# - نفس الشيء
```

## 🔧 التبديل بين المنصات

### للتحويل من Windows إلى Linux:
```bash
1. انقل ملفات المشروع
2. شغل install.sh على Linux
3. نسخ قاعدة البيانات m3sb.db
4. استمر في العمل بدون تغيير الإعدادات
```

### الميزة:
- **نفس التوكنات** تAME تعمل
- **نفس الكيوز** تعمل
- **نفس الـ IPs** تعمل
- **لا تحتاج إعادة تفعيل أي شيء**

## 📊 المقارنة

| الميزة | Linux | Windows |
|--------|-------|---------|
| الاستقرار | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| الأداء | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| سهولة الإدارة | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| الأمان | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| المواصفات | ⭐⭐⭐⭐⭐ | ⭐⭐ |

## 🚀 التوصية

**استخدم Linux VPS إذا:**
- ✓ تريد استقرار عالي
- ✓ تريد أداء أفضل
- ✓ تريد إدارة أسهل
- ✓ تريد تحديثات تلقائية
- ✓ تwant تشغيل 24/7

**استخدم Windows إذا:**
- ⚠️ لديك VPS Windows فقط
- ⚠️ تريد تجربة سريعة
- ⚠️ لا تريد استخدام Linux

## 📞 الدعم

إذا كنت تريد:
- **تثبيت على Linux** - استخدم install.sh
- **ترقية من Windows** - انقل الملفات وشغل install.sh
- **الاستمرار على Windows** - استخدم BAT files

---

**الخلاصة:** النظام يعمل بنفس الطريقة على كلا المنصتين، لكن Linux هو الخيار الأمثل للاستخدام الاحترافي.

**Made with ❤️ by M3SB IOS | @m3sbffxx**