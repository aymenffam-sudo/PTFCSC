# مجلد /opt - شرح بسيط

## 🤔 السؤال: هل /opt موجود على Windows؟

### **الجواب: لا، /opt موجود فقط على Linux**

```
على Windows:        ممكن توجد /opt (لأنه Bash):
C:\Windows\...      but when using WSL2 أو Git Bash

على Linux:          ✅ موجود ب definitely:
/opt/               ← هذا المجلد سُيُنشأ على VPS
```

## 📋 ما هو /opt؟

### **على Linux:**
```
/opt/               ← "Optional" - مجلد thirds-party software
├── docker/         ← مثلاً Docker
├── google/         ← مثلاً Google Chrome
├── m3sb/          ← مشروعك سيكون هنا!
└── ...
```

## 🚀 ماذا يحدث عندما تشغل install.sh؟

```bash
# install.sh سينشئ /opt تلقائياً:
mkdir -p /opt/m3sb

# لا تحتاج لإنشائه بنفسك!
# السكريبت يعمله لك
```

## ✅ لا تقلق بشأن /opt

### **السيناريو 1: على Windows (localhost):**
```
❌ /opt غير موجود
❌ لا يمكن التشغيل هنا
✅ لكن الملفات جاهزة للرفع
```

### **السيناريو 2: على Linux VPS:**
```bash
# 1. ترفع الملفات
scp -r proxy_project_v2 root@vps:/opt/

# 2. يتواجد /opt تلقائياً على VPS
# (لا تحتاج لإنشائه)

# 3. المجلد النهائي:
/opt/proxy_project_v2/
```

## 💡 كيف يعمل install.sh بدون /opt موجود؟

```bash
# install.sh:
mkdir -p /opt/m3sb        ← ينشئ هرم
mkdir -p /opt/m3sb/data   ← ينشئ البيانات
mkdir -p /opt/m3sb/logs   
mkdir -p /opt/m3sb/certs  

# ثم ينسخ الملفات:
cp -r ./* /opt/m3sb/
```

## 🔄 المسار على VPS فقط

```
/opt/m3sb/               ← الموقع النهائي على VPS
├── (نفس الملفات)
```

**لا يوجد /opt على Windows، وهذا عادي.**
**المشروع مُصمم للعمل على Linux VPS فقط.**

---

**ملاحظة:** إذا كنت تستخدم WSL2 على Windows، `/opt` موجود داخل WSL عند تشغيل `bash install.sh`.

**Made with ❤️ by M3SB IOS | @m3sbffxx**