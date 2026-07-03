# M3SB Bot Messages - جميع رسائل البوت

## 📋 محتويات هذا الملف
هذا الملف يحتوي على جميع الرسائل التي يرسلها البوت للمستخدمين، معتربة بشكل منظم.

---

## 🎯 رسائل الترحيب

### **رسالة البداية للجميع (غير المسجلين):**
```python
"👋 *Welcome to M3SB Proxy*\n━━━━━━━━━━━━━━━━━━━━\nSend your key to activate access.\n_Example:_ `M3SB-IOS-XXXXX-XXXXX-XXXXX`"
```

### **رسالة ترحيب للowners:**
```python
"👑 *M3SB Proxy Manager*\n━━━━━━━━━━━━━━━━━━━━\nWelcome, Owner! Choose an option:"
```

### **رسالة ترحيب للresellers:**
```python
"🤝 *Reseller Panel — M3SB*\n━━━━━━━━━━━━━━━━━━━━\nWelcome! Your access expires: `{fmt_ts(rs['expires_at'])}`\nChoose an option:"
```

---

## 🔐 رسائل المفاتيح (Keys)

### **1. إنشاء مفتاح جديد:**
```python
# عند الضغط على "Generate Key"
"🔑 *Generate New Key*\n━━━━━━━━━━━━\nSelect duration:"

# بعد اختيار المدة
"✅ *Key Created*\n━━━━━━━━━━━━━━━━\n🔑  `{code}`\n⏱  Duration : {duration_label(secs)}\n📌  Status   : Unused\n\n_Share this key with the user._"
```

### **2. التحقق من المفتاح:**
```python
# عند إرسال مفتاح غير مسجل
"❌ *Invalid Key*\nThis key does not exist.\n_Contact @m3sbffxx to get a key._"

# عند إرسال مفتاح محظور
"🚫 *Key Banned*\n_Contact @m3sbffxx for support._"

# عند إرسال مفتاح مستخدم من شخص آخر
"🔒 *Key Already Used*\n_This key belongs to another user._"

# عند إرسال مفتاح منتهي
"⏳ *Subscription Expired*\n_Contact the seller to renew._"

# عند إرسال مفتاح صالح unused
"✅ *Key Verified!*\n━━━━━━━━━━━━━━━━\n🔑  Key      : `{row['key_code']}`\n⏱  Duration : {duration_label(row['duration_sec'])}\n\n📡 Now send your *IP address* to activate:"
```

### **3. تحديث IP (عند إعادة تفعيل):**
```python
"🔄 *Update IP*\n━━━━━━━━━━━━━━━━\n🌐  Current IP : `{ip_row['ip']}`\n📅  Expires    : {fmt_ts(ip_row['expires_at'])}\n\n📡 Send your new *IP address*:"
```

### **4. تفعيل ناجح:**
```python
"🎉 *Access Activated!*\n━━━━━━━━━━━━━━━━\n🌐  Your IP  : `{ip}`\n⏱  Duration : {duration_label(dur_sec)}\n📅  Expires  : {fmt_ts(expires_at)}\n\n_Connect to the proxy and enjoy!_\n👑 M3SB Proxy | @m3sbffxx"
```

### **رسائل مفاتيح إضافية:**
```python
# Bulk generate
"📦 *Bulk Generate*\n━━━━━━━━━━━━\nHow many keys? (1–100):"

"✅ *Bulk Keys Created*\n━━━━━━━━━━━━━━━━\n🔢  Count    : *{count}*\n⏱  Duration : {duration_label(secs)}\n\n{keys}"

# Reset key
"🔄 *Key Reset*\n━━━━━━━━━━━━━━━━\n🔑  Key     : `{key_code}`\n🌐  Old IP  : `{old_ip or '—'}` removed\n\n_Key is now available for reuse._"

# Check key
"🔍 *Key Details*\n━━━━━━━━━━━━━━━━\n🔑  Key      : `{row['key_code']}`\n📊  Status   : `{row['status']}`\n⏱  Duration : {duration_label(row['duration_sec'])}\n{ip_info}"

# Ban key
"🚫 *Key Banned*\n`{text}`" + (f"\n🌐 IP `{row['used_by_ip']}` was also revoked." if row["used_by_ip"] else "")

# Delete key
"🗑 *Key Deleted*\n`{text}`" + (f"\n🌐 IP `{row['used_by_ip']}` was also revoked." if row["used_by_ip"] else "")
```

---

## 🌐 رسائل IPs

### **1. قائمة IPs النشطة:**
```python
"🌐 *Active IPs*\n━━━━━━━━━━━━━━━━\n\n{lines}"
```
حيث每条 IP:
```
🟢  `{ip}`
     Expires: {timestamp}
     Key: `{key_used or '—'}`
```

