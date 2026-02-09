import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/accounting_provider.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/accounting_entry_model.dart';
import '../../../widgets/accounting/accounting_drawer.dart';

class ChartOfAccountsScreen extends StatelessWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Planı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAccountDialog(context),
          ),
        ],
      ),
      drawer: const AccountingDrawer(currentRoute: '/accounting/chart'),
      backgroundColor: AppColors.background,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAccountTree(provider),
    );
  }

  Widget _buildAccountTree(AccountingProvider provider) {
    final parentAccounts = provider.parentAccounts;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: parentAccounts.length,
      itemBuilder: (context, index) {
        final account = parentAccounts[index];
        return _buildAccountNode(context, provider, account);
      },
    );
  }

  Widget _buildAccountNode(
    BuildContext context,
    AccountingProvider provider,
    AccountModel account, {
    int level = 0,
  }) {
    final children = provider.getChildAccounts(account.id);
    final hasChildren = children.isNotEmpty;
    final isIncome = account.type == AccountType.income;

    return Card(
      margin: EdgeInsets.only(left: level * 16.0, bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: level == 0 ? AppColors.primary : AppColors.border,
          width: level == 0 ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          title: Text(
            '${account.code} - ${account.name}',
            style: TextStyle(
              fontSize: level == 0 ? 16 : 15,
              fontWeight: level == 0 ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: account.hasBalance
              ? Text(
                  'Bakiye: ${_formatCurrency(account.balance)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: account.balance >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
          trailing: hasChildren
              ? null
              : PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditAccountDialog(context, account);
                    } else if (value == 'view') {
                      _showAccountDetail(context, provider, account);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('Detay Görüntüle'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                  ],
                ),
          initiallyExpanded: level < 2,
          children: children
              .map(
                (child) => _buildAccountNode(
                  context,
                  provider,
                  child,
                  level: level + 1,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Hesap'),
        content: const Text('Hesap ekleme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDialog(BuildContext context, AccountModel account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Düzenle'),
        content: Text('${account.code} - ${account.name} düzenleniyor...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _showAccountDetail(
    BuildContext context,
    AccountingProvider provider,
    AccountModel account,
  ) {
    final entries = provider.getEntriesForAccount(account.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          account.code,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bakiye:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatCurrency(account.balance),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: account.balance >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'İşlemler (${entries.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: entries.isEmpty
                    ? const Center(child: Text('Bu hesapta işlem bulunmuyor.'))
                    : ListView.builder(
                        controller: controller,
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return ListTile(
                            title: Text(entry.description),
                            subtitle: Text(entry.transactionDate.toString()),
                            trailing: Text(
                              _formatCurrency(entry.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: entry.entryType == EntryType.income
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '₺${amount.toStringAsFixed(2)}';
  }
}
