import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.transfers.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return ManagerPageScaffold(
      title: 'Virman / Transfer',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Transfer Ekle'),
      ),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Hesap Bakiyeleri',
                  child: Column(
                    children: provider.accountBalances.entries
                        .map(
                          (entry) => ListTile(
                            dense: true,
                            title: Text(
                              ManagerFinanceMockData.accounts.firstWhere(
                                    (account) => account['id'] == entry.key,
                                    orElse: () => {'name': entry.key},
                                  )['name'] ??
                                  entry.key,
                            ),
                            trailing: Text(
                              formatCurrency(entry.value),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (provider.transfers.isEmpty)
                  const SizedBox(
                    height: 220,
                    child: ManagerEmptyState(
                      icon: Icons.sync_alt,
                      title: 'Transfer kaydi yok',
                      subtitle: 'Hesaplar arasi virman olusturabilirsiniz.',
                    ),
                  )
                else
                  ...provider.transfers.map(
                    (transfer) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor:
                              transfer.status == TransferStatus.completed
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : AppColors.error.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.swap_horiz,
                            color: transfer.status == TransferStatus.completed
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        title: Text(
                            '${transfer.fromAccountName} → ${transfer.toAccountName}'),
                        subtitle: Text(
                          '${dateFormat.format(transfer.transferDate)} • ${transfer.description}',
                        ),
                        trailing: Text(
                          formatCurrency(transfer.amount),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final amountController = TextEditingController(text: '1500');
    final descriptionController = TextEditingController(text: 'Kasa virmani');

    Map<String, String> fromAccount = ManagerFinanceMockData.accounts.first;
    Map<String, String> toAccount = ManagerFinanceMockData.accounts[1];

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Yeni Transfer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Map<String, String>>(
                      initialValue: fromAccount,
                      decoration:
                          const InputDecoration(labelText: 'Cikan Hesap'),
                      items: ManagerFinanceMockData.accounts
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item['name']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => fromAccount = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Map<String, String>>(
                      initialValue: toAccount,
                      decoration:
                          const InputDecoration(labelText: 'Giren Hesap'),
                      items: ManagerFinanceMockData.accounts
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item['name']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => toAccount = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Tutar'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Aciklama'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Vazgec'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      return;
                    }
                    if (fromAccount['id'] == toAccount['id']) {
                      return;
                    }

                    final success = await context
                        .read<ManagerFinanceProvider>()
                        .createTransfer(
                          fromAccountId: fromAccount['id']!,
                          fromAccountName: fromAccount['name']!,
                          toAccountId: toAccount['id']!,
                          toAccountName: toAccount['name']!,
                          amount: amount,
                          description: descriptionController.text,
                        );

                    if (!context.mounted) {
                      return;
                    }

                    if (success) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yetersiz bakiye')),
                      );
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
