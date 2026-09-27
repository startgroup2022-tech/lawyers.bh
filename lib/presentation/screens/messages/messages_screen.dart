import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.messages),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: EmptyState(
        icon: Icons.chat_bubble_outline,
        title: l10n.noMessages,
        subtitle: 'ستظهر محادثاتك مع المحامين هنا',
        action: AppButton(
          text: l10n.searchLawyers,
          onPressed: () => context.go(AppRoutes.search),
        ),
      ),
    );
  }
}