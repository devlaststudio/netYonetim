import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/app_provider.dart';
import '../../../data/mock/mock_data.dart';
import 'widgets/quick_transactions_panel.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final summary = MockData.getManagerDashboardSummary();
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return RefreshIndicator(
      onRefresh: () async {
        // Wrap local refresh in the existing void function if needed
        provider.refreshData();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          final mainContent = SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Main KPI Cards - Responsive
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;

                    final kpi1 = _KpiCard(
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.primary,
                      bgColor: AppColors.primary.withValues(alpha: 0.1),
                      title: 'Toplam Kasa',
                      value: currencyFormat.format(summary['totalCash']),
                    );
                    final kpi2 = _KpiCard(
                      icon: Icons.trending_up,
                      iconColor: AppColors.success,
                      bgColor: AppColors.success.withValues(alpha: 0.1),
                      title: 'Tahsilat Oranı',
                      value: '%${summary['collectionRate']}',
                    );
                    final kpi3 = _KpiCard(
                      icon: Icons.arrow_downward_rounded,
                      iconColor: AppColors.success,
                      bgColor: AppColors.success.withValues(alpha: 0.1),
                      title: 'Aylık Gelir',
                      value: currencyFormat.format(summary['monthlyIncome']),
                    );
                    final kpi4 = _KpiCard(
                      icon: Icons.arrow_upward_rounded,
                      iconColor: AppColors.error,
                      bgColor: AppColors.error.withValues(alpha: 0.1),
                      title: 'Aylık Gider',
                      value: currencyFormat.format(summary['monthlyExpense']),
                    );

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: kpi1),
                          const SizedBox(width: 12),
                          Expanded(child: kpi2),
                          const SizedBox(width: 12),
                          Expanded(child: kpi3),
                          const SizedBox(width: 12),
                          Expanded(child: kpi4),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: kpi1),
                              const SizedBox(width: 12),
                              Expanded(child: kpi2),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: kpi3),
                              const SizedBox(width: 12),
                              Expanded(child: kpi4),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Status Cards Row
                Row(
                  children: [
                    const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Site Durumu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatusTile(
                        icon: Icons.confirmation_number_outlined,
                        color: AppColors.warning,
                        value: '${summary['openTickets']}',
                        label: 'Açık Talep',
                      ),
                    ),
                    const SizedBox(width: 8),
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
                const SizedBox(height: 28),

                // Quick Actions
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      'Hızlı İşlemler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceAround,
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
                const SizedBox(height: 32),

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
                const SizedBox(height: 10),
                _UpcomingPaymentCard(
                  title: 'Asansör Bakım Ücreti',
                  dueDate: '20 Şub 2026',
                  amount: '₺8.750',
                  unitInfo: 'Genel Gider',
                  isUrgent: true,
                ),
                const SizedBox(height: 28),

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
                const SizedBox(height: 28),

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
                const SizedBox(height: 40),

                // If mobile, show QuickTransactionsPanel at the bottom
                if (!isWide) ...[
                  const Divider(height: 32),
                  const Text(
                    'Hızlı İşlemler Paneli',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height:
                        700, // Fixed height or physics to allow internal scroll
                    child: QuickTransactionsPanel(),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 65, child: mainContent),
                Container(
                  width: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                const Expanded(
                  flex: 35,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: QuickTransactionsPanel(),
                  ),
                ),
              ],
            );
          }

          return mainContent;
        },
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        leading: Container(
          width: 8,
          height: 48,
          decoration: BoxDecoration(
            color: announcement.priority.index == 2
                ? AppColors.error
                : announcement.priority.index == 1
                ? AppColors.warning
                : AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(
          announcement.title,
          style: TextStyle(
            fontWeight: announcement.isRead ? FontWeight.w500 : FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('dd MMM yyyy', 'tr_TR').format(announcement.publishDate),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
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
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${ticket.userName} • ${ticket.statusDisplayName}',
            style: TextStyle(
              color: statusColor.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            ticket.statusDisplayName,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUrgent
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUrgent ? Icons.schedule : Icons.receipt_long_outlined,
                color: isUrgent ? AppColors.warning : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Middle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: isUrgent
                            ? AppColors.warning
                            : AppColors.textSecondary,
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
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $unitInfo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
