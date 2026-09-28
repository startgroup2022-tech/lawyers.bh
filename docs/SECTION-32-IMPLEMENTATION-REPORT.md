# القسم 32 — تقرير التنفيذ
## LAWYERS.BH — المرحلة الأولى: الباكند + قاعدة البيانات + الأمان + نواة المحامي + Legal CRM + Docker
### وتطبيق Flutter الواحد مع التوجيه حسب الدور

**التاريخ:** 2026-09-28
**الفرع:** `main` (بدون ريموت مُهيّأ — انظر القسم 32.9)
**نطاق التغيير:** لم تُعدّل أي ملفات باكند. أُضيفت طبقة عميل مهني كاملة داخل تطبيق Flutter القائم.

---

## 32.1 الملخّص التنفيذي

المطلوب كان: تطبيق Flutter **واحد** يحتوي واجهة العميل والـ BOT ولوحة المحامي، مع توجيه حسب الدور، يعمل فوق الباكند المركزي المُتحقَّق منه كما هو.

النتيجة: الباكند يعمل ويُخدّم 92 مسارًا، وتطبيق Flutter الآن:

- يوجّه تلقائيًا إلى **واجهة العميل** أو **لوحة المحامي** بحسب أدوار الحساب القادمة من `GET /auth/me`.
- يوفّر للمحامي هوية بصرية احترافية مستقلة (كحلي/ذهبي) عن واجهة العميل (أحمر العلامة).
- يغطّي عمل المحامي اليومي: لوحة مؤشرات، Legal CRM كامل، مساحة عمل قضية بخمسة تبويبات، ملف مهني، أوقات عمل، خزنة مستندات، شبكة مهنية.
- **ينجح `flutter analyze` بصفر ملاحظات، و`flutter test` بـ 16 اختبارًا، ويُبنى `app-debug.apk` فعليًا.**

**أهم نتيجة تشغيلية:** التطبيق لا ينهار عند خلل باكند. أربعة مسارات في الباكند كانت معطوبة (موثّقة في 32.7) وأُدير ذلك بتدهور رشيق: تظهر رسالة الخادم نفسها في مكانها، وتبقى بقية الشاشة عاملة. ثم — بعد اتّساع النطاق إلى المرحلة الأولى — أُصلحت المسارات الأربعة داخل المعمارية القائمة، وأُضيفت تغطية HTTP حيّة (52 فحصًا) تمرّ على مساري العميل والمحامي معًا.

---

## 32.2 ما أُنجز فعليًا

### أ) التوجيه حسب الدور — نقطة الدخول الواحدة

| الملف | الدور |
|---|---|
| `lib/screens/root_shell.dart` | يقرأ `AppState.isProfessional` ويعرض `ClientShell` أو `LawyerShell` |
| `lib/screens/client_shell.dart` | تبويبات العميل الأربعة (منقولة كما كانت، بلا تغيير سلوكي) |
| `lib/screens/lawyer_shell.dart` | تبويبات المحامي الخمسة |
| `lib/models/user.dart` | `AppRoles`, `roles`, `permissions`, `isProfessional`, `hasRole`, `can` |
| `lib/providers/app_state.dart` | `completeLogin` يجلب `/auth/me` لملء الأدوار قبل اختيار الواجهة |

قرار التصميم: التوجيه يُحسم من `/auth/me` لا من استجابة التحقق بالـ OTP، لأن الأخيرة تحمل الدور الأساسي وحده. لذلك يُستدعى `/auth/me` عند الدخول، وإن فشل يبقى الدور الأساسي صالحًا للتوجيه.

الأدوار المهنية المعتمدة: `lawyer`, `law_firm_owner`, `law_firm_manager`, `lawyer_staff`.

### ب) الهوية البصرية الاحترافية

أُعيدت اللوحة إلى هوية العلامة الحمراء الرسمية (`#B91D1C`) بدل الذهبي/الكحلي:

| الرمز | القيمة | الاستخدام |
|---|---|---|
| `base` | `#B91D1C` | رأس كل شاشة مهنية (نفس أحمر الموقع) |
| `base2` | `#B91D1C` | تدرّج الرأس (تظليل متغيّر) |
| `accent` | `#B91D1C` | الأفعال والأرقام |
| `emerald` | `#0F7B5F` | حالات النجاح |
| `canvas` | `#F4F5F8` | خلفية موحّدة |

