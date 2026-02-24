import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:site_yonetimi_app/data/providers/manager_finance_provider.dart';
import 'package:site_yonetimi_app/data/providers/manager_ops_provider.dart';
import 'package:site_yonetimi_app/screens/manager/finance/scheduled_charges_tracking_screen.dart';
import 'package:site_yonetimi_app/screens/manager/finance/charges_wizard_codex_screen.dart';
import 'package:site_yonetimi_app/screens/manager/ops/legacy_members_screen.dart';
import 'package:site_yonetimi_app/screens/manager/ops/notifications_center_screen.dart';
import 'package:site_yonetimi_app/screens/manager/ops/site_settings_screen.dart';

void main() {
  testWidgets('Scheduled charges tracking screen renders KPI and tabs', (
    WidgetTester tester,
  ) async {
    final financeProvider = ManagerFinanceProvider();
    await tester.runAsync(() async {
      await financeProvider.loadMockData();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ManagerFinanceProvider>.value(
        value: financeProvider,
        child: const MaterialApp(home: ScheduledChargesTrackingScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Aktif Kurallar'), findsOneWidget);
    expect(find.text('Çalışma Geçmişi'), findsOneWidget);
  });

  testWidgets('Charges wizard codex renders method controls at top', (
    WidgetTester tester,
  ) async {
    final financeProvider = ManagerFinanceProvider();
    await tester.runAsync(() async {
      await financeProvider.loadMockData();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ManagerFinanceProvider>.value(
        value: financeProvider,
        child: const MaterialApp(home: ChargesWizardCodexScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Borclandirma Yontemi'), findsOneWidget);
    expect(find.text('Aidat Grubu'), findsWidgets);
    expect(find.text('Borclandirma Olustur'), findsOneWidget);
  });

  testWidgets('Notifications screen renders auto notification rules', (
    WidgetTester tester,
  ) async {
    final opsProvider = ManagerOpsProvider();
    await tester.runAsync(() async {
      await opsProvider.loadMockData();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ManagerOpsProvider>.value(
        value: opsProvider,
        child: const MaterialApp(home: NotificationsCenterScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Otomatik Bildirim Kurallari'), findsOneWidget);
    expect(find.text('Aidat Vade Hatirlatma'), findsOneWidget);
  });

  testWidgets(
    'Site settings import preview supports row edit and revalidation',
    (WidgetTester tester) async {
      final opsProvider = ManagerOpsProvider();
      await tester.runAsync(() async {
        await opsProvider.loadMockData();
        await opsProvider.prepareImportPreview(sourceName: 'test.xlsx');
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<ManagerOpsProvider>.value(
          value: opsProvider,
          child: const MaterialApp(
            routes: {'/manager/legacy-members': _legacyMembersRoute},
            home: SiteSettingsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Aktarimi Tamamla'), findsOneWidget);
      expect(find.text('Yeniden Kontrol Et'), findsOneWidget);
      expect(find.byTooltip('Satiri Duzenle'), findsWidgets);
    },
  );

  testWidgets('Legacy members screen lists former member records', (
    WidgetTester tester,
  ) async {
    final opsProvider = ManagerOpsProvider();
    await tester.runAsync(() async {
      await opsProvider.loadMockData();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ManagerOpsProvider>.value(
        value: opsProvider,
        child: const MaterialApp(home: LegacyMembersScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Sahin Ucar'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('Eski Uye Gorunumu'), findsOneWidget);
    expect(find.text('Sahin Ucar'), findsOneWidget);
  });
}

Widget _legacyMembersRoute(BuildContext context) {
  return const LegacyMembersScreen();
}
