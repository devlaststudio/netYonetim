import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/dashboard_embed_scope.dart';
import '../../../core/theme/app_theme.dart';

class ManagerPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;

  const ManagerPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    // Dashboard içine gömüldüğünde AppBar'ı gizle (header zaten mevcut)
    final isEmbedded = DashboardEmbedScope.hideBackButton(context);

    return Scaffold(
      appBar: isEmbedded ? null : AppBar(title: Text(title), actions: actions),
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      body: child,
    );
  }
}

class ManagerSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget trailing;

  const ManagerSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class ManagerKpiGrid extends StatelessWidget {
  final List<ManagerKpiItem> items;

  const ManagerKpiGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: item.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ManagerKpiItem {
  final String label;
  final String value;
  final Color color;

  const ManagerKpiItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class ManagerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ManagerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class ManagerStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const ManagerStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String formatCurrency(double value) {
  final formatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );
  return formatter.format(value);
}