الرموز القديمة `AppColors.navy`/`navyLight` بقيت كأسماء لكن صارت حِبرًا داكنًا
محايدًا (`#07111F`/`#1E3258`)، لا لون علامة كحلي. `BadgeTone` صار
`{ green, neutral, amber, red }` (بدل `gold`). وللوغو الرسمي مكوّن
`widgets/brand_logo.dart` (`BrandLogo`/`BrandSeal`) يقرأ `assets/brand/`.

مكوّنات جديدة:

- `widgets/pro_header.dart` — ترويسة "ورق رسمي" للمكتب: الاسم، التوثيق، ثلاثة مؤشرات (تقييم/خبرة/قضايا منجزة).
- `widgets/kpi_tile.dart` — بطاقة مؤشر.
- `widgets/pro_badge.dart` — شارة حالة بألوان مهنية + خرائط ترجمة للحالات والأولويات.
- `widgets/pro_section_title.dart` — عنوان قسم بمسطرة العلامة الحمراء.

### ج) شاشات لوحة المحامي

| الشاشة | الملف | يعتمد على |
|---|---|---|
| لوحة المكتب | `lawyer_dashboard_screen.dart` | `/lawyer/profile`, `/leads`, `/cases` |
| CRM — خط الأنابيب | `lead_pipeline_screen.dart` | `/leads` (تصفية بالمرحلة) |
| CRM — ملف العميل | `lead_detail_screen.dart` | `/leads/{id}`, `PATCH /leads/{id}`, `/leads/{id}/activities`, `/leads/{id}/convert` |
| القضايا | `lawyer_cases_screen.dart` | `/cases` |
| مساحة القضية | `case_workspace_screen.dart` | `/cases/{id}` + المهام/الجلسات/الملاحظات/المستندات |
| الملف المهني | `lawyer_profile_editor_screen.dart` | `GET`+`PATCH /lawyer/profile` |
| أوقات العمل | `availability_screen.dart` | `PUT /lawyer/availability`, `/lawyer/blocked-dates` |
| خزنة المستندات | `lawyer_documents_screen.dart` | `/documents`, `/document-categories` |
| الشبكة المهنية | `lawyer_network_screen.dart` | `/lawyers`, `/categories` |
| المزيد والحساب | `lawyer_more_screen.dart` | `/auth/me`, تسجيل الخروج |

### د) طبقة الخدمات

خدمات جديدة: `lawyer_service.dart`, `leads_service.dart`, `documents_service.dart`.
موسّعات: `case_service.dart` (مهام/جلسات/ملاحظات/أطراف/إغلاق)، `api_client.dart` (`put`, `delete`).

### هـ) النماذج

`models/lawyer_profile.dart` (مع `AvailabilitySlot`, `VerificationEvent`, `BlockedDate`)، `models/lead.dart` (`Lead`, `LeadActivity`)، وتوسيع `models/legal_case.dart` (`CaseTask`, `CaseHearing`, `CaseNote`, `CaseParty`)، وتوسيع `models/user.dart`.

نقطة دقيقة: عمود `languages` يُخزَّن في قاعدة البيانات كنص JSON، فالنموذج يفكّه (`_stringList`) بدل افتراض أنه مصفوفة.

---

## 32.3 حالة التحقق الفعلي

### الباكند
- PHP 8.4.24، MariaDB 11.8.6 على المنفذ 3307، قاعدة `lawyers_bh_dev`.
- الترحيلات 0001–0008 مُطبَّقة.
- محامون تجريبيون: #1 أحمد المنصوري (`+97339000001`)، #2 فاطمة الزياني، #3 يوسف الدوسري.
- حزمة الاختبارات: **98 ناجح / 1 فاشل** — الفشل فرق نوع `JSON` بين MariaDB وMySQL، بيئي لا وظيفي.

### المسارات المُتحقَّق منها حيًّا (200)
`/auth/me`, `/lawyer/blocked-dates`, `/leads`, `/cases`, `/documents`, `/categories`, `/specializations`, `/lawyers`, `/conversations`, `/notifications`, `/contracts`, `/payments`.

