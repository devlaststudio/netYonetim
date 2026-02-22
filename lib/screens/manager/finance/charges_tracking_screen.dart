import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class ChargesTrackingScreen extends StatefulWidget {
  const ChargesTrackingScreen({super.key});

  @override
  State<ChargesTrackingScreen> createState() => _ChargesTrackingScreenState();
}

class _ChargesTrackingScreenState extends State<ChargesTrackingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final rules = provider.autoChargeRules.where((rule) {
      return rule.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borclandirma Takip'),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh or information can be added here
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(provider.autoChargeRules.length),
          _buildSearchAndFilters(),
          Expanded(
            child: rules.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: rules.length,
                    itemBuilder: (context, index) {
                      return _buildRuleCard(context, rules[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalRules) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zamanlanmis Islemler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toplam $totalRules aktif tanimlama bulunuyor',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Islem adina gore ara...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: ManagerEmptyState(
        icon: Icons.schedule_outlined,
        title: 'Kayitli Islem Bulunmadi',
        subtitle: 'Zamanlanmis tum borclandirma islemleri burada gorunur.',
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, AutoChargeRule rule) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rule.isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: rule.isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    rule.isActive
                        ? Icons.play_circle_fill
                        : Icons.schedule_outlined,
                    color: rule.isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${rule.frequency.label} • ${rule.scope.label}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: rule.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    context.read<ManagerFinanceProvider>().toggleAutoChargeRule(
                      rule.id,
                      value,
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoBit(
                  'Tutar',
                  currencyFormat.format(rule.amount),
                  AppColors.primary,
                ),
                _buildInfoBit(
                  'Sonraki Calisma',
                  dateFormat.format(rule.nextRunAt),
                  AppColors.info,
                ),
                _buildInfoBit(
                  'Vade Gunu',
                  'Her ayin ${rule.dueDay}. gunu',
                  AppColors.warning,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: rule.isActive
                      ? () => context
                            .read<ManagerFinanceProvider>()
                            .runAutoChargeRuleNow(rule.id)
                      : null,
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  label: const Text('Simdi Calistir'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Delete logic can be added to provider
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Silme islemi simule edildi.'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  tooltip: 'Sil',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBit(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
