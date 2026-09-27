import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';

void main() {
  group('Common Widgets Tests', () {
    testWidgets('AppButton should render correctly', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppButton(
                text: 'Test Button',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('AppButton should show loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppButton(
                text: 'Loading',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppInputField should render with label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppInputField(
                label: 'Email',
                hint: 'Enter email',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter email'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('AppCard should render child', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppCard(
                child: const Text('Card Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('AppChip should show selected state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppChip(
                label: 'Selected Chip',
                selected: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Selected Chip'), findsOneWidget);
      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isTrue);
    });

    testWidgets('AppBadge should render with correct type', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Column(
                children: [
                  AppBadge(text: 'Success', type: BadgeType.success),
                  AppBadge(text: 'Warning', type: BadgeType.warning),
                  AppBadge(text: 'Error', type: BadgeType.error),
                  AppBadge(text: 'Info', type: BadgeType.info),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
    });

    testWidgets('AppAvatar should show initials when no image', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppAvatar(name: 'أحمد محمد'),
            ),
          ),
        ),
      );

      expect(find.text('أح'), findsOneWidget);
    });

    testWidgets('EmptyState should render correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: EmptyState(
                icon: Icons.person_off,
                title: 'No Data',
                subtitle: 'There is no data to display',
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person_off), findsOneWidget);
      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('There is no data to display'), findsOneWidget);
    });

    testWidgets('AppSectionTitle should render with action', (tester) async {
      bool actionPressed = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppSectionTitle(
                title: 'Section Title',
                actionText: 'View All',
                onAction: () => actionPressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Section Title'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);

      await tester.tap(find.text('View All'));
      await tester.pump();

      expect(actionPressed, isTrue);
    });

    testWidgets('AppProgressBar should render progress', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppProgressBar(progress: 0.75),
            ),
          ),
        ),
      );

      final progressBar = tester.widget<Container>(find.byType(Container));
      expect(progressBar, isNotNull);
    });

    testWidgets('AppTimeline should render items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: AppTimeline(items: [
                AppTimelineItem.done('Completed Step'),
                AppTimelineItem.active('Current Step'),
                AppTimelineItem.pending('Pending Step'),
              ]),
            ),
          ),
        ),
      );

      expect(find.text('Completed Step'), findsOneWidget);
      expect(find.text('Current Step'), findsOneWidget);
      expect(find.text('Pending Step'), findsOneWidget);
    });
  });
}