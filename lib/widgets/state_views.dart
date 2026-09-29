import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The three non-happy states a data-backed screen can be in, rendered the same
/// way everywhere so the app reads as one product:
///
///   [LoadingState]  a skeleton shaped like the content that is coming.
///   [ErrorState]    a plain explanation plus a retry.
///   [EmptyState]    "nothing here yet" with an optional action.
///
/// Screens were previously each rolling their own spinner-or-message block,
/// which is why some had a bare `CircularProgressIndicator` while others had an
/// icon and a button. Centralising them keeps spacing, type and tone consistent.

/// A shimmer-free skeleton: a soft placeholder block. Cheaper than an animated
/// shimmer and it cannot jank a low-end device while the first frame settles.
class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const SkeletonBox({super.key, required this.height, this.width, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.neutralBg,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A skeleton for a list of lawyer rows — the shape most screens load first.
class LawyerListSkeleton extends StatelessWidget {
  final int count;
  const LawyerListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              const SkeletonBox(height: 46, width: 46, radius: 23),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(height: 12, width: 150),
                    SizedBox(height: 8),
                    SkeletonBox(height: 10, width: 90),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centred loading state. When [skeleton] is set the caller supplies skeleton
/// content (shaped like the real content) instead of the generic spinner.
class LoadingState extends StatelessWidget {
  final Widget? skeleton;
  final String? label;

  const LoadingState({super.key, this.skeleton, this.label});

  @override
  Widget build(BuildContext context) {
    if (skeleton != null) return skeleton!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.brandRed),
          ),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!,
                textAlign: TextAlign.center,
                style: AppTextStyles.tajawal(size: 12.5, color: AppColors.ink2)),
          ],
        ],
      ),
    );
  }
}

/// A friendly failure with a retry. [onRetry] is required because a dead end
/// with no way forward is worse than the error itself.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final String retryLabel;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.cloud_off_outlined,
    this.retryLabel = 'إعادة المحاولة',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
                color: AppColors.neutralBg, shape: BoxShape.circle),
            child: Icon(icon, size: 26, color: AppColors.ink2),
          ),
          const SizedBox(height: 14),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.tajawal(size: 13, color: AppColors.ink2, height: 1.6)),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 17),
            label: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}

/// "Nothing here yet" — distinct from an error, and optionally actionable.
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: AppColors.ink3),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.tajawal(size: 13, color: AppColors.ink2, height: 1.6)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
