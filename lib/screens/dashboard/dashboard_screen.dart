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
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            titleSpacing: 24,
            leading: null,
            automaticallyImplyLeading: false, // Hide back button if any
            title: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user?.firstName.substring(0, 1) ?? 'K',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hoş Geldiniz,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${user?.firstName} ${user?.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    if (provider.unreadAnnouncementsCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed('/announcements'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Blue background extension behind the card
                Container(
                  height: 100, // Extends the blue area down
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Content: Site Info + Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Site Info Text inside the blue area
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24, left: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.apartment_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${MockData.siteName}, ${user?.unitDisplay ?? ""}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Debt Summary Card (Overlaps the bottom of blue area)
                      _DebtSummaryCard(
                        totalDebt: provider.totalDebt,
                        currencyFormat: currencyFormat,
                        onPayNow: () =>
                            Navigator.of(context).pushNamed('/dues'),
                        onHistory: () =>
                            Navigator.of(context).pushNamed('/payments'),
                      ),

                      const SizedBox(height: 24),

                      // Quick Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _QuickActionItem(
                            icon: Icons.build_rounded,
                            label: 'Talep',
                            color: Colors.orange.shade100,
                            iconColor: Colors.deepOrange,
                            onTap: () =>
                                Navigator.of(context).pushNamed('/tickets'),
                          ),
                          _QuickActionItem(
                            icon: Icons.poll_rounded,
                            label: 'Anket',
                            color: Colors.purple.shade100,
                            iconColor: Colors.purple,
                            onTap: () =>
                                Navigator.of(context).pushNamed('/polls'),
                          ),
                          _QuickActionItem(
                            icon: Icons.calendar_today_rounded,
                            label: 'Rezerve',
                            color: Colors.teal.shade100,
                            iconColor: Colors.teal,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed('/reservations'),
                          ),
                          _QuickActionItem(
                            icon: Icons.description_rounded,
                            label: 'Raporlar',
                            color: Colors.blue.shade100,
                            iconColor: Colors.blue.shade800,
                            onTap: () =>
                                Navigator.of(context).pushNamed('/reports'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Overdue Warning
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Gecikme tazminatı işlemektedir',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
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

                      // Announcements
                      Column(
                        children: [
                          _SectionHeader(
                            title: 'Duyurular',
                            actionText: 'Tümü',
                            onAction: () => Navigator.of(
                              context,
                            ).pushNamed('/announcements'),
                          ),
                          const SizedBox(height: 12),
                          if (provider.announcements.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Henüz duyuru bulunmamaktadır.'),
                              ),
                            )
                          else
                            ...provider.announcements.take(2).map((
                              announcement,
                            ) {
                              return _AnnouncementCard(
                                announcement: announcement,
                                onTap: () {
                                  provider.markAnnouncementAsRead(
                                    announcement.id,
                                  );
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/announcements');
                                },
                              );
                            }),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Recent Tickets Section
                      if (provider.tickets.isNotEmpty) ...[
                        Column(
                          children: [
                            _SectionHeader(
                              title: 'Son Talepler',
                              actionText: 'Tümü',
                              onAction: () =>
                                  Navigator.of(context).pushNamed('/tickets'),
                            ),
                            const SizedBox(height: 12),
                            ...provider.tickets.take(2).map((ticket) {
                              return _TicketCard(ticket: ticket);
                            }),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  final double totalDebt;
  final NumberFormat currencyFormat;
  final VoidCallback onPayNow;
  final VoidCallback onHistory;

  const _DebtSummaryCard({
    required this.totalDebt,
    required this.currencyFormat,
    required this.onPayNow,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam Borç',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalDebt),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800, // Extra bold
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Placeholder for due date, assuming static or from first due
          Text(
            'Son ödeme tarihi: 25 Şub 2026', // Ideally dynamic
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hemen Öde',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onHistory,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20), // Circular feel
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3), // Lighter background
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: announcement.priority.index == 2
                ? AppColors.error.withValues(alpha: 0.1)
                : announcement.priority.index == 1
                ? AppColors.warning.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.campaign_outlined,
            color: announcement.priority.index == 2
                ? AppColors.error
                : announcement.priority.index == 1
                ? AppColors.warning
                : AppColors.primary,
          ),
        ),
        title: Text(
          announcement.title,
          style: TextStyle(
            fontWeight: announcement.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('dd MMM yyyy', 'tr_TR').format(announcement.publishDate),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              ticket.categoryDisplayName.substring(0, 2),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ),
        title: Text(
          ticket.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${ticket.statusDisplayName} • ${DateFormat('dd MMM').format(ticket.createdAt)}',
            style: TextStyle(color: statusColor, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
