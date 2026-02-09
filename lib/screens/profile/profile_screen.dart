import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';
import '../../data/mock/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Kullanıcı',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        user?.roleDisplayName ?? '',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MockData.siteName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      user?.unitDisplay ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact info
            Card(
              child: Column(
                children: [
                  _ProfileListTile(
                    icon: Icons.email_outlined,
                    title: 'E-posta',
                    subtitle: user?.email ?? '',
                  ),
                  const Divider(height: 1),
                  _ProfileListTile(
                    icon: Icons.phone_outlined,
                    title: 'Telefon',
                    subtitle: user?.phone ?? '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Menu items
            Card(
              child: Column(
                children: [
                  _MenuListTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Borç Özeti',
                    onTap: () => Navigator.of(context).pushNamed('/dues'),
                  ),
                  const Divider(height: 1),
                  _MenuListTile(
                    icon: Icons.history,
                    title: 'Ödeme Geçmişi',
                    onTap: () => Navigator.of(context).pushNamed('/payments'),
                  ),
                  const Divider(height: 1),
                  _MenuListTile(
                    icon: Icons.edit_note,
                    title: 'Taleplerim',
                    onTap: () => Navigator.of(context).pushNamed('/tickets'),
                  ),
                  const Divider(height: 1),
                  _MenuListTile(
                    icon: Icons.campaign_outlined,
                    title: 'Duyurular',
                    badge: provider.unreadAnnouncementsCount > 0
                        ? provider.unreadAnnouncementsCount.toString()
                        : null,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/announcements'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick actions
            Card(
              child: Column(
                children: [
                  _MenuListTile(
                    icon: Icons.description_outlined,
                    title: 'Belgelerim',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yakında eklenecek')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _MenuListTile(
                    icon: Icons.local_parking_outlined,
                    title: 'Araç Bilgilerim',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yakında eklenecek')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _MenuListTile(
                    icon: Icons.groups_outlined,
                    title: 'Aile Üyeleri',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yakında eklenecek')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Support
            Card(
              child: Column(
                children: [
                  _MenuListTile(
                    icon: Icons.help_outline,
                    title: 'Yardım ve Destek',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Destek ekibiyle iletişime geçiliyor...',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _MenuListTile(
                    icon: Icons.info_outline,
                    title: 'Hakkında',
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Version
            Text(
              'SiteYönet Pro v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Ayarlar', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Bildirimler'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? 'Bildirimler açıldı' : 'Bildirimler kapatıldı',
                      ),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Karanlık Mod'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tema ayarları yakında')),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Dil'),
              trailing: const Text('Türkçe'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Şifre Değiştir'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Şifre değiştirme yakında')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('SiteYönet Pro'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versiyon: 1.0.0 (Demo)'),
            SizedBox(height: 8),
            Text('Site yönetiminde yeni nesil çözüm.'),
            SizedBox(height: 16),
            Text('© 2026 SiteYönet Pro'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppProvider>().logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _MenuListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final VoidCallback onTap;

  const _MenuListTile({
    required this.icon,
    required this.title,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
      onTap: onTap,
    );
  }
}
