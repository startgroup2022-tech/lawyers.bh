import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SosButton extends StatelessWidget {
  const SosButton({super.key});

  Future<void> _confirmAndTrigger(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('نجدة قانونية عاجلة', style: AppTextStyles.cairo(size: 15)),
        content: Text(
          'راح يتم إشعار فريق التشغيل بطلب نجدة عاجل باسمك. هل تريد المتابعة؟',
          style: AppTextStyles.tajawal(size: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.crimson),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، أرسل النجدة'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final appState = context.read<AppState>();
    try {
      await appState.sos.trigger(note: 'تفعيل من زر SOS بواجهة العميل');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلب النجدة، سيتم التواصل معك فورًا.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر إرسال طلب النجدة، حاول مرة أخرى.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _confirmAndTrigger(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.crimson, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text('SOS', style: AppTextStyles.cairo(size: 11, weight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
