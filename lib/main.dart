import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/providers/app_provider.dart';
import 'data/providers/accounting_provider.dart';
import 'data/providers/manager_finance_provider.dart';
import 'data/providers/manager_ops_provider.dart';
import 'data/providers/manager_reports_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/site_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dues/dues_screen.dart';
import 'screens/tickets/tickets_screen.dart';
import 'screens/announcements/announcements_screen.dart';
import 'screens/payments/payments_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/visitors/visitors_screen.dart';

import 'screens/more/reservation_screen.dart';
import 'screens/more/reports_screen.dart';
import 'screens/more/phonebook_screen.dart';

import 'screens/accounting/accounting_dashboard_screen.dart';
import 'screens/accounting/chart_of_accounts_screen.dart';
import 'screens/accounting/income_expense_screen.dart';
import 'screens/accounting/budget_screen.dart';
import 'screens/accounting/reports_screen.dart' as accounting_reports;
import 'screens/more/management_screen.dart';
import 'screens/more/staff_screen.dart';
import 'screens/more/polls_screen.dart';
import 'screens/more/service_records_screen.dart';

import 'screens/manager/finance/collections_center_screen.dart';
import 'screens/manager/finance/cash_expenses_screen.dart';
import 'screens/manager/finance/transfers_screen.dart';
import 'screens/manager/finance/bank_reconciliation_screen.dart';
import 'screens/manager/finance/accrual_movements_screen.dart';
import 'screens/manager/finance/cash_movements_screen.dart';
import 'screens/manager/finance/unit_statement_screen.dart';
import 'screens/manager/finance/vendor_statement_screen.dart';
import 'screens/manager/finance/charges_wizard_codex_screen.dart';
import 'screens/manager/reports/bulk_reports_screen.dart';
import 'screens/manager/ops/notifications_center_screen.dart';
import 'screens/manager/ops/site_settings_screen.dart';
import 'screens/manager/ops/staff_roles_screen.dart';
import 'screens/manager/ops/task_tracking_screen.dart';
import 'screens/manager/ops/decision_book_screen.dart';
import 'screens/manager/ops/file_archive_screen.dart';
import 'screens/manager/ops/meter_reading_screen.dart';
import 'screens/manager/ops/legacy_members_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Turkish locale
  await initializeDateFormatting('tr_TR', null);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SiteYonetApp());
}

class SiteYonetApp extends StatelessWidget {
  const SiteYonetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AccountingProvider()),
        ChangeNotifierProvider(create: (_) => ManagerFinanceProvider()),
        ChangeNotifierProvider(create: (_) => ManagerOpsProvider()),
        ChangeNotifierProvider(create: (_) => ManagerReportsProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'SiteYönet Pro',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: provider.isLoggedIn ? '/home' : '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/site-selection': (context) => const SiteSelectionScreen(),
              '/home': (context) => const HomeScreen(),
              '/dues': (context) => const DuesScreen(),
              '/tickets': (context) => const TicketsScreen(),
              '/announcements': (context) => const AnnouncementsScreen(),
              '/payments': (context) => const PaymentsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/visitors': (context) => const VisitorsScreen(),
              '/reservations': (context) => const ReservationScreen(),
              '/reports': (context) => const ReportsScreen(),
              '/phonebook': (context) => const PhonebookScreen(),
              '/management': (context) => const ManagementScreen(),
              '/staff': (context) => const StaffScreen(),
              '/polls': (context) => const PollsScreen(),
              '/service_records': (context) => const ServiceRecordsScreen(),
              // Accounting routes
              '/accounting/dashboard': (context) =>
                  const AccountingDashboardScreen(),
              '/accounting/chart': (context) => const ChartOfAccountsScreen(),
              '/accounting/income-expense': (context) =>
                  const IncomeExpenseScreen(),
              '/accounting/budget': (context) => const BudgetScreen(),
              '/accounting/reports': (context) =>
                  const accounting_reports.ReportsScreen(),

              // Manager module routes
              '/manager/collections': (context) =>
                  const CollectionsCenterScreen(),
              '/manager/cash-expenses': (context) => const CashExpensesScreen(),
              '/manager/transfers': (context) => const TransfersScreen(),
              '/manager/bank-reconciliation': (context) =>
                  const BankReconciliationScreen(),
              '/manager/accrual-movements': (context) =>
                  const AccrualMovementsScreen(),
              '/manager/cash-movements': (context) =>
                  const CashMovementsScreen(),
              '/manager/statement-unit': (context) =>
                  const UnitStatementScreen(),
              '/manager/statement-vendor': (context) =>
                  const VendorStatementScreen(),
              '/manager/charges-wizard-codex': (context) =>
                  const ChargesWizardCodexScreen(),
              '/manager/bulk-reports': (context) => const BulkReportsScreen(),
              '/manager/notifications': (context) =>
                  const NotificationsCenterScreen(),
              '/manager/site-settings': (context) => const SiteSettingsScreen(),
              '/manager/staff-roles': (context) => const StaffRolesScreen(),
              '/manager/task-tracking': (context) => const TaskTrackingScreen(),
              '/manager/decision-book': (context) => const DecisionBookScreen(),
              '/manager/file-archive': (context) => const FileArchiveScreen(),
              '/manager/meter-reading': (context) => const MeterReadingScreen(),
              '/manager/legacy-members': (context) =>
                  const LegacyMembersScreen(),
            },
            // Handle auth state changes
            onGenerateRoute: (settings) {
              // If not logged in, redirect to login
              if (!provider.isLoggedIn && settings.name != '/login') {
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              }
              if (provider.isLoggedIn &&
                  provider.needsSiteSelection &&
                  settings.name == '/home') {
                return MaterialPageRoute(
                  builder: (_) => const SiteSelectionScreen(),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
