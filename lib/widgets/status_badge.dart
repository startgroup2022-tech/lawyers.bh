import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeTone { green, neutral, amber, red }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;
  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.neutral});

  (Color, Color) get _colors {
    switch (tone) {
      case BadgeTone.green:
        return (AppColors.greenBg, AppColors.green);
      case BadgeTone.neutral:
        return (AppColors.neutralBg, AppColors.neutralInk);
      case BadgeTone.amber:
        return (AppColors.amberBg, AppColors.amber);
      case BadgeTone.red:
        return (AppColors.redBg, AppColors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTextStyles.cairo(size: 9.5, weight: FontWeight.w700, color: fg)),
    );
  }
}
