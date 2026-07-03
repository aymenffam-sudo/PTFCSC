# ⚡ Quick Start - ابدأ هنا!

## 📂 مكان المشروع الحقيقي:

```
الموقع الصحيح: proxy_project_v2/
```
(في الجذر، ليس في PTFCSC)

## 🎯 3 خطوات فقط للتشغيل:

### **الخطوة 1: رفع من Windows**

من **PowerShell** على Windows:
```bash
scp -r proxy_project_v2 root@your-vps-ip:/opt/
```

### **الخطوة 2: تثبيت على VPS**

```bash
ssh root@your-vps-ip
cd /opt/proxy_project_v2/scripts
bash install.sh
```

### **الخطوة 3: تشغيل**

```bash
# إعداد البوت
nano /etc/systemd/system/m3sb-bot.service
# (عدل التوكن)

# تشغيل
systemctl daemon-reload
systemctl enable --now m3sb-bot m3sb-api
m3sb-proxy start 8882 NECK_ANTENNA
```

## ✅ تحقق من العمل:

```bash
systemctl status m3sb-bot
m3sb-proxy status
```

## 📞 للعملاء:

```bash
ssh -L 8882:127.0.0.1:8882 root@vps-ip -N
```

---

**هذا هو المشروع الحقيقي:** `proxy_project_v2/`

**ليس PTFCSC** - هذا مجلد زيادة.