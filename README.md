# Lawyers.bh - منصة محامين البحرين

تطبيق Flutter احترافي لمنصة محامين البحرين، مبني بأحدث التقنيات وأفضل الممارسات ليكون جاهزاً للإنتاج.

## 🏗️ البنية المعمارية

```
lib/
├── core/                    # طبقة النواة المشتركة
│   ├── constants/          # الثوابت والإعدادات
│   ├── theme/              # نظام التصميم والألوان
│   ├── router/             # التوجيه والملاحة (GoRouter)
│   ├── network/            # طبقة الشبكة (Dio + Interceptors)
│   ├── storage/            # التخزين الآمن والمحلي
│   ├── localization/       # الترجمة والتعريب
│   ├── di/                 # حقن التبعيات (GetIt)
│   ├── errors/             # إدارة الأخطاء
│   └── utils/              # أدوات مساعدة
├── data/                    # طبقة البيانات
│   ├── models/             # نماذج البيانات (Freezed)
│   ├── repositories/       # تنفيذ المستودعات
│   └── datasources/        # مصادر البيانات (Remote/Local)
├── domain/                  # طبقة النطاق (Clean Architecture)
│   ├── entities/           # الكيانات الأساسية
│   ├── repositories/       # عقود المستودعات
│   └── usecases/           # حالات الاستخدام
└── presentation/           # طبقة العرض
    ├── providers/          # إدارة الحالة (Riverpod)
    ├── screens/            # الشاشات
    ├── common/             # المكونات المشتركة
    └── state/              # حالات UI
```

## 🛠️ التقنيات المستخدمة

| الطبقة | التقنية |
|----------|---------|
| **State Management** | Riverpod 2.x |
| **Routing** | GoRouter |
| **Network** | Dio + PrettyDioLogger |
| **Local Storage** | SharedPreferences + FlutterSecureStorage |
| **DI** | GetIt |
| **Serialization** | Freezed + JSON Serializable |
| **Testing** | Mocktail + Flutter Test |
| **CI/CD** | Codemagic |
| **Fonts** | Cairo + Tajawal (Google Fonts) |

## 🎨 نظام التصميم

### الألوان الأساسية
- **Navy (أساسي)**: `#0F1E36`
- **Gold (ثانوي)**: `#C59B27`
- **Crimson (تحذير/طارئ)**: `#861F41`
- **Green (نجاح)**: `#1E7E34`
- **Red (خطأ)**: `#A62A2A`

### الخطوط
- **العناوين**: Cairo (Bold, ExtraBold)
- **النصوص**: Tajawal (Regular, Medium, Bold)

### RTL Support
التطبيق يدعم RTL بشكل كامل مع اللغة العربية كلغة افتراضية.

## 🚀 البدء السريع

### المتطلبات
- Flutter 3.19+
- Dart 3.3+
- Android Studio / Xcode
- CocoaPods (لـ iOS)

### التثبيت

```bash
# استنساخ المشروع
git clone https://github.com/your-org/lawyers_bh.git
cd lawyers_bh

# تثبيت التبعيات
flutter pub get

# توليد الكود (Freezed, JSON Serializable, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# تشغيل التطبيق
flutter run --flavor development
```

### متغيرات البيئة

انسخ `.env.example` إلى `.env` وأضف القيم:

```bash
cp .env.example .env
# أو للبيئات المختلفة
cp .env.development .env    # للتطوير
cp .env.staging .env        # للمرحلة
# الإنتاج يتم عبر CI/CD secrets
```

## 📱 Flavors (بيئات البناء)

| Flavor | Android Package | iOS Bundle ID | الاستخدام |
|--------|----------------|---------------|-----------|
| `development` | `com.lawyersbh.app.dev` | `com.lawyersbh.app.dev` | التطوير المحلي |
| `staging` | `com.lawyersbh.app.staging` | `com.lawyersbh.app.staging` | اختبار QA |
| `production` | `com.lawyersbh.app` | `com.lawyersbh.app` | الإنتاج |

### أوامر البناء

```bash
# Android
flutter build apk --flavor development
flutter build appbundle --flavor staging
flutter build appbundle --flavor production

# iOS
flutter build ios --flavor development --no-codesign
flutter build ios --flavor staging --no-codesign
flutter build ios --flavor production --no-codesign
```

## 🔐 الأمان

- **FlutterSecureStorage** للرموز الحساسة
- **Certificate Pinning** للشبكة
- **ProGuard/R8** لإخفاء الكود (Android)
- **App Transport Security** (iOS)
- **Biometric Authentication** اختياري
- لا توجد أسرار في الكود أو Git

