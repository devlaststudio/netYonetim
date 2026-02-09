import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';
import '../../data/mock/mock_data.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
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
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (provider.unreadAnnouncementsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${provider.unreadAnnouncementsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/announcements');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Hoş geldin, ${user?.firstName ?? "Kullanıcı"}! 👋',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${MockData.siteName} - ${user?.unitDisplay ?? ""}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.error,
                      title: 'BORÇ',
                      value: currencyFormat.format(provider.totalDebt),
                      subtitle: '${provider.openDues.length} adet bekleyen',
                      buttonText: 'ÖDE',
                      onButtonPressed: provider.openDues.isEmpty
                          ? null
                          : () => Navigator.of(context).pushNamed('/dues'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.check_circle,
                      iconColor: AppColors.success,
                      title: 'ÖDENDİ',
                      value: currencyFormat.format(provider.totalPaid),
                      subtitle: '${provider.paidDues.length} ödeme',
                      buttonText: 'Görüntüle',
                      onButtonPressed: () =>
                          Navigator.of(context).pushNamed('/payments'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Overdue warning
              if (provider.overdueDues.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${provider.overdueDues.length} Gecikmiş Borç',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gecikme tazminatı işlemektedir',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/dues'),
                        child: const Text('Öde'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Announcements section
              _SectionHeader(
                title: '📢 Son Duyurular',
                actionText: 'Tümü',
                onAction: () =>
                    Navigator.of(context).pushNamed('/announcements'),
              ),
              const SizedBox(height: 12),
              ...provider.announcements.take(2).map((announcement) {
                return _AnnouncementCard(
                  announcement: announcement,
                  onTap: () {
                    provider.markAnnouncementAsRead(announcement.id);
                    Navigator.of(context).pushNamed('/announcements');
                  },
                );
              }),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                '⚡ Hızlı İşlemler',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickActionButton(
                    icon: Icons.payment,
                    label: 'Öde',
                    onTap: () => Navigator.of(context).pushNamed('/dues'),
                  ),
                  _QuickActionButton(
                    icon: Icons.edit_note,
                    label: 'Talep',
                    onTap: () => Navigator.of(context).pushNamed('/tickets'),
                  ),
                  _QuickActionButton(
                    icon: Icons.person_add_alt_1,
                    label: 'Ziyaretçi',
                    onTap: () => Navigator.of(context).pushNamed('/visitors'),
                  ),
                  _QuickActionButton(
                    icon: Icons.how_to_vote,
                    label: 'Oyla',
                    onTap: () => Navigator.of(context).pushNamed('/polls'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent tickets
              if (provider.tickets.isNotEmpty) ...[
                _SectionHeader(
                  title: '📋 Son Talepler',
                  actionText: 'Tümü',
                  onAction: () => Navigator.of(context).pushNamed('/tickets'),
                ),
                const SizedBox(height: 12),
                ...provider.tickets.take(2).map((ticket) {
                  return _TicketCard(ticket: ticket);
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        TextButton(onPressed: onAction, child: Text(actionText)),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final dynamic announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: announcement.priority.index == 2
                ? AppColors.error
                : announcement.priority.index == 1
                ? AppColors.warning
                : AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          announcement.title,
          style: TextStyle(
            fontWeight: announcement.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat('dd MMM yyyy', 'tr_TR').format(announcement.publishDate),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final dynamic ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (ticket.status.index) {
      case 0:
        statusColor = AppColors.info;
        break;
      case 1:
        statusColor = AppColors.warning;
        break;
      case 2:
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              ticket.categoryDisplayName.substring(0, 2),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        title: Text(ticket.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${ticket.statusDisplayName} • ${DateFormat('dd MMM').format(ticket.createdAt)}',
          style: TextStyle(color: statusColor),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            ticket.statusDisplayName,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
