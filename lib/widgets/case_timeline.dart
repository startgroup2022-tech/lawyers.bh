import 'package:flutter/material.dart';
import '../models/legal_case.dart';
import '../theme/app_theme.dart';

class CaseTimelineWidget extends StatelessWidget {
  final List<CaseMilestone> steps;
  const CaseTimelineWidget({super.key, required this.steps});

  Color _dotColor(String state) {
    switch (state) {
      case 'done':
        return AppColors.green;
      case 'active':
        return AppColors.crimson;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _dotColor(step.state),
                        border: Border.all(
                          color: step.state == 'done'
                              ? AppColors.green
                              : step.state == 'active'
                                  ? AppColors.crimson
                                  : AppColors.line,
                          width: 3,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: step.state == 'done' ? AppColors.green : AppColors.line,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 2),
                  child: Text(
                    step.label,
                    style: AppTextStyles.tajawal(
                      size: 13,
                      weight: step.state == 'pending' ? FontWeight.w500 : FontWeight.w700,
                      color: step.state == 'pending' ? AppColors.ink3 : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