## 🧪 الاختبارات

```bash
# تشغيل جميع الاختبارات
flutter test

# اختبارات الوحدة فقط
flutter test test/unit

# اختبارات الويدجت
flutter test test/widget

# مع التغطية
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📦 CI/CD مع Codemagic

الملف `codemagic.yaml` معرف ب workflows التالية:

| Workflow | الوصف |
|----------|---------|
| `android-debug` | بناء APK للتطوير |
| `android-staging` | AAB للمرحلة + رفع لـ Play Console Internal |
| `android-production` | AAB للإنتاج + رفع لـ Play Console Production |
| `ios-debug` | بناء iOS للتطوير |
| `ios-staging` | IPA للمرحلة + رفع لـ TestFlight |
| `ios-production` | IPA للإنتاج + رفع لـ TestFlight |
| `full-test` | تشغيل جميع الاختبارات + تحليل الكود |
| `pr-validation` | تحقق تلقائي للـ Pull Requests |

### متغيرات Codemagic المطلوبة

في واجهة Codemagic، أضف المتغيرات التالية كـ **Secret Variables**:

```
GCLOUD_SERVICE_ACCOUNT_KEY      # JSON service account لـ Google Play
APP_STORE_CONNECT_API_KEY       # مفتاح App Store Connect API
APP_STORE_CONNECT_API_KEY_ID    # معرف المفتاح
APP_STORE_CONNECT_ISSUER_ID     # معرف المصدر
KEYSTORE_PASSWORD               # كلمة مرور Keystore
KEY_PASSWORD                    # كلمة مرور المفتاح
CM_KEYSTORE                     # Keystore مشفر بـ Base64
CM_PROVISIONING_PROFILE         # Provisioning Profile مشفر
CM_CERTIFICATE                  # شهادة التوزيع مشفرة
CM_CERTIFICATE_PASSWORD         # كلمة مرور الشهادة
```

## 📁 هيكل الشاشات

### العميل (Client)
- **Splash/Onboarding** - الترحيب والتسجيل
- **Auth** - تسجيل دخول، إنشاء حساب، نسيان كلمة المرور، OTP
- **Home** - الرئيسية مع البحث السريع والمحامون المقترحون
- **Lawyers Directory** - دليل المحامين مع التصفية
- **Lawyer Profile** - ملف المحامي وحجز الاستشارة
- **Services** - الخدمات القانونية المتاحة
- **Appointments** - المواعيد (قادمة، سابقة، ملغية)
- **Messages** - المحادثات
- **Favorites** - المحامون المحفوظون
- **Profile/Settings** - الملف الشخصي والإعدادات

### المحامي (Lawyer)
- **Dashboard** - شاشة القيادة (قضايا، عروض، حاسبة أتعاب)
- **Contracts/Files** - العقود والملفات
- **Notifications** - التنبيهات والمواعيد

### الإدارة (Admin)
- **KPIs** - مؤشرات الأداء الاستراتيجية
- **Dispute Resolution** - فض النزاعات
- **Management Structure** - الهيكل الإداري

## 📋 قائمة التحقق للإنتاج (Production Checklist)

- [ ] تحديث `version` في `pubspec.yaml`
- [ ] تعيين `flutterVersionCode` و `flutterVersionName` في `local.properties`
- [ ] إنشاء Keystore للتوقيع (Android)
- [ ] إنشاء شهادات توزيع (iOS)
- [ ] تعيين متغيرات البيئة في Codemagic
- [ ] اختبار البناء على أجهزة حقيقية
- [ ] مراجعة الأذونات في `AndroidManifest.xml` و `Info.plist`
- [ ] تفعيل App Check و Firebase
- [ ] إعداد Crashlytics و Analytics
- [ ] مراجعة سياسة الخصوصية والشروط
- [ ] اختبار عمليات الدفع (BenefitPay, Apple Pay)
- [ ] اختبار الإشعارات الفورية
- [ ] اختبار البيومترية
- [ ] اختبار RTL الكامل

## 📄 الترخيص

مشروع خاص - جميع الحقوق محفوظة لشركة محامون البحرين للتقنية القانونية.

## 🤝 المساهمة

1. Fork المشروع
2. إنشاء فرع للميزة (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push للفرع (`git push origin feature/amazing-feature`)
4. فتح Pull Request

## 📞 التواصل

- **البريد الإلكتروني**: dev@lawyers.bh
- **الموقع**: https://lawyers.bh
- **الدعم الفني**: support@lawyers.bh