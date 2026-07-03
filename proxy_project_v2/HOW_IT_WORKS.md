# كيف يعمل M3SB Proxy - الشرح الكامل

## 🎯 المطلوب منك فهمه

```
┌─────────────────────────────────────────────────────────────┐
│  1. اللاعب (Client)                                         │
│  2. البروكسي (Proxy) ← على VPS Linux                     │
│  3. SSH Tunnel                                                │
│  4. الشهادة (Certificate)                                    │
│  5. اللعبة (Game Server)                                     │
└─────────────────────────────────────────────────────────────┘
```

## 📡 السلسلة الكاملة (Chain)

```
┌──────────┐      ┌──────────┐      ┌──────────┐
│  Player  │─────▶│   SSH    │─────▶│  VPS     │
│  (Phone) │  ↓   │  Tunnel  │  ↓   │  Linux   │
└──────────┘  ↓   └──────────┘  ↓   └────┬─────┘
              ↓                         ↓
         Port 8882/22                mitmdump
              ↓                    Port 8882
              ↓                         ↓
              └─────────────────────────┘
                                    │
                                    ▼
                              Free Fire
                              Game Server
```

## 🔍 كيف يعمل كل جزء؟

### **1. SSH Tunnel (الأنفاق)**

```
Player على port 22 يفتح اتصال SSH مع VPS

يقول: "أريد أن أرسل كل شيء من port 8882 
       على جهازي إلى port 8882 على السيرفر"

النتيجة:
- Player يستخدم 127.0.0.1:8882 محلياً
- VPS يسمع على ::
- البيانات تمر عبر SSH مشفرة
```

### **2. البروكسي (mitmdump)**

```
يستمع على port 8882
عندما يأتي طلب:

1. يقرأ HTTPS request
2. يفحص إذا كان IP مسموح (من قاعدة البيانات)
3. إذا مسموح:
   - يعدل الملفات (cache_res, assetindexer, fileinfo)
   - يرسل الملفات المخصصة للاعب
4. إذا غير مسموح:
   - يرفض الطلب
```

### **3. الشهادة (MITM Certificate)**

```
بدون شهادة:
┌─────────┐      ┌──────────┐      ┌─────────┐
│  Device │─────▶│ Internet │─────▶│  Game   │
│         │      │ (HTTPS)  │      │ Server  │
└─────────┘      └──────────┘      └─────────┘
     ↑                 ↑
     │                 │
  Game sees          Server sees
  Encrypted data    Encrypted data
  (can't read)      (can't read)
  
مشكلة: البروكسي لا يستطيع قراءة البيانات!

─────────────────────────────────────────────────────────────

مع الشهادة:
┌─────────┐      ┌──────────┐      ┌─────────┐
│  Device │─────▶│  Proxy   │─────▶│  Game   │
│         │      │ mitmdump │      │ Server  │
└─────────┘      └────┬─────┘      └─────────┘
     ↑                  ↑
     │                  │
  Sees fake           Sees real
  certificate         certificate
  (app trusts)        (signed by CA)
  
الحل:
1. Device ثبت الشهادة M3SB CA
2. عند فتح HTTPS connection:
   - Device تقبل الشهادة المزورة
   - Traffic يمر عبر Proxy
   - Proxy يقرأ ويعدل
   - يعيد للـ Game Server
```

## 🔄 العملية الكاملة خطوة بخطوة

```
1. اللاعب يشغل:
   
   ssh -L 8882:127.0.0.1:8882 root@vps-ip -N
   
   ├── يفتح اتصال SSH مع VPS
   ├── يوجه port 8882 محلياً إلى 127.0.0.1:8882 على VPS
   └── يبقى متصلاً (-N = لا تشغيل shell)

2. اللاعب يفتح اللعبة:
   
   Proxy: 127.0.0.1
   Port: 8882
   
   ├── اللعبة ترسل HTTPS request إلى 127.0.0.1:8882
   ├── SSH Tunnel يرسله إلى VPS:8882
   └── mitmdump يستقبله

3. mitmdump يعالج الطلب:
   
   ├── يقرأ ال headers
   ├── يفحص URL
   │   ├── إذا كان cache_res/fileinfo/assetindexer:
   │   │   ├── يلجأ لقاعدة البيانات
   │   │   ├── يتحقق من IP
   │   │   └── يعيد ملف مخصص بدلاً من الأصلي
   │   └── إذا كان majorlogin:
   │       ├── يتحقق من IP
   │       └── يعدل الـ response
   │
   └── بالنسبة لبقية الطلبات:
       └── يمررها كما هي (tunnel mode)

4. الرد يتبع المسار العكسي:
   
   mitmdump ←──── SSH Tunnel ←──── Game Server
   (عدل)                      (الرد الأصلي)
        ↓
   Device receives modified response
```

## 🗄️ قاعدة البيانات - كيف يتعرف النظام على اللاعب؟

```sql
-- عند شراء مفتاح و تفعيله:

-- 1. البوت ينشئ مفتاح
INSERT INTO license_keys (key_code, status) 
VALUES ('M3SB-IOS-XXXXX-XXXXX-XXXXX', 'unused');

-- 2. اللاعب يرسل المفتاح للبوت
-- البوت يتحقق من صحته

-- 3. البوت يطلب IP من اللاعب
-- اللاعب يرسل IP (مثلاً 105.74.64.140)

-- 4. البوت يضيف الـ IP لقاعدة البيانات
INSERT INTO allowed_ips (ip, expires_at, key_used, status)
VALUES ('105.74.64.140', 9999999999, 'M3SB-IOS-...', 'active');

-- 5. الآن mitmdump يعرف أن هذا الـ IP مسموح
```

## 🔐 كيف ت ();
```

## 📊 الأرقام

```
المكونات:
├── 1x VPS Linux (Ubuntu/Debian)
├── 1x Telegram Bot (Python)
├── 1x API Server (Python)
├── 1x mitmdump instance (لكل port)
├── 1x SQLite database
└── 1x Systemd services

المنافذ:
├── 22: SSH
├── 8080: API Server
├── 8881-8883: Proxy ports (أو أي منفذ تريده)
└── 53: DNS (إذا لزم الأمر)

الموارد:
├── RAM: 512MB للبوت + 200MB لكل mitmdump
├── CPU: 1 core كافي
└── Storage: 1GB
```

**Made with ❤️ by M3SB IOS | @m3sbffxx**