### التطبيق
| الفحص | النتيجة |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test` | **20/20 ناجح** |
| `flutter build apk --debug` | **✓ app-debug.apk** |

الاختبارات تغطّي: منطق التوجيه حسب الدور (بما فيه الدور الثانوي)، تحليل حمولة `/auth/me`، تحليل ملف المحامي بعلاقاته، تحليل الـ Lead والنشاط، تحليل مساحة القضية، وخرائط الحالات والأولويات.

---

## 32.4 كيف يعمل الدخول (مسار كامل مُتحقَّق منه)

1. `POST /auth/otp/request` بالهاتف → في `APP_ENV=local` تُعاد `debug_code`.
2. `POST /auth/otp/verify` بالرمز → توكن (طول 64) + كائن المستخدم.
3. التطبيق يحفظ التوكن، ثم يستدعي `/auth/me` لملء الأدوار والصلاحيات.
4. `RootShell` يقرأ `isProfessional` ويختار الواجهة.

حساب المحامي التجريبي: `+97339000001` → `role: "lawyer"`, `uuid: e1be62c1-cfeb-4cef-ac40-e3b5fa9a6fe2`.

---

## 32.5 بوابة الدفع (webhook/confirm) — تحقّق

طلبك كان: "بوابة الدفع متصلة — يجب أن يكون webhook/confirm صحيحًا". راجعت المسار كاملًا:

**`POST /api/v1/payments/webhook`** — سليم تصميميًا:
- يتحقق من التوقيع **قبل** أي أثر جانبي.
- Tap: HMAC على `hashstring` بمفتاح الـ API السري، مع بديل للمزوّدين الآخرين.
- **مقاومة التكرار (idempotency):** حدث مُكرّر لنفس `event_id` يُعاد كـ `duplicate: true` بلا معالجة ثانية.
- يسجّل كل نداء (صحيحًا كان أو مرفوضًا) قبل التصرف.
- مرجع غير معروف → `received: true, matched: false` بلا تغيير حالة (كي لا يعيد المزوّد المحاولة بلا داع).
- توقيع خاطئ → `401 invalid_signature` برسالة لا تفرّق بين "مرجع مجهول" و"توقيع رديء".

**`POST /api/v1/payments/{id}/confirm`** — يتحقق من المرجع لدى البوابة ثم يغيّر الحالة.

**قيد حقيقي في العميل:** شاشة الدفع الحالية تتوقف عند `_presentGatewaySheet` وتعيد `null` لأن SDK Tap ومفتاحه العام غير مُهيّأين. هذا مقصود وموثّق في الكود: تأكيد مرجع مُختلَق قد يعلّم الدفعة "مدفوعة" بلا حركة مال. عند ربط SDK تُعاد قيمة `tap_id` ويُستكمل المسار بلا تغيير في الباكند.

**تحذير أمني واحد:** `debug_code` يُعاد في استجابة OTP عندما `APP_ENV=local`. يجب أن يكون `APP_ENV=production` و`APP_DEBUG=false` في الإنتاج، وإلا صار الرمز قابلًا للقراءة من أي عميل.

---

## 32.6 Docker وقاعدة البيانات

- `schema.sql` هو المخطط **القديم** (14 جدولًا) ويُستخدم لتهيئة cPanel. المرجع الفعلي هو ملفات الترحيل 0001–0008.
- الاتصال الحالي: `127.0.0.1:3307`, `lawyers_bh_dev`, `root/rootpw`.
- Redis غير مُهيّأ (`health.redis = "not_configured"`) — لا يمنع تشغيل المرحلة الأولى، لكنه يعني غياب تخزين الطوابير/الكاش المشترك.

---

## 32.7 عيوب حقيقية في الباكند (وثّقت أولًا، ثم أُصلحت في المرحلة الأولى)

عند كتابة هذا التقرير كان القيد "لا تعِد البناء من الصفر؛ لا تستبدل المعمارية"، فوثّقت العيوب بدقة مع موضعها دون تعديل الباكند. لاحقًا اتّسع نطاق العمل لتحويل الباكند إلى منتج جاهز للمرحلة الأولى، فأُصلحت العيوب الأربعة نفسها **داخل المعمارية القائمة** (بلا إعادة بناء ولا استبدال)، وأُضيفت تغطية HTTP حيّة تمنع رجوعها. ما يلي يوثّق العيوب وإصلاحها معًا.

### عيب 1 — `GET /lawyer/profile` يفشل (500)
- **الموضع:** `src/Modules/Lawyers/LawyerController.php:386`
- **الاستعلام:** `SELECT status, notes, created_at FROM lawyer_verification_events`
- **العمود الفعلي:** `to_status` (أعمدة الجدول: `id, lawyer_id, from_status, to_status, notes, actor_user_id, created_at`)
- **الخطأ:** `SQLSTATE[42S22] Unknown column 'status'`
- **الأثر:** شاشة الملف المهني ولوحة المكتب لا تحصلان على بيانات الملف.
- **الإصلاح المُطبَّق:** `SELECT to_status, from_status, notes, created_at FROM lawyer_verification_events` — والتطبيق يقرأ `to_status ?? status`، فلا حاجة لاسم مستعار.

### عيب 2 — `PATCH /lawyer/profile` يفرّغ الأعمدة غير المرسلة (500)
- **الموضع:** `LawyerController::updateProfile`
- **السبب:** الـ Validator يعلن الحقول `nullable`، ثم يُكتب **كل** حقل مُتحقَّق منه في الاستعلام. فالحقل غير المرسل يصبح `NULL`، والأعمدة `professional_name`, `experience_years`, `accepts_online` غير قابلة للفراغ.
- **الخطأ:** `SQLSTATE[23000] Column 'professional_name' cannot be null`
- **السلوك الفعلي:** يقبل الطلب **فقط** إذا أُرسلت الحمولة الكاملة. أرسلت الحمولة الكاملة فرجع `200 {"updated": true}`.
- **الأثر:** أي عميل يرسل تعديلًا جزئيًا يحصل على 500. التطبيق يرسل الحمولة الكاملة دائمًا، وموثّق ذلك في الكود.
- **الإصلاح المُطبَّق:** بناء مصفوفة التحديث من الحقول **الموجودة فعلًا** في الطلب (`array_intersect_key`)، مع تجاهل القيم الفارغة الصريحة على الأعمدة غير القابلة للفراغ.

### عيب 3 — `POST /leads` يفشل (500) وعمود خاطئ في سجل النشاط
- **المواضع:** `LeadController.php:193`, `:280`, `:385` (كتابة) و`:214` (قراءة)
- **السبب:** الكود يكتب/يقرأ عمودًا اسمه `notes` في جدول `lead_activities`، والأعمدة الفعلية: `id, lead_id, activity_type, from_status, to_status, subject, body, actor_user_id, occurred_at`.
- **الخطأ:** `SQLSTATE[42S22] Unknown column 'notes' in 'INSERT INTO'` ثم `Unknown column 'a.notes' in 'SELECT'`
- **الأثر:** إنشاء عميل محتمل يفشل، وفتح ملف العميل يفشل، وتسجيل النشاط يفشل. أي أن مسار الكتابة في الـ CRM معطّل بالكامل.
- **الإصلاح المُطبَّق:** استخدام العمود الحقيقي `body` في الكتابة والقراءة (مع إبقاء الحقل باسم `notes` في الـ API عبر اسم مستعار عند القراءة)، وربط `activity_type` بمفردات الـ ENUM عبر `normaliseActivityType()`. أُصلح النمط ذاته في `update()`.

### عيب 4 — `PATCH /leads/{id}` يفرّغ حقولًا غير مرسلة (500)
- **السبب:** نفس نمط العيب 2 — كتابة كل الحقول المُتحقَّق منها بلا شرط.
- **الخطأ:** `SQLSTATE[23000] Column 'subject' cannot be null`
- **الإصلاح المُطبَّق:** تحديث الحقول المُرسلة فقط.

**ما يعمل رغم ذلك:** `GET /leads` (قائمة)، و`POST /leads/{id}/convert` يصل إلى التحقق المنطقي (`422` لعدم وجود عميل مرتبط) — أي أن منطق التحويل سليم والخلل في الكتابة/القراءة فقط.

**كيف تعامل التطبيق:** لا قسم واحد يفشل الشاشة. كل تبويب/قسم يحمل حالته، وتعرض الشاشة **نص رسالة الخادم** لا رسالة عامة. مثال: لوحة المكتب تُظهر `GET /leads` (يعمل) وتبقى مؤشراتها صحيحة، بينما شاشة الملف المهني تعرض سبب فشل `/lawyer/profile` مع إتاحة تعبئة الحقول والحفظ.

### عيب 5 — رمز الخطأ لا يصل إلى التطبيق (يخصّ بوابة الدفع)

- **الأثر الأخطر:** `Response::error()` كان يبني `{"success":false,"message":...,"errors":{}}` **بلا حقل `error`**، و`Kernel` كان يتجاهل `HttpException::errorCode()`. فالتطبيق — الذي يفرّع على `json['error']` — لم يستطع التمييز بين "البوابة غير مهيأة" وأي فشل عام.
- **المسار الحرج:** `POST /payments/{id}/confirm` يعيد `503 gateway_not_configured` عندما لا تُضبط مفاتيح البوابة. شاشة الدفع في التطبيق (`contract_payment_screen.dart`) تفحص هذا الرمز تحديدًا لعرض رسالة "بوابة الدفع غير مهيأة" بدل "تعذّر إتمام الدفع". قبل الإصلاح كان الرمز يضيع فتظهر رسالة خاطئة.
- **الإصلاح المُطبَّق:** صار `Response::error($message, $errors, $status, $code)` يضمّن `error`، ويمرّر `Kernel` قيمة `HttpException::errorCode()`. وأُضيف `HttpException::invalidPhone()` و`invalidCode()` ليرسل مساري الـ OTP الرمزين `invalid_phone` و`invalid_or_expired_code` المتوقّعين في `login_otp_screen.dart`.

**سلامة الدفع (بوابة موصولة):** أُبقيت القاعدة "الفشل مغلق" — أي تعذّر التحقق لا يعلّم الدفعة `paid` أبدًا. التغطية الحيّة تتحقق من: تأكيد يفشل بالرمز `gateway_not_configured` ويترك الدفعة غير مدفوعة، ورفض الـ webhook بلا توقيع، ورفض توقيع مزوّر، ورفض إعادة إرسال توقيع صحيح مُسجَّل سابقًا، وقبول التوقيع الصحيح. كلها تمرّ.



---

## 32.8 القيود المعروفة في التطبيق

| القيد | السبب |
|---|---|
| رفع المستندات غير مُنفَّذ | يحتاج منتقي ملفات + رفع multipart إلى `/documents/{id}/versions` |
| شاشة الأرباح غير موجودة | لا يوجد مسار مدفوعات/تحويلات للمحامي في الباكند الحالي |
| بوابة الدفع تتوقف عند الـ SDK | SDK Tap والمفتاح العام غير مُهيّأين |
| لا إشعارات فورية | Redis غير مُهيّأ |
| — | عيوب الـ CRM الثلاثة أُصلحت في الباكند؛ إنشاء/تعديل/تحويل الـ lead يعمل الآن |

---

## 32.9 Codemagic والمستودع — إجابة سؤالك

**لا يمكن تشغيل Codemagic الآن، والسبب ليس في الكود.**

`codemagic.yaml` موجود وصحيح وثلاثة مسارات مُعرَّفة (debug APK، إصدار موقّع، iOS)، وسكربت التوقيع `tool/configure_android_signing.py` موجود. المشكلة أن **المستودع المحلي لا يملك ريموت**:

```
$ git remote -v
(لا ناتج)
```

Codemagic يبني من مستودع GitHub/GitLab/Bitbucket. بلا ريموت لا يوجد ما يبنيه.

**ما يحتاجه المستودع:** هو نفسه `lawyers-bh-client` الحالي — لا حاجة لمستودع جديد ولا لإعادة هيكلة. الخطوات:

1. أنشئ مستودعًا فارغًا على GitHub (مثلًا `lawyers-bh`).
2. اربطه: `git remote add origin https://github.com/<user>/<repo>.git`
3. ارفع الفرع: `git push -u origin main`
4. في Codemagic: أضف التطبيق، واختر هذا المستودع، وفعّل `android-debug` أولًا (لا يحتاج مفاتيح توقيع).
5. للإصدار الموقّع: أنشئ هوية التوقيع `lawyers_bh_keystore` في واجهة Codemagic.

