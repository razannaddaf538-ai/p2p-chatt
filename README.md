# P2P Chat Application

## 🚀 نظام دردشة نقطة لنقطة (Peer-to-Peer Chat)

تطبيق دردشة متقدم يعتمد على بروتوكول TCP/IP للاتصال المباشر بين الأجهزة دون الحاجة لسيرفر وسيط.

---

## 📋 المميزات الحالية

### النسخة الأولى (Dart Console)
- ✅ فتح منفذ استقبال (Server Socket)
- ✅ الاتصال بـ IP معين وإرسال بيانات نصية
- ✅ العمل على الشبكة المحلية LAN
- ✅ بروتوكول TCP/IP موثوق

### النسخة الثانية (Flutter App) - قيد التطوير
- 🎨 واجهة مستخدم احترافية بـ Flutter
- 💬 شاشة دردشة متقدمة
- 👥 إدارة الأقران المتصلين (Peers)
- 🔐 تسجيل دخول آمن
- 🎯 تصميم Material Design
- 📱 دعم أجهزة متعددة (Android, iOS, Windows, Web, macOS, Linux)

---

## 🛠️ الأدوات المستخدمة

| الأداة | الاستخدام |
|--------|----------|
| **Dart** | لغة البرمجة الأساسية |
| **Flutter** | إطار العمل للواجهات الرسومية |
| **dart:io** | التعامل مع الشبكات والمقابس |
| **TCP/IP** | بروتوكول الاتصال |
| **Material Design** | تصميم واجهة المستخدم |

---

## 📁 هيكل المشروع

```
p2p-chatt/
├── lib/
│   ├── main.dart                 # نقطة الدخول الرئيسية
│   ├── main_screen.dart          # الشاشة الرئيسية
│   ├── chat_screen.dart          # شاشة الدردشة
│   ├── login_screen.dart         # شاشة تسجيل الدخول
│   ├── peers_screen.dart         # شاشة عرض الأقران
│   ├── chat_bubble.dart          # مكون الفقاعات النصية
│   ├── app_theme.dart            # إعدادات الثيم
│   └── app_colors.dart           # ألوان التطبيق
├── android/                      # ملفات بناء Android
├── ios/                          # ملفات بناء iOS
├── windows/                      # ملفات بناء Windows
├── web/                          # ملفات بناء الويب
├── macos/                        # ملفات بناء macOS
├── linux/                        # ملفات بناء Linux
├── pubspec.yaml                  # ملف المشروع والمكتبات
├── analysis_options.yaml         # إعدادات تحليل الكود
├── p2plogic.dart                 # منطق اتصال P2P
├── architecture.txt              # شرح معمارية النظام
└── README.md                     # هذا الملف
```

---

## 🔧 المتطلبات

- **Flutter SDK** ^3.11.5
- **Dart SDK** ^3.11.5
- **Java** (لـ Android)
- **Xcode** (لـ iOS)
- **Visual Studio** (لـ Windows)

---

## 📦 التثبيت والتشغيل

### 1. استنساخ المستودع
```bash
git clone https://github.com/razannaddaf538-ai/p2p-chatt.git
cd p2p-chatt
```

### 2. تثبيت المكتبات
```bash
flutter pub get
```

### 3. التشغيل على الأجهزة المختلفة

#### تشغيل على Android
```bash
flutter run -d android
```

#### تشغيل على iOS
```bash
flutter run -d ios
```

#### تشغيل على Windows
```bash
flutter run -d windows
```

#### تشغيل على الويب
```bash
flutter run -d web
```

#### تشغيل على macOS
```bash
flutter run -d macos
```

#### تشغيل على Linux
```bash
flutter run -d linux
```

---

## 🏗️ معمارية النظام

### بروتوكول الاتصال: TCP/IP
- **Protocol**: TCP (Transmission Control Protocol)
- **Addressing**: IPv4 على الشبكات المحلية LAN
- **Pattern**: Client-Server مع إمكانية Peer-to-Peer

### منطق العمل:
1. كل مستخدم يعمل كـ **Peer Node**
2. فتح **ServerSocket** للاستماع المستمر
3. عند الإرسال، ينشئ **Socket مؤقت** لتسليم البيانات
4. إغلاق الاتصال بعد التسليم الناجح

---

## 🔐 الخطط المستقبلية

- [ ] 🔒 تشفير البيانات (Encryption)
- [ ] 📝 حفظ سجل الرسائل
- [ ] 👥 دعم مجموعات الدردشة
- [ ] 🖼️ نقل الملفات والصور
- [ ] 📞 المكالمات الصوتية
- [ ] 🌐 الاتصال عبر الإنترنت (خارج LAN)
- [ ] 🔔 إشعارات في الوقت الفعلي
- [ ] 🎨 مظهر/ثيمات متعددة

---

## 👨‍💻 المساهمة

نرحب بمساهماتك! يمكنك:
1. Fork المستودع
2. إنشاء فرع جديد (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add some amazing feature'`)
4. Push للفرع (`git push origin feature/amazing-feature`)
5. فتح Pull Request

---

## 📄 الترخيص

هذا المشروع مفتوح المصدر ومتاح للاستخدام التعليمي.

---

## 📧 التواصل

- 👤 المطور: **razannaddaf538-ai**
- 🔗 GitHub: [razannaddaf538-ai](https://github.com/razannaddaf538-ai)

---

## 📚 المراجع والموارد

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Dart Documentation](https://dart.dev/)
- [TCP/IP Protocol](https://en.wikipedia.org/wiki/Internet_protocol_suite)
- [Socket Programming in Dart](https://api.dart.dev/stable/dart-io/Socket-class.html)

---

**آخر تحديث:** يونيو 2026  
**الإصدار الحالي:** 1.0.0
