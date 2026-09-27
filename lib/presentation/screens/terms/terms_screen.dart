import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.termsConditions),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الشروط والأحكام', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'آخر تحديث: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 24),
            _Section('1. القبول بالشروط', '''
باستخدامك لتطبيق "محامون البحرين"، فإنك تقر بأنك قرأت وفهمت ووافقت على هذه الشروط والأحكام وسياسة الخصوصية الخاصة بنا. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام التطبيق.'''),
            _Section('2. وصف الخدمة', '''
"محامون البحرين" هي منصة إلكترونية تربط بين العملاء الباحثين عن خدمات قانونية والمحامين المرخصين في مملكة البحرين. المنصة توفر:
- دليل المحامين المرخصين
- حجز الاستشارات القانونية (فيديو، صوت، حضوري)
- التعاقد الآمن مع حماية المدفوعات (Escrow)
- متابعة القضايا وإدارة المستندات
- نظام تقييم ومراجعات شفاف'''),
            _Section('3. التسجيل والحساب', '''
- يجب أن تكون بعمر 18 عاماً أو أكثر للتسجيل
- يجب تقديم معلومات دقيقة وكاملة
- أنت مسؤول عن سرية بيانات دخولك
- يحق للمنصة تعليق أو إغلاق الحسابات المخالفة'''),
            _Section('4. خدمات المحامين', '''
- جميع المحامين على المنصة مرخصون من وزارة العدل
- المنصة لا تقدم استشارات قانونية مباشرة
- العلاقة التعاقدية تتم بين العميل والمحامي مباشرة
- المنصة توفر البنية التقنية وحماية المدفوعات فقط'''),
            _Section('5. المدفوعات وحماية الأموال', '''
- تتم المدفوعات عبر بوابات دفع معتمدة (BenefitPay, Apple Pay)
- يتم حجز المبلغ في حساب ضمان حتى إتمام الخدمة
- يتم تحرير المبلغ للمحامي بعد تأكيد العميل أو انقضاء المدة المحددة
- يحق للعميل طلب استرداد المبلغ في حالات محددة'''),
            _Section('6. فض النزاعات', '''
- يتوفر آلية لفض النزاعات بين العملاء والمحامين
- يتدخل فريق متخصص لمراجعة الأدلة واتخاذ قرار عادل
- قرارات فض النزاعات نهائية وملزمة للطرفين'''),
            _Section('7. الملكية الفكرية', '''
- جميع محتويات التطبيق (شعار، تصاميم، كود) ملك للمنصة
- لا يجوز نسخ أو إعادة استخدام أي جزء دون إذن كتابي
- علامات "محامون البحرين" و "Lawyers.bh" علامات تجارية مسجلة'''),
            _Section('8. تحديد المسؤولية', '''
- المنصة وسيط تقني ولا تتحمل مسؤولية جودة الخدمة القانونية
- الحد الأقصى لمسؤولية المنصة يقتصر على المبلغ المدفوع للخدمة
- لا تتحمل المنصة أضراراً غير مباشرة أو تبعية'''),
            _Section('9. التعديلات', '''
يحق للمنصة تعديل هذه الشروط في أي وقت. سيتم إخطار المستخدمين بالتغييرات الجوهرية عبر التطبيق أو البريد الإلكتروني. استمرار استخدام التطبيق بعد التعديلات يعني قبولها.'''),
            _Section('10. القانون المطبق والاختصاص', '''
تخضع هذه الشروط لقوانين مملكة البحرين. أي نزاع ينشأ عنها يخضع لاختصاص محاكم البحرين حصراً.'''),
            _Section('11. التواصل', '''
للاستفسارات حول هذه الشروط:
- البريد الإلكتروني: legal@lawyers.bh
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