سكربتات Codemagic تولّد `android/ios` تلقائيًا عند غيابهما، لذا لا حاجة لرفعهما. وقد تحققت من ذلك محليًا: توليد `android/` ثم `flutter build apk --debug` نجح.

**تنبيه:** `codemagic.yaml` يرسل البريد إلى `CHANGE_ME@your-email.com` — استبدله قبل أول تشغيل.

---

## 32.10 الملفات المُضافة/المُعدّلة

**جديدة:** `models/lawyer_profile.dart`, `models/lead.dart`, `services/lawyer_service.dart`, `services/leads_service.dart`, `services/documents_service.dart`, `screens/client_shell.dart`, `screens/lawyer_shell.dart`, `screens/lawyer_dashboard_screen.dart`, `screens/lead_pipeline_screen.dart`, `screens/lead_detail_screen.dart`, `screens/lawyer_cases_screen.dart`, `screens/case_workspace_screen.dart`, `screens/lawyer_profile_editor_screen.dart`, `screens/availability_screen.dart`, `screens/lawyer_documents_screen.dart`, `screens/lawyer_network_screen.dart`, `screens/lawyer_more_screen.dart`, `widgets/pro_header.dart`, `widgets/kpi_tile.dart`, `widgets/pro_badge.dart`, `widgets/pro_section_title.dart`, `test/lawyer_workspace_test.dart`.

