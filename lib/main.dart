import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/providers/app_provider.dart';
import 'data/providers/accounting_provider.dart';
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
      ],
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'SiteYönet Pro',
            debugShowCheckedModeBanner: false,
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
