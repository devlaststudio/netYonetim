import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/responsive_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class ScheduledChargesTrackingScreen extends StatefulWidget {
  const ScheduledChargesTrackingScreen({super.key});

  @override
  State<ScheduledChargesTrackingScreen> createState() =>
      _ScheduledChargesTrackingScreenState();
}

class _ScheduledChargesTrackingScreenState
    extends State<ScheduledChargesTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter state
  String _frequencyFilter = 'all'; // all, daily, weekly, monthly
  String _statusFilter = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final allRules = provider.autoChargeRules;
    final executionLogs = provider.executionLogs;

    return ManagerPageScaffold(
      title: 'Zamanlanmış Borçlandırma Takip',
      child: Column(
        children: [
          // KPI Summary
          _buildKpiSummary(allRules),

          // Tab Bar
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRulesTab(provider, allRules),
                _buildHistoryTab(executionLogs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── KPI Summary ────────────────────────────────────────────────────────────

  Widget _buildKpiSummary(List<AutoChargeRule> rules) {
    final activeCount = rules.where((r) => r.isActive).length;
    final totalAmount = rules
        .where((r) => r.isActive)
        .fold<double>(0, (sum, r) => sum + r.amount);
    final nextRun = rules.where((r) => r.isActive).isNotEmpty
        ? rules
              .where((r) => r.isActive)
              .map((r) => r.nextRunAt)
              .reduce((a, b) => a.isBefore(b) ? a : b)
        : null;
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildKpiChip(
              Icons.rule_outlined,
              '${rules.length}',
              'Kural',
              AppColors.primary,
            ),
            _kpiDivider(),
            _buildKpiChip(
              Icons.check_circle_outline_rounded,
              '$activeCount',
              'Aktif',
              AppColors.success,
            ),
            _kpiDivider(),
            _buildKpiChip(
              Icons.schedule_outlined,
              nextRun != null ? dateFormat.format(nextRun) : '—',
              'Sonraki',
              AppColors.info,
            ),
            _kpiDivider(),
            _buildKpiChip(
              Icons.account_balance_wallet_outlined,
              formatCurrency(totalAmount),
              'Toplam',
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiChip(IconData icon, String value, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiDivider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.border,
    );
  }

  // ─── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Aktif Kurallar'),
          Tab(text: 'Çalışma Geçmişi'),
        ],
      ),
    );
  }

  // ─── Rules Tab ──────────────────────────────────────────────────────────────

  Widget _buildRulesTab(
    ManagerFinanceProvider provider,
    List<AutoChargeRule> allRules,
  ) {
    // Apply filters
    var rules = allRules.where((rule) {
      if (_searchQuery.isNotEmpty &&
          !rule.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_frequencyFilter != 'all' &&
          rule.frequency.name != _frequencyFilter) {
        return false;
      }
      if (_statusFilter == 'active' && !rule.isActive) return false;
      if (_statusFilter == 'inactive' && rule.isActive) return false;
      return true;
    }).toList();

    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: rules.isEmpty
              ? const Center(
                  child: ManagerEmptyState(
                    icon: Icons.schedule_outlined,
                    title: 'Kural Bulunamadı',
                    subtitle:
                        'Arama kriterlerinize uygun zamanlanmış kural yok.',
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = !ResponsiveBreakpoints.isMobileWidth(
                      constraints.maxWidth,
                    );
                    if (isWide) {
                      return _buildRulesGrid(provider, rules);
                    }
                    return _buildRulesList(provider, rules);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Kural adına göre ara...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Tümü',
                  'all',
                  _statusFilter,
                  (v) => setState(() => _statusFilter = v),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'Aktif',
                  'active',
                  _statusFilter,
                  (v) => setState(() => _statusFilter = v),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'Pasif',
                  'inactive',
                  _statusFilter,
                  (v) => setState(() => _statusFilter = v),
                ),
                const SizedBox(width: 12),
                Container(width: 1, height: 24, color: AppColors.border),
                const SizedBox(width: 12),
                _buildFilterChip(
                  'Tüm Sıklık',
                  'all',
                  _frequencyFilter,
                  (v) => setState(() => _frequencyFilter = v),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'Günlük',
                  'daily',
                  _frequencyFilter,
                  (v) => setState(() => _frequencyFilter = v),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'Haftalık',
                  'weekly',
                  _frequencyFilter,
                  (v) => setState(() => _frequencyFilter = v),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'Aylık',
                  'monthly',
                  _frequencyFilter,
                  (v) => setState(() => _frequencyFilter = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    final isSelected = value == currentValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRulesGrid(
    ManagerFinanceProvider provider,
    List<AutoChargeRule> rules,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: rules.length,
      itemBuilder: (context, index) =>
          _buildRuleCard(context, provider, rules[index]),
    );
  }

  Widget _buildRulesList(
    ManagerFinanceProvider provider,
    List<AutoChargeRule> rules,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: rules.length,
      itemBuilder: (context, index) =>
          _buildRuleCard(context, provider, rules[index]),
    );
  }

  Widget _buildRuleCard(
    BuildContext context,
    ManagerFinanceProvider provider,
    AutoChargeRule rule,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rule.isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          InkWell(
            onTap: () => _showRuleDetail(context, rule),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: rule.isActive
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.textSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      rule.isActive
                          ? Icons.play_circle_fill_rounded
                          : Icons.pause_circle_outline_rounded,
                      color: rule.isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 22,
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
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            ManagerStatusChip(
                              label: rule.frequency.label,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 6),
                            ManagerStatusChip(
                              label: rule.scope.label,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: rule.isActive,
                    activeTrackColor: AppColors.primary,
                    onChanged: (value) {
                      provider.toggleAutoChargeRule(rule.id, value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          // Info row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoPill(
                    Icons.attach_money_rounded,
                    currencyFormat.format(rule.amount),
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoPill(
                    Icons.event_repeat_rounded,
                    dateFormat.format(rule.nextRunAt),
                    AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoPill(
                    Icons.calendar_today_rounded,
                    'Her ${rule.dueDay}.',
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          // Actions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: rule.isActive
                      ? () {
                          provider.runAutoChargeRuleNow(rule.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${rule.name} başarıyla çalıştırıldı.',
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text(
                    'Şimdi Çalıştır',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _confirmDeleteRule(context, provider, rule),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.error,
                  tooltip: 'Kuralı Sil',
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── History Tab ────────────────────────────────────────────────────────────

  Widget _buildHistoryTab(List<ScheduledChargeExecutionLog> logs) {
    if (logs.isEmpty) {
      return const Center(
        child: ManagerEmptyState(
          icon: Icons.history_outlined,
          title: 'Çalışma Geçmişi Bulunamadı',
          subtitle: 'Henüz zamanlanmış bir borçlandırma çalıştırılmadı.',
        ),
      );
    }

    // Sort by date descending
    final sortedLogs = List<ScheduledChargeExecutionLog>.from(logs)
      ..sort((a, b) => b.executedAt.compareTo(a.executedAt));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: sortedLogs.length,
      itemBuilder: (context, index) =>
          _buildHistoryCard(context, sortedLogs[index]),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    ScheduledChargeExecutionLog log,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: log.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                log.status == ScheduledExecutionStatus.success
                    ? Icons.check_circle_outline_rounded
                    : log.status == ScheduledExecutionStatus.failed
                    ? Icons.error_outline_rounded
                    : Icons.skip_next_rounded,
                color: log.status.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.ruleName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ManagerStatusChip(
                        label: log.status.label,
                        color: log.status.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildHistoryDetail(
                        Icons.access_time_rounded,
                        dateFormat.format(log.executedAt),
                      ),
                      _buildHistoryDetail(
                        Icons.date_range_rounded,
                        'Dönem: ${log.period}',
                      ),
                      if (log.status == ScheduledExecutionStatus.success) ...[
                        _buildHistoryDetail(
                          Icons.apartment_rounded,
                          '${log.unitCount} daire',
                        ),
                        _buildHistoryDetail(
                          Icons.attach_money_rounded,
                          currencyFormat.format(log.totalAmount),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Rule Detail Dialog ─────────────────────────────────────────────────────

  void _showRuleDetail(BuildContext context, AutoChargeRule rule) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          rule.isActive
                              ? Icons.play_circle_fill_rounded
                              : Icons.pause_circle_outline_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rule.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ManagerStatusChip(
                              label: rule.isActive ? 'Aktif' : 'Pasif',
                              color: rule.isActive
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Details grid
                  _buildDetailRow('Tutar', currencyFormat.format(rule.amount)),
                  _buildDetailRow('Sıklık', rule.frequency.label),
                  _buildDetailRow('Kapsam', rule.scope.label),
                  _buildDetailRow('Dağılım', rule.distributionType.label),
                  _buildDetailRow('Vade Günü', 'Her ayın ${rule.dueDay}. günü'),
                  _buildDetailRow(
                    'Sonraki Çalışma',
                    dateFormat.format(rule.nextRunAt),
                  ),
                  if (rule.lastRunAt != null)
                    _buildDetailRow(
                      'Son Çalışma',
                      dateFormat.format(rule.lastRunAt!),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Delete Confirmation ────────────────────────────────────────────────────

  void _confirmDeleteRule(
    BuildContext context,
    ManagerFinanceProvider provider,
    AutoChargeRule rule,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 10),
              Text('Kuralı Sil'),
            ],
          ),
          content: Text(
            '"${rule.name}" kuralını silmek istediğinize emin misiniz?\nBu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                provider.deleteAutoChargeRule(rule.id);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${rule.name} silindi.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}
