import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A professional-workspace status chip.
///
/// Kept separate from the client's [StatusBadge] because the professional
/// palette carries its own functional tones; both now lead with the same
/// official brand red, so the two appear as one product.
class ProBadge extends StatelessWidget {
  final String label;
  final Color tone;
  final bool filled;

  const ProBadge({super.key, required this.label, this.tone = LawyerColors.accent, this.filled = false});

  /// Maps the backend's lead status to a tone and Arabic label.
  factory ProBadge.lead(String status, {Key? key}) {
    final (label, tone) = leadStatus(status);
    return ProBadge(key: key, label: label, tone: tone, filled: true);
  }

  /// Maps the backend's case status to a tone and Arabic label.
  factory ProBadge.forCase(String status, {Key? key}) {
    final (label, tone) = caseStatus(status);
    return ProBadge(key: key, label: label, tone: tone);
  }

  /// Maps a case priority to a tone and Arabic label.
  factory ProBadge.forPriority(String priority, {Key? key}) {
    final (label, tone) = priorityOf(priority);
    return ProBadge(key: key, label: label, tone: tone);
  }

  static (String, Color) leadStatus(String status) {
    switch (status) {
      case 'new':
        return ('جديد', LawyerColors.accent);
      case 'contacted':
        return ('تم التواصل', Color(0xFF2A6FBF));
      case 'qualified':
        return ('مؤهّل', LawyerColors.emerald);
      case 'consultation':
        return ('استشارة', Color(0xFF7A5AF8));
      case 'proposal':
        return ('عرض مقدّم', Color(0xFFB7791F));
      case 'negotiation':
        return ('تفاوض', Color(0xFFD97706));
      case 'won':
        return ('مكتسب', LawyerColors.emerald);
      case 'converted':
        return ('محوّل إلى قضية', LawyerColors.emerald);
      case 'lost':
        return ('خسارة', Color(0xFFA62A2A));
      default:
        return (status, LawyerColors.ink2);
    }
  }

  static (String, Color) caseStatus(String status) {
    switch (status) {
      case 'new':
        return ('جديدة', LawyerColors.accent);
      case 'active':
      case 'open':
        return ('نشطة', LawyerColors.emerald);
      case 'pending':
        return ('معلّقة', Color(0xFFB7791F));
      case 'on_hold':
        return ('موقوفة', Color(0xFFD97706));
      case 'closed':
        return ('مغلقة', LawyerColors.ink2);
      case 'won':
        return ('مكسوبة', LawyerColors.emerald);
      case 'lost':
        return ('خاسرة', Color(0xFFA62A2A));
      default:
        return (status, LawyerColors.ink2);
    }
  }

  static (String, Color) priorityOf(String priority) {
    switch (priority) {
      case 'urgent':
        return ('عاجل', Color(0xFFA62A2A));
      case 'high':
        return ('مهم', Color(0xFFD97706));
      case 'low':
        return ('منخفض', LawyerColors.ink3);
      default:
        return ('عادي', LawyerColors.ink2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? tone : tone.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.cairo(
          size: 9.5,
          weight: FontWeight.w700,
          color: filled ? Colors.white : tone,
        ),
      ),
    );
  }
}
