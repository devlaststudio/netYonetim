import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AccountingDrawer extends StatelessWidget {
  final String currentRoute;

  const AccountingDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muhasebe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Finansal Yönetim',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    subtitle: 'Genel Bakış',
                    isSelected: currentRoute == '/accounting/dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        '/accounting/dashboard',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _DrawerItem(
                    icon: Icons.account_tree,
                    title: 'Hesap Planı',
                    subtitle: 'Hesap Yapısı',
                    isSelected: currentRoute == '/accounting/chart',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        '/accounting/chart',
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long,
                    title: 'Gelir & Gider',
                    subtitle: 'İşlem Kayıtları',
                    isSelected: currentRoute == '/accounting/income-expense',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        '/accounting/income-expense',
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.pie_chart,
                    title: 'Bütçe',
                    subtitle: 'Planlama & Takip',
                    isSelected: currentRoute == '/accounting/budget',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        '/accounting/budget',
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.assessment,
                    title: 'Raporlar',
                    subtitle: 'Mali Analiz',
                    isSelected: currentRoute == '/accounting/reports',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        '/accounting/reports',
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Ana Menüye Dön'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.7)
              : AppColors.textTertiary,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
