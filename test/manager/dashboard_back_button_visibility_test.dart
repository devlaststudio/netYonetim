import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:site_yonetimi_app/core/navigation/dashboard_embed_scope.dart';
import 'package:site_yonetimi_app/data/providers/app_provider.dart';
import 'package:site_yonetimi_app/data/providers/manager_ops_provider.dart';
import 'package:site_yonetimi_app/screens/dashboard/manager_dashboard_screen.dart';
import 'package:site_yonetimi_app/screens/manager/ops/notifications_center_screen.dart';
import 'package:site_yonetimi_app/screens/manager/ops/sms_notifications_screen.dart';

void main() {
  void setDesktopSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets(
      'Manager dashboard app bar hides back button even when route can pop',
      (tester) async {
    setDesktopSurface(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>(
        create: (_) => AppProvider(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ManagerDashboardScreen(),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final appBar = find.ancestor(
      of: find.text('Yönetim Paneli'),
      matching: find.byType(AppBar),
    );
    expect(appBar, findsOneWidget);
    expect(find.descendant(of: appBar, matching: find.byType(BackButton)),
        findsNothing);
  });

  testWidgets(
      'ManagerPageScaffold screen hides back button inside dashboard scope',
      (tester) async {
    setDesktopSurface(tester);
    final opsProvider = ManagerOpsProvider();
    await tester.runAsync(() async {
      await opsProvider.loadMockData();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ManagerOpsProvider>.value(
        value: opsProvider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DashboardEmbedScope(
                          hideAppBarBack: true,
                          child: NotificationsCenterScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final appBar = find.ancestor(
      of: find.text('Toplu Bildirim Merkezi'),
      matching: find.byType(AppBar),
    );
    expect(appBar, findsOneWidget);
    expect(find.descendant(of: appBar, matching: find.byType(BackButton)),
        findsNothing);
  });

  testWidgets(
      'ManagerPageScaffold screen keeps back button outside dashboard scope',
      (tester) async {
    setDesktopSurface(tester);
    final opsProvider = ManagerOpsProvider();
    await tester.runAsync(() async {
      await opsProvider.loadMockData();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ManagerOpsProvider>.value(
        value: opsProvider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationsCenterScreen(),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final appBar = find.ancestor(
      of: find.text('Toplu Bildirim Merkezi'),
      matching: find.byType(AppBar),
    );
    expect(appBar, findsOneWidget);
    expect(find.descendant(of: appBar, matching: find.byType(BackButton)),
        findsOneWidget);
  });

  testWidgets('Sms screen hides back button inside dashboard scope',
      (tester) async {
    setDesktopSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DashboardEmbedScope(
                        hideAppBarBack: true,
                        child: SmsNotificationsScreen(),
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final appBar = find.ancestor(
      of: find.text('Toplu İletişim (SMS/E-posta)'),
      matching: find.byType(AppBar),
    );
    expect(appBar, findsOneWidget);
    expect(find.descendant(of: appBar, matching: find.byType(BackButton)),
        findsNothing);
  });

  testWidgets('Sms screen keeps back button outside dashboard scope',
      (tester) async {
    setDesktopSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SmsNotificationsScreen(),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final appBar = find.ancestor(
      of: find.text('Toplu İletişim (SMS/E-posta)'),
      matching: find.byType(AppBar),
    );
    expect(appBar, findsOneWidget);
    expect(find.descendant(of: appBar, matching: find.byType(BackButton)),
        findsOneWidget);
  });
}
