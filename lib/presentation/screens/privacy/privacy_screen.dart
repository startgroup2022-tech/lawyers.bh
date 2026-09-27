import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سياسة الخصوصية', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'آخر تحديث: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 24),
            _Section('1. مقدمة', '''
تلتزم "محامون البحرين" بحماية خصوصيتك وبياناتك الشخصية. توضح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك عند استخدامك لتطبيقنا.'''),
            _Section('2. البيانات التي نجمعها', '''
- بيانات الحساب: الاسم، البريد الإلكتروني، رقم الهاتف، صورة الملف الشخصي
- بيانات التحقق: بطاقة الهوية، رخصة المحاماة (للمحامين)
- بيانات الاستخدام: سجلات النشاط، تفضيلات البحث، سجل الاستشارات
- بيانات المدفوعات: معلومات الدفع (لا نخزن تفاصيل البطاقات الكاملة)
- بيانات الموقع: المدينة/المنطقة (للتوصية بمحامين قريبين)
- بيانات الجهاز: نوع الجهاز، نظام التشغيل، إصدار التطبيق'''),
            _Section('3. كيفية استخدام البيانات', '''
- تقديم الخدمات: ربطك بالمحامين، حجز المواعيد، إدارة العقود
- تحسين الخدمة: تحليل الاستخدام، تخصيص التوصيات
- الأمان: منع الاحتيال، التحقق من الهوية
- التواصل: إشعارات المواعيد، التحديثات، العروض (بموافقتك)
- الامتثال القانوني: الاستجابة للطلبات القانونية، التدقيق'''),
            _Section('4. مشاركة البيانات', '''
لا نبيع بياناتك الشخصية. قد نشارك البيانات مع:
- المحامين: عند حجز استشارة أو التعاقد (البيانات اللازمة فقط)
- مقدمي خدمات الدفع: BenefitPay، Apple Pay (لإتمام المعاملات)
- مقدمي الخدمات التقنية: استضافة، تحليلات (تحت اتفاقيات سرية)
- الجهات القانونية: عند الطلب القانوني الملزم'''),
            _Section('5. حماية البيانات', '''
- تشفير البيانات أثناء النقل (TLS 1.3) وعند التخزين (AES-256)
- تخزين رموز الوصول بشكل آمن في Keychain/Keystore
- مراجعات أمنية دورية واختبارات اختراق
- تدريب الفريق على حماية البيانات'''),
            _Section('6. حقوقك', '''
بموجب قانون حماية البيانات الشخصية البحريني، يحق لك:
- الوصول لبياناتك والحصول على نسخة منها
- تصحيح البيانات غير الدقيقة
- طلب حذف بياناتك (مع مراعاة الالتزامات القانونية)
- تقييد أو الاعتراض على المعالجة
- نقل البيانات إلى جهة أخرى
- سحب الموافقة في أي وقت'''),
            _Section('7. الاحتفاظ بالبيانات', '''
- بيانات الحساب: طوال فترة نشاط الحساب + 5 سنوات بعد الإغلاق
- سجلات المعاملات: 10 سنوات (متطلبات مالية)
- سجلات النشاط: سنتان
- بيانات التحقق: طوال فترة الترخيص + 3 سنوات'''),
            _Section('8. ملفات تعريف الارتباط والتتبع', '''
نستخدم تقنيات تتبع أساسية لـ:
- جلسات العمل (ضرورية)
- التحليلات مجهولة الهوية (اختيارية، يمكن تعطيلها)
- لا نستخدم ملفات تعريف ارتباط إعلانية'''),
            _Section('9. خصوصية الأطفال', '''
خدماتنا مخصصة للأشخاص بعمر 18 عاماً فأكثر. لا نجمع عمداً بيانات من القصر. إذا اكتشفنا ذلك، نحذف البيانات فوراً.'''),
            _Section('10. النقل الدولي للبيانات', '''
قد تتم معالجة البيانات على خوادم خارج البحرين. نضمن توفير حماية مكافئة عبر بنود تعاقدية قياسية أو قرارات كفاية.'''),
            _Section('11. التغييرات على السياسة', '''
سنخطرك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني قبل 30 يوماً من سريانها.'''),
            _Section('12. التواصل', '''
لأي استفسارات حول الخصوصية أو ممارسة حقوقك:
- مسؤول حماية البيانات: dpo@lawyers.bh
- البريد الإلكتروني: privacy@lawyers.bh
- الهاتف: +973 17 XXX XXX
- العنوان: مملكة البحرين - المنامة'''),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2, height: 1.7)),
        ],
      ),
    );
  }
}