### **2. إلغاء IP:**
```python
# عند طلب إلغاء IP
"❌ *Revoke IP*\n━━━━━━━━━━━━\nSend the IP to revoke:"

# بعد الإلغاء
"❌ *IP Revoked*\n`{text}`"

# IP غير موجود
"⚠️ IP `{text}` not found."
```

### **3. تحديث IP:**
```python
"✅ *IP Updated*\n━━━━━━━━━━━━━━━━\n🌐  New IP  : `{ip}`\n📅  Expires : {fmt_ts(expires_at)}"

# IP نشط بالفعل
"⚠️ IP `{ip}` is already active.\nExpires: {fmt_ts(existing['expires_at'])}"
```

---

## 👥 رسائل Resellers

### **إضافة Reseller:**
```python
# طلب معرف التلقرام
"👥 *Add Reseller*\n━━━━━━━━━━━━━━━━\n📌 Send the person's *Telegram ID*\n_Example:_ `123456789`"

# بعد الاختيار
"✅ *Reseller Added*\n━━━━━━━━━━━━━━━━━━━━\n🆔 ID       : `{rs_id}`\n📅 Duration : {duration_label(secs)}\n⏰ Expires  : `{fmt_ts(expires_at)}`\n{notify_status}"

# إشعار للـ Reseller الجديد
"🎉 *You are now a Reseller on M3SB Proxy*\n━━━━━━━━━━━━━━━━━━━━\n✅ Account activated as reseller\n📅 Duration : {duration_label(secs)}\n⏰ Expires  : `{fmt_ts(expires_at)}`\n\nYou can now:\n• Generate keys and share them with users\n• Manage your own keys only\n\nType /start to begin 🚀"
```

### **إزالة Reseller:**
```python
"🚫 *Remove Reseller*\n━━━━━━━━━━━━\nSend the reseller's *Telegram ID*:"

"🚫 *Reseller Removed*\nID: `{text}`"

"⚠️ ID `{text}` not found in resellers list."
```

### **قائمة Resellers:**
```python
"👥 *Resellers*\n━━━━━━━━━━━━━━━━\n\n{lines}"
```

---

## 🖥 رسائل التحكم في البروكسي

### **الواجهة الرئيسية:**
```python
"🖥 *Proxy Control*\n━━━━━━━━━━━━━━━━\n{maint_text}\n\nSelect a port:"
```

### **رسالة Maintenance:**
```python
# عند تفعيل maintenance
"🔧 *Maintenance Mode*\n━━━━━━━━━━━━\nAll users will see maintenance message."

# في القائمة
"🔧 Maintenance: *ON* — all users see maintenance message"
"🔧 Maintenance: *OFF*"
```

### **حالة Port:**
```python
"🖥 *Port {port}*\n━━━━━━━━━━━━━━━━\n📁 Feature : `{info['feature']}`\n{emoji} Status  : `{proxy_status(port)}`"
```

### **التحكم بالبروكسي:**
```python
# Start
"▶️ Port {port}: {'Started ✅' if ok else 'Failed ❌'}\nStatus: `{proxy_status(port)}`"

# Stop
"⏹ Port {port}: {'Stopped ✅' if ok else 'Failed ❌'}\nStatus: `{proxy_status(port)}`"

# Restart
"🔄 Port {port}: {'Restarted ✅' if ok else 'Failed ❌'}\nStatus: `{proxy_status(port)}`"

# Status details
"📊 *Port {port} Status*\n━━━━━━━━━━━━━━━━\n📁 Feature : `{info['feature']}`\n{emoji} Status  : `{proxy_status(port)}`\n📄 Files   : `{', '.join(files) if files else 'empty'}`"
```

### **تغيير الملفات:**
```python
# Change Hex
"📝 *Change Hex — Port {port}*\n━━━━━━━━━━━━\nSend the new hex file (`.txt`):"

"✅ *Hex Updated — Port {port}*\n━━━━━━━━━━━━━━━━\n📁 Feature : `{feature}`\n📄 File    : `{fname}` ({len(raw_data)} bytes)\n🔄 Proxy restarted"

# Change Fileinfo
"📋 *Change Fileinfo — Port {port}*\n━━━━━━━━━━━━\nSend the new fileinfo file (`.txt`):"

"✅ *Fileinfo Updated — Port {port}*\n━━━━━━━━━━━━━━━━\n📁 Feature : `{feature}`\n📄 File    : `{fname}` ({len(raw_data)} bytes)\n🔄 Proxy restarted"
```

---

## 📊 رسائل الإحصائيات

