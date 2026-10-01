# محامون البحرين — تطبيق الموبايل (واجهة العميل)

تطبيق Flutter (يشتغل iOS + Android) للجزء الأول من المخطط المعماري: **واجهة العميل**
(تسجيل دخول OTP، بحث ذكي ومطابقة، تعاقد آمن وتوقيع إلكتروني، دفع عبر BenefitPay/Apple Pay
لحساب ضمان، متابعة القضية، وزر SOS).

الشكل والألوان والخطوط منسوخة حرفيًا من ملف `lawyers-bh-mockup.html` المعتمد.

## 1) قبل أول تشغيل

هذا المجلد يحتوي فقط على كود Dart (`lib/`) و`pubspec.yaml` — بدون مجلدات `android/` و`ios/`
الخاصة بمشاريع Flutter (لأن توليدها يتطلب أدوات Flutter SDK الفعلية على جهازك).

نفّذ الخطوات التالية **مرة واحدة فقط**، من داخل مجلد `flutter_app/`:

```bash
# 1. تأكد إن Flutter مثبت عندك: flutter --version

# 2. ولّد ملفات المنصات (android/ios) داخل نفس المجلد
flutter create --org com.superai.lawyersbh --project-name lawyers_bh_client .

# 3. عند التوليد راح يسألك يستبدل pubspec.yaml أو lib/main.dart — اختر "لا" (n)
#    حتى تحافظ على الملفات الجاهزة اللي مرفقة معك.

# 4. نزّل الحزم
flutter pub get

# 5. شغّل التطبيق
flutter run
```

## 2) اربط التطبيق بالباكند

التطبيق يقرأ رابط الباكند من `API_BASE_URL` وقت البناء (dart-define)، والافتراضي هو
الإنتاج `https://www.lawyers.bh`. واجهة الموبايل نفسها جزء من نشر الموقع — ما فيه مضيف
API منفصل (`api.lawyers.bh` ما يُحلّ أصلًا):

```bash
# بيئة الاختبار (TEST)
flutter run --dart-define=API_BASE_URL=https://test.lawyers.bh

# الإنتاج (الافتراضي إذا ما مرّرت شي)
flutter build apk --release
```

ما فيه بيانات وهمية داخل التطبيق: الأسعار والمحامون والمواعيد كلها تُقرأ من الباكند، فأي
تغيير في لوحة الإدارة يظهر في التطبيق بدون إعادة بناء.

## 3) تفعيل الدفع الحقيقي (اختياري لهذه المرحلة)

شاشة `contract_payment_screen.dart` حاليًا تحاكي نجاح الدفع فورًا (`confirmPayment` تُستدعى مباشرة)
عشان تقدر تجرب تدفق التطبيق كامل بدون بوابة دفع فعلية. لتفعيل الدفع الحقيقي لاحقًا:

- **BenefitPay:** اطلب SDK الفليتر الرسمي من "بينفت" بعد تسجيل حساب تاجر، واستبدل استدعاء
  `_pay('benefitpay')` بفتح واجهة الدفع الخاصة بهم، ثم نادِ `confirmPayment` من `onSuccess`.
- **Apple Pay:** استخدم باقة مثل `pay` أو SDK معالج دفع (PayTabs/Stripe) يدعم Apple Pay بالبحرين.

## 4) الحزم المستخدمة

| الحزمة | الاستخدام |
|---|---|
| `google_fonts` | خطي Cairo (عناوين) و Tajawal (نصوص) بدون تضمين ملفات خطوط يدويًا |
| `http` | الاتصال بالـ API |
| `provider` | إدارة الحالة (الجلسة، الخدمات) |
| `shared_preferences` | حفظ رمز الدخول محليًا بين مرات فتح التطبيق |
| `signature` | لوحة التوقيع الإلكتروني بشاشة العقد |

## 5) هيكلة المشروع