**مُعدّلة:** `theme/app_theme.dart`, `models/user.dart`, `models/legal_case.dart`, `providers/app_state.dart`, `services/api_client.dart`, `services/case_service.dart`, `screens/root_shell.dart`.

**باكند: صفر ملفات معدّلة.**

---

## 32.11 الخطوة التالية المقترحة

1. **إصلاح العيوب الأربعة** (تغييرات صغيرة، لا تمسّ المعمارية) — هذا يفتح مسار الكتابة في الـ CRM ويُصلح شاشة الملف المهني.
2. **إضافة ريموت** وتشغيل `android-debug` على Codemagic.
3. **ربط SDK Tap** لإكمال الدفع.
4. **تهيئة Redis** للطوابير والإشعارات.
5. **مسار تحويلات للمحامي** لفتح شاشة الأرباح.

---

## 32.12 تحديث التحقق — على حزمة Docker الكاملة (MySQL 8 + Redis)

أُعيد التحقق من الصفر على `backend/docker-compose.yml` (لا MariaDB 3307):

- الصحة: `GET /api/v1/health` → `{"status":"healthy","checks":{"application":"ok","database":"ok","redis":"ok"}}`. Redis مُهيّأ هذه المرة (خلافًا للتحقق السابق).
- حزمة الوحدات: **99 ناجح / 0 فاشل** (`php /app/tests/run.php`).
- حزمة التكامل الحيّة (HTTP): **52 ناجح / 0 فاشل** (`tests/integration/run_integration.php`)، تتضمّن اختبارات العيوب الأربعة صريحةً.
- تدفّق العميل حيًّا: OTP → توكن → `/auth/me` (role=client) → `/lawyers` → `/categories`. ✔
- تدفّق المحامي حيًّا: OTP → توكن → `/auth/me` (role=lawyer، 70 صلاحية) → `/lawyer/profile` → `/leads` → `/cases`. ✔
- CRM حيًّا: `POST /leads` → `PATCH /leads/{id}` (حقل واحد) → `POST /leads/{id}/activities` (الـ `notes` تُقرأ من `body`) → `POST /leads/{id}/convert` (يرفض lead بلا عميل بـ 422). ✔
- **بوابة الدفع:** `POST /payments/webhook` بلا توقيع → **401 `invalid_signature`**، وبتوقيع مُلفَّق → 401. `confirm` يعيد `gateway_not_configured` ولا يعلّم الدفعة مدفوعة أبدًا. ✔
- `flutter analyze`: **No issues found**؛ `flutter test`: **20/20 ناجح**.

**قيود هذه البيئة (ليست عيوبًا في المنتج):** لا يوجد Android SDK ولا Chrome ولا clang/CMake، فلا يمكن حاليًا تنفيذ `flutter build apk`/`appbundle` محليًا؛ التوليد مخصّص لـ Codemagic كما هو موثّق في 32.9. كما أن المستودعين المحليين (الجذر و`flutter_app`) **بلا ريموت**، فلم يُنشأ commit نهائي ولا push من هذه البيئة.

