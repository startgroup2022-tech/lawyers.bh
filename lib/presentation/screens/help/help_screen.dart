import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final faqs = [
      ('كيف أسجل في المنصة؟', 'يمكنك التسجيل عبر رقم الهاتف مع التحقق الفوري (OTP)، أو عبر البريد الإلكتروني. اختر نوع حسابك (عميل أو محامٍ) وأكمل البيانات المطلوبة.'),
      ('كيف أبحث عن محامٍ مناسب؟', 'استخدم شاشة البحث لتصفية المحامين حسب التخصص، الموقع، التقييم، ورسوم الاستشارة. يمكنك أيضاً تصفح المحامين حسب التخصص من الشاشة الرئيسية.'),
      ('ما هي أنواع الاستشارات المتاحة؟', 'ثلاثة أنواع: استشارة فيديو (مكالمات فيديو)، استشارة صوتية (مكالمات هاتفية)، واستشارة حضورية (في مكتب المحامي).'),
      ('كيف تتم عملية الدفع؟', 'تدعم المنصة الدفع عبر BenefitPay و Apple Pay. يتم حجز المبلغ في حساب ضمان (Escrow) حتى إتمام الخدمة.'),
      ('ماذا لو لم أكن راضياً عن الخدمة؟', 'يمكنك فتح نزاع عبر المنصة وسيقوم فريق فض النزاعات بمراجعة الحالة والتدخل لحل المشكلة بشكل عادل.'),
      ('كيف أحجز موعداً مع محامٍ؟', 'من ملف المحامي، اختر نوع الاستشارة واضغط "احجز استشارة". ستظهر لك المواعيد المتاحة للاختيار منها.'),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.helpSupport),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_center, color: AppColors.gold, size: 32),
                      const SizedBox(width: 12),
                      Text('مركز المساعدة', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ابحث عن إجابات للأسئلة الشائعة أو تواصل مع فريق الدعم',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'تواصل معنا',
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppOutlinedButton(
                          text: 'الدردشة المباشرة',
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.white),
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          final (question, answer) = faqs[index - 1];
          return ExpansionTile(
            title: Text(question, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            tilePadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius)),
            backgroundColor: AppColors.surface,
            collapsedBackgroundColor: AppColors.surface,
            children: [
              Text(answer, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2, height: 1.6)),
            ],
          );
        },
      ),
    );
  }
}