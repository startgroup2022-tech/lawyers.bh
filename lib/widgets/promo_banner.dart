import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_logo.dart';

/// One slide in the home banner. Slides carry brand messaging and a real call to
/// action only — no invented offers, prices or lawyer data.
///
/// [showWordmark] swaps the decorative icon for the official platform wordmark,
/// so the brand slide uses the exact asset the rest of the app uses.
class BannerSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final String actionLabel;
  final VoidCallback onAction;
  final bool showWordmark;

  const BannerSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.actionLabel,
    required this.onAction,
    this.showWordmark = false,
  });
}

/// A compact, auto-advancing banner.
///
/// Deliberately short (about a fifth of a phone screen) so the main sections
/// below it stay above the fold. It pauses while the user is dragging and loops
/// through the supplied slides.
class PromoBanner extends StatefulWidget {
  final List<BannerSlide> slides;
  final double height;

  const PromoBanner({super.key, required this.slides, this.height = 138});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.slides.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              // Hold the timer while the user is interacting, then resume.
              if (n is ScrollStartNotification) _timer?.cancel();
              if (n is ScrollEndNotification) _startAutoPlay();
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => _slide(widget.slides[i]),
            ),
          ),
        ),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.slides.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.brandRed : AppColors.ink3.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _slide(BannerSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: slide.colors,
          ),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(slide.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cairo(
                          size: 15.5, weight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(slide.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.tajawal(
                          size: 11.5,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: slide.onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.brandRed,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle:
                            AppTextStyles.cairo(size: 11.5, weight: FontWeight.w700),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 14),
                      label: Text(slide.actionLabel),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              // The brand slide carries the official platform emblem — the same
              // asset the splash and sign-in use — instead of a generic icon.
              child: slide.showWordmark
                  ? const BrandSeal(size: 34)
                  : Icon(slide.icon, size: 26, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
