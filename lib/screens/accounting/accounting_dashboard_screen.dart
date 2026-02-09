import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/accounting_provider.dart';
import '../../../data/providers/app_provider.dart';
import '../../../widgets/accounting/accounting_drawer.dart';
import '../../../widgets/accounting/summary_card_widget.dart';
import '../../../widgets/accounting/transaction_list_widget.dart';

class AccountingDashboardScreen extends StatefulWidget {
  final bool embedded;
  const AccountingDashboardScreen({super.key, this.embedded = false});

  @override
  State<AccountingDashboardScreen> createState() =>
      _AccountingDashboardScreenState();
}

class _AccountingDashboardScreenState extends State<AccountingDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load accounting data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountingProvider>().loadAccountingData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final accountingProvider = context.watch<AccountingProvider>();

    // Check access permission
    if (!appProvider.canAccessAccounting) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yetki Hatası')),
        body: const Center(child: Text('Bu modüle erişim yetkiniz yok.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Muhasebe Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => accountingProvider.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      drawer: widget.embedded
          ? null
          : const AccountingDrawer(currentRoute: '/accounting/dashboard'),
      backgroundColor: AppColors.background,
      body: accountingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => accountingProvider.refreshData(),
              child: _buildDashboardContent(accountingProvider),
            ),
    );
  }

  Widget _buildDashboardContent(AccountingProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          const Text(
            'Finansal Özet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCards(provider),
          const SizedBox(height: 24),

          // Budget Overview (if active budget exists)
          if (provider.budgets.isNotEmpty) ...[
            _buildBudgetOverview(provider),
            const SizedBox(height: 24),
          ],

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Son İşlemler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/accounting/income-expense');
                },
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentTransactions(provider),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AccountingProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: SummaryCardWidget(
                  icon: Icons.trending_up,
                  iconColor: AppColors.success,
                  title: 'Toplam Gelir',
                  amount: formatCurrency(provider.totalIncome),
                  subtitle: '${provider.incomeEntries.length} işlem',
                  trend: 12.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCardWidget(
                  icon: Icons.trending_down,
                  iconColor: AppColors.error,
                  title: 'Toplam Gider',
                  amount: formatCurrency(provider.totalExpense),
                  subtitle: '${provider.expenseEntries.length} işlem',
                  trend: -5.2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCardWidget(
                  icon: Icons.account_balance_wallet,
                  iconColor: provider.netIncome >= 0
                      ? AppColors.primary
                      : AppColors.warning,
                  title: 'Net Gelir',
                  amount: formatCurrency(provider.netIncome),
                  subtitle: provider.netIncome >= 0 ? 'Faz la' : 'Eksik',
                  trend: provider.netIncome >= 0 ? 8.3 : -8.3,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              SummaryCardWidget(
                icon: Icons.trending_up,
                iconColor: AppColors.success,
                title: 'Toplam Gelir',
                amount: formatCurrency(provider.totalIncome),
                subtitle: '${provider.incomeEntries.length} işlem',
                trend: 12.5,
              ),
              const SizedBox(height: 12),
              SummaryCardWidget(
                icon: Icons.trending_down,
                iconColor: AppColors.error,
                title: 'Toplam Gider',
                amount: formatCurrency(provider.totalExpense),
                subtitle: '${provider.expenseEntries.length} işlem',
                trend: -5.2,
              ),
              const SizedBox(height: 12),
              SummaryCardWidget(
                icon: Icons.account_balance_wallet,
                iconColor: provider.netIncome >= 0
                    ? AppColors.primary
                    : AppColors.warning,
                title: 'Net Gelir',
                amount: formatCurrency(provider.netIncome),
                subtitle: provider.netIncome >= 0 ? 'Fazla' : 'Eksik',
                trend: provider.netIncome >= 0 ? 8.3 : -8.3,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildBudgetOverview(AccountingProvider provider) {
    final budget = provider.budgets.first;
    final realizationPercent = budget.realizationPercentage;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bütçe Gerçekleşme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/accounting/budget');
                  },
                  child: const Text('Detay'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: realizationPercent / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                realizationPercent > 100
                    ? AppColors.warning
                    : realizationPercent > 80
                    ? AppColors.success
                    : AppColors.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Planlanan',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatCurrency(budget.totalPlanned),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Gerçekleşen',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatCurrency(budget.totalActual),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '%${realizationPercent.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(AccountingProvider provider) {
    final recentEntries = provider.entries.take(10).toList();

    return SizedBox(
      height: 400,
      child: TransactionListWidget(
        entries: recentEntries,
        showGrouping: false,
        onTap: (entry) {
          // Handle tap
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Implement filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: const Text('Filtreleme seçenekleri yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
