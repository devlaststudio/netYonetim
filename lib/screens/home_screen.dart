import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/app_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/manager_dashboard_screen.dart';
import '../screens/dues/dues_screen.dart';
import '../screens/tickets/tickets_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/accounting/accounting_dashboard_screen.dart';
import '../core/theme/app_theme.dart';
import 'more/more_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset index if switching roles and index is out of bounds
    final provider = context.read<AppProvider>();
    final maxIndex = provider.canAccessAccounting ? 3 : 4;
    if (_selectedIndex > maxIndex) {
      setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAdminOrManager = provider.canAccessAccounting;

    return Scaffold(
      body: _buildBody(isAdminOrManager),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: isAdminOrManager
              ? _buildAdminDestinations(provider)
              : _buildResidentDestinations(provider),
        ),
      ),
    );
  }

  // --- Admin / Manager: 4 tabs ---
  List<NavigationDestination> _buildAdminDestinations(AppProvider provider) {
    return [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Ana Sayfa',
      ),
      const NavigationDestination(
        icon: Icon(Icons.account_balance_outlined),
        selectedIcon: Icon(Icons.account_balance),
        label: 'Muhasebe',
      ),
      NavigationDestination(
        icon: Consumer<AppProvider>(
          builder: (context, provider, _) {
            if (provider.openTicketsCount > 0) {
              return Badge(
                label: Text('${provider.openTicketsCount}'),
                child: const Icon(Icons.confirmation_number_outlined),
              );
            }
            return const Icon(Icons.confirmation_number_outlined);
          },
        ),
        selectedIcon: const Icon(Icons.confirmation_number),
        label: 'Talepler',
      ),
      const NavigationDestination(
        icon: Icon(Icons.menu),
        selectedIcon: Icon(Icons.menu_open),
        label: 'Diğer',
      ),
    ];
  }

  // --- Resident / Tenant: 5 tabs (original) ---
  List<NavigationDestination> _buildResidentDestinations(AppProvider provider) {
    return [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Ana Sayfa',
      ),
      NavigationDestination(
        icon: Consumer<AppProvider>(
          builder: (context, provider, _) {
            if (provider.openDues.isNotEmpty) {
              return Badge(
                label: Text('${provider.openDues.length}'),
                child: const Icon(Icons.receipt_long_outlined),
              );
            }
            return const Icon(Icons.receipt_long_outlined);
          },
        ),
        selectedIcon: const Icon(Icons.receipt_long),
        label: 'Borçlar',
      ),
      NavigationDestination(
        icon: Consumer<AppProvider>(
          builder: (context, provider, _) {
            if (provider.openTicketsCount > 0) {
              return Badge(
                label: Text('${provider.openTicketsCount}'),
                child: const Icon(Icons.confirmation_number_outlined),
              );
            }
            return const Icon(Icons.confirmation_number_outlined);
          },
        ),
        selectedIcon: const Icon(Icons.confirmation_number),
        label: 'Talepler',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
      const NavigationDestination(
        icon: Icon(Icons.menu),
        selectedIcon: Icon(Icons.menu_open),
        label: 'Diğer',
      ),
    ];
  }

  Widget _buildBody(bool isAdminOrManager) {
    if (isAdminOrManager) {
      // Admin/Manager: Ana Sayfa, Muhasebe, Talepler, Diğer
      switch (_selectedIndex) {
        case 0:
          return const ManagerDashboardScreen();
        case 1:
          return const AccountingDashboardScreen();
        case 2:
          return const TicketsScreen();
        case 3:
          return const MoreScreen();
        default:
          return const ManagerDashboardScreen();
      }
    } else {
      // Resident: Ana Sayfa, Borçlar, Talepler, Profil, Diğer
      switch (_selectedIndex) {
        case 0:
          return const DashboardScreen();
        case 1:
          return const DuesScreen();
        case 2:
          return const TicketsScreen();
        case 3:
          return const ProfileScreen();
        case 4:
          return const MoreScreen();
        default:
          return const DashboardScreen();
      }
    }
  }
}
