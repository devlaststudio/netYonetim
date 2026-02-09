import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';
import '../../data/mock/mock_data.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1565C0), // Primary Dark
                  Color(0xFF1976D2), // Primary
                ],
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        user?.firstName.substring(0, 1) ?? 'K',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.firstName} ${user?.lastName}'.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${MockData.siteName} - ${user?.unitDisplay}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Settings Icon
                IconButton(
                  onPressed: () => Navigator.of(context).pushNamed('/profile'),
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _MenuItem(
                  icon: Icons.announcement_outlined,
                  title: 'Duyurular',
                  onTap: () =>
                      Navigator.of(context).pushNamed('/announcements'),
                ),
                _MenuItem(
                  icon: Icons.key,
                  title:
                      'Kira ve Borçlar', // Replaced "Kira" with "Kira ve Borçlar" to be more applicable
                  onTap: () => Navigator.of(context).pushNamed('/dues'),
                ),
                _MenuItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Rezervasyon',
                  onTap: () => Navigator.of(context).pushNamed('/reservations'),
                ),
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Raporlar',
                  onTap: () => Navigator.of(context).pushNamed('/reports'),
                ),
                // Muhasebe menu - only for Admin and Manager
                if (provider.canAccessAccounting)
                  _MenuItem(
                    icon: Icons.account_balance,
                    title: 'Muhasebe',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed('/accounting/dashboard'),
                  ),
                const Divider(),
                _MenuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Gönderi Takibi',
                  // No placeholder yet, reusing visitor logic conceptually or new screen later
                  // For now, let's point to Visitors as it handles packages often
                  onTap: () => Navigator.of(context).pushNamed('/visitors'),
                ),
                _MenuItem(
                  icon: Icons.phone_outlined,
                  title: 'Telefon Rehberi',
                  onTap: () => Navigator.of(context).pushNamed('/phonebook'),
                ),
                _MenuItem(
                  icon: Icons.people_outline,
                  title: 'Yönetim Kadrosu',
                  onTap: () => Navigator.of(context).pushNamed('/management'),
                ),
                _MenuItem(
                  icon: Icons.engineering_outlined,
                  title: 'Çalışan Kadrosu',
                  onTap: () => Navigator.of(context).pushNamed('/staff'),
                ),
                const Divider(),
                _MenuItem(
                  icon: Icons.poll_outlined,
                  title: 'Anket',
                  onTap: () => Navigator.of(context).pushNamed('/polls'),
                ),
                _MenuItem(
                  icon: Icons.person_add_outlined,
                  title: 'Ziyaretçi Kaydı',
                  onTap: () => Navigator.of(context).pushNamed('/visitors'),
                ),
                _MenuItem(
                  icon: Icons.directions_bus_outlined,
                  title: 'Servis Kaydı',
                  onTap: () =>
                      Navigator.of(context).pushNamed('/service_records'),
                ),
                _MenuItem(
                  icon: Icons.directions_car_outlined,
                  title: 'Araçlar',
                  // No placeholder yet, reusing Profile as it has vehicle info usually
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black26,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      dense: true,
      tileColor: Colors.white,
    );
  }
}