### **إحصائيات عامة (للowner):**
```python
"📊 *Statistics*\n━━━━━━━━━━━━━━━━\n\n👤 *Bot Users*\n     Total    : `{v_total}`\n     Monthly  : `{v_30d}`\n     Weekly   : `{v_7d}`\n     Today    : `{v_today}`\n\n🔑 *Keys*\n     Total    : `{total_keys}`\n     Unused   : `{unused_keys}`\n     Used     : `{used_keys}`\n     Banned   : `{banned_keys}`\n     Expired  : `{expired_keys}`\n\n📈 *Keys Created*\n     7 Days   : `{keys_7d}`\n     30 Days  : `{keys_30d}`\n\n🌐  Active IPs : `{active_ips}`\n👥  Resellers  : `{active_rs}/{total_rs}`\n\n📡 *Proxy Requests*\n     24h      : `{reqs_24h}`\n     7 Days   : `{reqs_7d}`\n     30 Days  : `{reqs_30d}`\n     Total    : `{reqs_total}`"
```

### **إحصائيات الـ Reseller:**
```python
"📊 *My Stats*\n━━━━━━━━━━━━━━━━\n⏰  Expires    : `{fmt_ts(rs['expires_at'])}`\n🔑  Total Keys : `{total}`\n✅  Unused     : `{unused}`\n🔒  Used       : `{used}`\n🚫  Banned     : `{banned}`"
```

---

## 🔐 رسائل API Keys

### **إنشاء API Key:**
```python
"🔐 *API Key Generated*\n━━━━━━━━━━━━━━━━\n🔑  `{key}`\n\n_Use this key in the `X-API-Key` header._\n_Base URL:_ `https://m3sbios.com/api/v1`"
```

### **قائمة API Keys:**
```python
"🔐 *API Keys*\n━━━━━━━━━━━━━━━━\n\n{lines}"
```

---

## 📁 رسائل Convert File

### **تحويل ملف:**
```python
"📁 *Convert File to Hex*\n━━━━━━━━━━━━━━━━\nSelect the file type:"

"📁 *Convert to {file_type}*\n━━━━━━━━━━━━\nSend the binary file to convert:"

"✅ *{file_type} Converted*\n━━━━━━━━━━━━━━━━\n📦 Compressed : `{comp_size}` bytes\n📄 Original   : `{uncomp_size}` bytes\n🔒 SHA1 (gz)  : `{comp_sha1}`"

"📋 *Fileinfo* (matching hex above)"
```

---

## 🚨 رسائل الخطأ

### **أخطاء عامة:**
```python
"⚠️ Usage: `/reset M3SB-IOS-XXXXX-XXXXX-XXXXX`"
"⚠️ Send a valid numeric ID.\n_Example:_ `123456789`"
"⚠️ Enter a number between 1 and 100."
"⚠️ Send a valid number (1–100)."
"⚠️ Key is `{status}`, nothing to reset."
"⚠️ Unknown port."
"⚠️ IP `{ip}` is already active.\nExpires: {fmt_ts(existing['expires_at'])}"
"⛔ Owner only."
"⛔ Access denied."
"⛔ You can only reset keys you created."
"⛔ You can only ban keys you created."
"⛔ You can only delete keys you created."
"⏳ *Rate Limit*\n━━━━━━━━━━━━\nToo many keys created. Wait 1 minute."
```

---

## 🎮 رسائل الـ Proxy Injection (عند الاعتراض)

### **عند نجاح الـ Injection:**
```python
# في m3sb_proxy.py
MSG_SUCCESS = (
    "[00FF00]⚡ Successfully Injected!\n"
    "[FFFFFF]Please turn OFF proxy to login.\n"
    "[00FFFF]👑 M3SB IOS | @m3sbffxx"
)
```

### **رسائل الخطأ للـ IP:**
```python
# IP غير مسجل
msg_not_registered(ip) = (
    f"[FF0000]🚫 Not Registered!\n"
    f"[FFFFFF]Your IP is not in the system.\n"
    f"[FFFF00]Your IP : {ip}\n"
    f"[00FFFF]Get access: contact @m3sbffxx"
)

# IP منتهي
msg_expired(ip) = (
    f"[FF9900]⏳ Subscription Expired!\n"
    f"[FFFFFF]Your access has ended.\n"
    f"[FFFF00]Your IP : {ip}\n"
    f"[00FFFF]Renew: contact @m3sbffxx"
)

# IP محظور
msg_banned(ip) = (
    f"[FF0000]🚫 You Are Banned!\n"
    f"[FFFFFF]Your IP has been banned.\n"
    f"[FFFF00]Your IP : {ip}\n"
    f"[00FFFF]Contact: the seller"
)

