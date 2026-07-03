# M3SB Proxy System

## 🎯 ما هو هذا المشروع؟

نظام بروكسي كامل للعبة Free Fire يعمل على **Linux VPS** مع:
- 📡 **بوابات ديناميكية** (Dynamic Ports)
- 🤖 **بوت تيليجرام** للتحكم الكامل
- 🔑 **نظام كيوز** (License Keys)
- 👥 **نظام وكلاء** (Resellers)
- 🔐 **شهادة MITM** لاعتراض HTTPS
- 🚀 **SSH Tunneling** للعملاء

## 🚀 تشغيل سريع

### **على Linux VPS (مفضل):**

```bash
# 1. تثبيت
cd /opt/proxy_project_v2/scripts
bash install.sh

# 2. إعداد البوت
nano /etc/systemd/system/m3sb-bot.service
# (عدل YOUR_BOT_TOKEN و YOUR_ADMIN_IDS)

# 3. تشغيل
systemctl daemon-reload
systemctl enable --now m3sb-bot m3sb-api
m3sb-proxy start 8882 NECK_ANTENNA
```

### **على Windows (قديم):**

```bash
# شغل start_all.bat
# أو استخدم manage_proxy.bat
```

## 📁 هيكل المشروع

```
proxy_project_v2/
├── scripts/                    ← الكود واللوقات
│   ├── m3sb_bot.py            ← البوت (نفسه على Linux/Windows)
│   ├── m3sb_proxy.py          ← البروكسي
│   ├── manage_proxy.sh        ← مدير Linux
│   ├── manage_proxy.bat       ← مدير Windows
│   ├── install.sh             ← مثبت Linux
│   └── generate_cert.sh       ← شهادة
├── data/                       ← قاعدة البيانات والملفات
├── logs/                       ← السجلات
└── certs/                      ← الشهادات
```

## 📚 الوثائق

- **README_LINUX.md** - دليل التثبيت الكامل
- **SETUP_GUIDE.md** - إعداد عملي
- **SSH_TUNNEL_GUIDE.md** - شرح tunneling
- **CERTIFICATE_GUIDE.md** - دليل الشهادة
- **CROSS_PLATFORM.md** -跨平台
- **HOW_IT_WORKS.md** - كيف يعمل
- **PATHS_STRUCTURE.md** - المسارات
- **BOT_MESSAGES.md** - رسائل البوت

## 🎮 للمستخدمين (العملاء):

1. **تواصل مع البائع** لشراء مفتاح
2. **افتح البوت** على تيليجرام
3. **أرسل المفتاح** واستلم الـ IP
4. **شغل SSH Tunnel:**
   ```bash
   ssh -L 8882:127.0.0.1:8882 root@vps-ip -N
   ```
5. **في اللعبة:** Proxy 127.0.0.1:8882

## 🔧 للبائع (Owner):

### **إضافة بوابة جديدة:**
```bash
m3sb-proxy start 9999 CUSTOM_FEATURE
```

### **إنشاء مفتاح:**
افتح البوت → Generate Key → اختر المدة

### **تفعيل IP:**
العميل يرسل المفتاح → البوت يطلب IP → تفعيل تلقائي

## 💡 الميزات الرئيسية

✅ **بوابات ديناميكية** - أي عدد من البوابات
✅ **نظام كيوز** - إنشاء/تجديد/حظر
✅ **Resellers** - إدارة وكلاء
✅ **API Server** - تحكم خارجي
✅ **شهادة MITM** - اعتراض HTTPS
✅ **SSH Tunneling** - أمان تام
✅ **سجلات كاملة** - مراقبة كل شيء

## 📊 الموارد المطلوبة

```
VPS: Ubuntu/Debian
RAM: 1GB كافي
CPU: 1 Core
Disk: 1GB
Ports: 22, 8080, 8881-8883
```

## 🛡️ الأمان

- SSH Tunneling = اتصال مشفر
- شهادة CA للاعتراض
- IPs مسجلة فقط
- صيانة دورية

## 📞 الدعم

- Telegram: @m3sbffxx
- Project: M3SB IOS

---

**Made with ❤️ by M3SB IOS | @m3sbffxx**

## 🎯 ملاحظة

هذا المشروع جاهز 100% للاستخدام الإنتاجي على **Linux VPS**.