```
lib/
  main.dart                    نقطة الدخول + RTL + الثيم
  theme/app_theme.dart         الألوان والخطوط (منسوخة من المعاينة المعتمدة)
  models/                      User, Lawyer, LegalCategory, LegalContract, LegalCase
  services/                    ApiClient + AuthService + LawyersService + CaseService + SosService
  providers/app_state.dart     الجلسة + حقن الخدمات
  screens/
    splash_screen.dart
    login_otp_screen.dart
    root_shell.dart            الشريط السفلي بـ4 تبويبات (الرئيسية/المطابقة/العقد/القضية)
    home_screen.dart
    lawyers_directory_screen.dart
    lawyer_profile_screen.dart
    my_contracts_screen.dart
    my_cases_screen.dart
    contract_payment_screen.dart
    case_tracking_screen.dart
  widgets/                     lawyer_row, category_tile, case_timeline, sos_button, status_badge, section_title
```

## 7) البناء عبر Codemagic (بدون تثبيت Flutter على جهازك أبدًا)

إذا ما تبي تثبت Flutter SDK محليًا، تقدر تخلي [Codemagic](https://codemagic.io/) يسوي كل شي:
يولّد مجلدات `android/ios`، ينزّل الحزم، ويبني لك APK/AAB (وحتى IPA لاحقًا) جاهزة للتحميل مباشرة.

ملف `codemagic.yaml` المرفق بهذا المجلد جاهز ومُعد مسبقًا بـ 3 قوالب بناء.

### الخطوات

1. **مهم:** حط محتويات مجلد `flutter_app/` هذا في **مستودع Git مستقل بحد ذاته** (وليس مع الباكند)،
   بحيث يكون `pubspec.yaml` و`codemagic.yaml` بجذر المستودع مباشرة — Codemagic يتعرف على مشروع
   Flutter من وجود `pubspec.yaml` بالجذر.
   ```bash
   cd flutter_app
   git init
   git add .
   git commit -m "Lawyers.bh client app"
   git remote add origin <رابط مستودعك على GitHub>
   git push -u origin main
   ```
2. افتح [codemagic.io](https://codemagic.io/) وسجّل دخول (يدعم تسجيل الدخول مباشرة بحساب GitHub).
3. اضغط **Add application** واختر المستودع اللي رفعته بالخطوة 1. Codemagic راح يكتشف تلقائيًا إنه
   مشروع Flutter ويقرأ `codemagic.yaml` الموجود.
4. من قائمة الـ Workflows بواجهة Codemagic، اختر:
   - **`android-debug`** → أسهل تجربة أولى، ما يحتاج أي إعداد توقيع، ينتج APK تقدر تثبته فورًا
     على جوالك للتجربة.
   - **`android-release`** → لإصدار حقيقي (Play Store أو توزيع مباشر)، يحتاج مفتاح توقيع
     (Keystore) — من Codemagic: **Team settings → Code signing identities → Android keystore**،
     ارفع أو ولّد Keystore جديد باسم `lawyers_bh_keystore` (نفس الاسم المذكور بالملف).
     كذلك يحتاج متغيّر `API_BASE_URL` (رابط الباكند الإنتاجي) داخل مجموعة متغيّرات باسم
     `lawyers_bh_prod`، ويُفضّل تعليمه **secure** في واجهة Codemagic. الـ Workflow يفشل مبكرًا
     إن لم يكن مضبوطًا، حتى لا يُبنى إصدار يشير إلى `localhost`.
   - **`ios-release`** → اختياري، يحتاج حساب Apple Developer فعّال (99$ سنويًا) + إعداد توقيع
     عبر App Store Connect API Key من نفس صفحة Code signing identities. تجاهله إذا ما عندك
     حساب Apple Developer حاليًا. يحتاج أيضًا `API_BASE_URL` من نفس المجموعة.
5. اضغط **Start new build**، اختر الـ Workflow، وانتظر — بعد انتهاء البناء (عادة 5-10 دقائق)
   راح تلقى رابط تحميل الـ APK/AAB مباشرة بصفحة نتيجة البناء.
6. بعد ما تربط رابط الباكند الحقيقي، كل `push` جديد لمستودعك ممكن يشغّل بناء تلقائي (لو فعّلت
   الـ triggering من إعدادات الـ workflow بـ Codemagic).

> **لا أسرار داخل `codemagic.yaml`.** لا مفاتيح ولا كلمات مرور ولا إيميلات مكتوبة بالملف؛
> كل ما يحتاج سرًّا يمر عبر توقيع Codemagic (`android_signing`/`ios_signing` → متغيّرات
> `CM_KEYSTORE_*`) أو عبر متغيّر `API_BASE_URL` المشفّر.

### ملاحظة

نفس فكرة `flutter create --platforms=android,ios ...` المذكورة بالخطوة 1 من هذا الملف، مضمّنة
تلقائيًا داخل كل Workflow بـ `codemagic.yaml` كخطوة أولى — يعني ما تحتاج تسويها يدويًا لا محليًا
ولا على Codemagic، الأداة نفسها تتكفل فيها أول ما تبدأ أول build.

كذلك، ولأن `flutter create` يولّد `android/app/build.gradle.kts` بتوقيع **debug** حتى لو رفعت
الـ Keystore، يتضمّن كل Workflow خطوة `python3 tool/configure_android_signing.py` تربط متغيّرات
Codemagic (`CM_KEYSTORE_PATH`, `CM_KEYSTORE_PASSWORD`, `CM_KEY_ALIAS`, `CM_KEY_PASSWORD`) بإعداد
Gradle. السكربت لا يغيّر أي شيء عند غياب هذي المتغيّرات، فتبقى البناءات المحلية شغّالة بمفاتيح
debug كالمعتاد.

### التشغيل والتحقق محليًا (اختياري)

كل ما يلي يحتاج Flutter SDK وJDK وAndroid SDK، وليس إلزاميًا لأن Codemagic يسويها عنك:

```bash
flutter pub get
flutter analyze                 # يجب أن ينتهي بـ "No issues found!"
flutter test                    # اختبارات دون اتصال؛ الاختبارات الحيّة تُتخطّى بدون API_BASE_URL
flutter build apk --debug       # نفس ناتج Workflow الأول
flutter build apk --release     # نفس ناتج Workflow الثاني (موقّع فقط لو ضبطت متغيّرات CM_)
```

للتحقق من العقد الحقيقي مقابل بيئة الاختبار:

```bash
flutter test --dart-define=API_BASE_URL=https://test.lawyers.bh test/api_contract_test.dart
flutter test --dart-define=API_BASE_URL=https://test.lawyers.bh test/backend_integration_test.dart
```

## 8) الهوية الرسمية (الأيقونة والاسم وشاشة الإقلاع)

التطبيق يحمل هوية **محامون البحرين** الرسمية، وليست أيقونة Flutter الافتراضية ولا أي هوية
قديمة. ولأن `android/` غير مُلتزَم بالمستودع (Codemagic يولّده بـ `flutter create`)، تُطبَّق
الهوية في `tool/prepare_android_platform.py` بعد خطوة التوليد:

- **الاسم:** `android:label` يصير «محامون البحرين» بدل اسم حزمة Dart (`lawyers_bh_client`).
- **الأيقونة:** الأيقونة الرسمية (ختم BH على خلفية حمراء `#B91D1C`) بكل الكثافات، مع أيقونة
  تكيّفية (adaptive icon) على API 26+ عبر `mipmap-anydpi-v26/ic_launcher.xml`.
- **شاشة الإقلاع:** نافذة الإقلاع الأصلية حمراء بشعار «محامون البحرين» الأبيض، فتطابق شاشة
  البداية داخل التطبيق بدل وميض أبيض.

الأيقونات مُولَّدة مسبقًا ومُلتزَمة تحت `tool/android_branding/`، والسكربت ينسخها فقط — يعني
البناء ما يحتاج أي أدوات صور. الشعار نفسه هو شعار الموقع الرسمي
(`assets/images/logo_bh.png` = `logo-BH.png` في الموقع)، والأيقونة المشتقّة من الختم الموجود
داخل `assets/brand/logo_color.png` المستخدم في شاشة البداية.

## 9) ملاحظة عن نطاق هذا التسليم

هذا التطبيق يغطي **واجهة العميل** فقط (حسب الاتفاق). واجهة المحامي (المكتب الافتراضي)،
وواجهة التشغيل/الإدارة، وغرفة التحكم الاستراتيجية للقيادة العليا — تحتاج تطبيقات/شاشات منفصلة
بجولة بناء قادمة، وقاعدة البيانات بالباكند مصممة بحيث تتوسع لها لاحقًا بسهولة.