# وضع الصيانة
msg_maintenance(ip) = (
    f"[FFFF00]🔧 Proxy Under Maintenance!\n"
    f"[FFFFFF]The proxy is currently under maintenance.\n"
    f"[FFFF00]Your IP : {ip}\n"
    f"[00FFFF]Please try again later."
)
```

---

## 📱 رسائل القوائم (Keyboards)

### **القائمة الرئيسية للـ Owner:**
```
🔑 Generate Key
📋 All Keys
🌐 Active IPs
❌ Revoke IP
🚫 Ban Key
🗑 Delete Key
👥 Add Reseller
📜 Reseller List
🚫 Remove Reseller
📊 Statistics
📦 Bulk Generate
🔐 API Keys
🖥 Proxy Control
📁 Convert File
```

### **قائمة الـ Reseller:**
```
🔑 Generate Key
📋 My Keys
🚫 Ban Key
🗑 Delete Key
📊 My Stats
```

### **أزرار المدة (Duration):**
```
⏱ 1 Day
📅 3 Days
🗓 7 Days
🗓 14 Days
🗓 30 Days
🗓 60 Days
🗓 90 Days
```

### **أزرار التحكم بالبروكسي:**
```
🔧 Maintenance: ON/OFF
🟢 Port 1010
🔴 Port 8881
🟢 Port 8882
🔴 Port 8883
🔙 Back
```

---

## 🔔 إشعارات النظام (Logs)

### **في البوت (bot.log):**
```
Key created: {code} dur={secs}s by {uid}
Key banned: {text} by {uid}
Key deleted: {text} by {uid}
IP activated: {ip} key={key_code} user={uid}
IP updated: {old_ip} -> {ip} key={key_code} user={uid}
Reseller added: {rs_id} dur={secs}s by owner {uid}
Maintenance mode ENABLED
Maintenance mode DISABLED
M3SB Bot v5 started
```

### **في البروكسي (proxy_*.log):**
```
[INFO] [M3SB IOS] Proxy loaded — Feature: {FEATURE}
[INFO] [M3SB IOS] TLS MITM only for: {MITM_DOMAINS}
[INFO] [M3SB IOS] Loaded cache_res (hex): {size} bytes
[INFO] [M3SB IOS] Ready: {list(FILE_CACHE.keys())}
[INFO] INJECTED ip={ip}
[INFO] BANNED ip={ip}
[INFO] EXPIRED ip={ip}
[INFO] NOT_REGISTERED ip={ip}
[WARNING] BLOCKED file intercept ip={ip} status={status} file={p}
```

---

## 🎨 ملاحظات على التصميم

### **الألوان المستخدمة:**
```
[00FF00] - أخضر (نجاح)
[FF0000] - أحمر (خطأ/حظر)
[FF9900] - برتقالي (تنبيه)
[FFFF00] - أصفر (تحذير)
[00FFFF] - سماوي (معلومات)
[FFFFFF] - أبيض (نص عادي)
```

### **الرموز التعبيرية:**
```
👑 - ملك/مالك
🤝 - وكيل/Reseller
👋 - ترحيب
✅ - نجاح
❌ - خطأ
🚫 - حظر
🔒 - مغلق/مستخدم
⏳ - منتهي الصلاحية
🔧 - صيانة
📊 - إحصائيات
🌐 - IP/.networking
🔑 - مفتاح
📋 - قائمة
👥 - مستخدمين
🖥 - شاشة/تحكم
📁 - ملف
📦 - حزمة
📅 - تقويم
⏱ - ساعة
🗑 - سلة مهملات
```

---

## 📝 ملاحظات للمطورين

### **كيفية تعديل الرسائل:**

```python
# 1. ابحث عن الرسالة في m3sb_bot.py
# 2. عدل النص كما تريد
# 3. احفظ الملف
# 4. أعد تشغيل البوت

# مثال:
await update.message.reply_text(
    "رسالة جديدة هنا", 
    parse_mode="Markdown"
)
```

### **إضافة رسالة جديدة:**

```python
# 1. عرف المتغير إذا كنت تريد استخدامه في أماكن متعددة
NEW_MESSAGE = (
    "✅ *Success!*\n"
    "Your action completed.\n"
    "👑 M3SB Proxy"
)

# 2. استخدمها في الـ handler
await update.message.reply_text(NEW_MESSAGE, parse_mode="Markdown")
```

### **Markdown Formatting:**
```python
# استخدم这些 لتنسيق النص:
*bold*                # نص عريض
_italic_              # نص مائل
`code`                # كود
```code```            # كود بلوك
```python
# قائمة
- item1
- item2
```

---

**ملاحظة:** هذه الرسائل ثابتة في الكود. لتعديلها، ابحث عن النص في `m3sb_bot.py`.

**Made with ❤️ by M3SB IOS | @m3sbffxx**