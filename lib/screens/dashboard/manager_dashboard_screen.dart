import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';
import '../../data/mock/mock_data.dart';
import 'package:intl/intl.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final summary = MockData.getManagerDashboardSummary();
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
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Yönetim Paneli'),
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
              // Welcome section + Staff contacts
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Welcome text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoş geldin, ${user?.firstName ?? "Yönetici"}! 👋',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: provider.managedSites.length > 1
                              ? () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/site-selection');
                                }
                              : null,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_city,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  provider.selectedSiteName,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (provider.managedSites.length > 1) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.swap_horiz,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                              const SizedBox(width: 6),
                              Text(
                                '• ${user?.roleDisplayName ?? ""}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right: Mini staff contacts
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _MiniStaffChip(
                        role: 'Görevli',
                        name: 'Ali Demir',
                        phone: '0532 111 22 33',
                        icon: Icons.engineering,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 6),
                      _MiniStaffChip(
                        role: 'Güvenlik',
                        name: 'Hasan Kara',
                        phone: '0533 444 55 66',
                        icon: Icons.shield_outlined,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.primary,
                      bgColor: AppColors.primary.withValues(alpha: 0.1),
                      title: 'Toplam Kasa',
                      value: currencyFormat.format(summary['totalCash']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.trending_up,
                      iconColor: AppColors.success,
                      bgColor: AppColors.success.withValues(alpha: 0.1),
                      title: 'Tahsilat Oranı',
                      value: '%${summary['collectionRate']}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Income / Expense cards
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.arrow_downward_rounded,
                      iconColor: AppColors.success,
                      bgColor: AppColors.success.withValues(alpha: 0.1),
                      title: 'Aylık Gelir',
                      value: currencyFormat.format(summary['monthlyIncome']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.arrow_upward_rounded,
                      iconColor: AppColors.error,
                      bgColor: AppColors.error.withValues(alpha: 0.1),
                      title: 'Aylık Gider',
                      value: currencyFormat.format(summary['monthlyExpense']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status Cards Row
              Text(
                '📊 Site Durumu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusTile(
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                      value: '${summary['overdueUnits']}',
                      label: 'Gecikmiş Daire',
                    ),
                  ),
                  Expanded(
                    child: _StatusTile(
                      icon: Icons.confirmation_number_outlined,
                      color: AppColors.warning,
                      value: '${summary['openTickets']}',
                      label: 'Açık Talep',
                    ),
                  ),
                  Expanded(
                    child: _StatusTile(
                      icon: Icons.home_outlined,
                      color: AppColors.success,
                      value:
                          '${summary['occupiedUnits']}/${summary['totalUnits']}',
                      label: 'Dolu Daire',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                '⚡ Hızlı İşlemler',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickActionButton(
                    icon: Icons.account_balance,
                    label: 'Muhasebe',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed('/accounting/dashboard'),
                  ),
                  _QuickActionButton(
                    icon: Icons.edit_note,
                    label: 'Talepler',
                    onTap: () => Navigator.of(context).pushNamed('/tickets'),
                  ),
                  _QuickActionButton(
                    icon: Icons.campaign,
                    label: 'Duyuru',
                    onTap: () =>
                        Navigator.of(context).pushNamed('/announcements'),
                  ),
                  _QuickActionButton(
                    icon: Icons.poll,
                    label: 'Anket',
                    onTap: () => Navigator.of(context).pushNamed('/polls'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Yaklaşan Ödemeler
              _SectionHeader(
                title: '💰 Yaklaşan Ödemeler',
                actionText: 'Tümü',
                onAction: () => Navigator.of(context).pushNamed('/dues'),
              ),
              const SizedBox(height: 12),
              _UpcomingPaymentCard(
                title: 'Şubat 2026 Aidat',
                dueDate: '15 Şub 2026',
                amount: '₺2.500',
                unitInfo: 'A Blok - 12 Daire',
                isUrgent: false,
              ),
              const SizedBox(height: 8),
              _UpcomingPaymentCard(
                title: 'Asansör Bakım Ücreti',
                dueDate: '20 Şub 2026',
                amount: '₺8.750',
                unitInfo: 'Genel Gider',
                isUrgent: true,
              ),
              const SizedBox(height: 24),

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

              // Recent tickets
              if (provider.tickets.isNotEmpty) ...[
                _SectionHeader(
                  title: '📋 Son Talepler',
                  actionText: 'Tümü',
                  onAction: () => Navigator.of(context).pushNamed('/tickets'),
                ),
                const SizedBox(height: 12),
                ...provider.tickets.take(3).map((ticket) {
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

// --- Widget Components ---

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String value;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatusTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
          '${ticket.userName} • ${ticket.statusDisplayName}',
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

class _MiniStaffChip extends StatelessWidget {
  final String role;
  final String name;
  final String phone;
  final IconData icon;
  final Color color;

  const _MiniStaffChip({
    required this.role,
    required this.name,
    required this.phone,
    required this.icon,
    required this.color,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$role: $name',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _makePhoneCall(phone),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.phone, size: 12, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingPaymentCard extends StatelessWidget {
  final String title;
  final String dueDate;
  final String amount;
  final String unitInfo;
  final bool isUrgent;

  const _UpcomingPaymentCard({
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.unitInfo,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUrgent
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Left icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isUrgent
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUrgent ? Icons.schedule : Icons.receipt_long_outlined,
                color: isUrgent ? AppColors.warning : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Middle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dueDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: isUrgent
                              ? AppColors.warning
                              : AppColors.textSecondary,
                          fontWeight: isUrgent
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $unitInfo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right amount
            Text(
              amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isUrgent ? AppColors.warning : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
