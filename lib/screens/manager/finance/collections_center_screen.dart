import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class CollectionsCenterScreen extends StatefulWidget {
  const CollectionsCenterScreen({super.key});

  @override
  State<CollectionsCenterScreen> createState() =>
      _CollectionsCenterScreenState();
}

class _CollectionsCenterScreenState extends State<CollectionsCenterScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.collections.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return ManagerPageScaffold(
      title: 'Tahsilat Merkezi',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCollectionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tahsilat Ekle'),
      ),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Tahsilat Ozet',
                  child: ManagerKpiGrid(
                    items: [
                      ManagerKpiItem(
                        label: 'Toplam Tahsilat',
                        value: formatCurrency(provider.totalCollectionAmount),
                        color: AppColors.success,
                      ),
                      ManagerKpiItem(
                        label: 'Islem Sayisi',
                        value: '${provider.collections.length}',
                        color: AppColors.primary,
                      ),
                      ManagerKpiItem(
                        label: 'Onayli',
                        value:
                            '${provider.collections.where((e) => e.status == CollectionStatus.approved).length}',
                        color: AppColors.info,
                      ),
                      ManagerKpiItem(
                        label: 'Iptal',
                        value:
                            '${provider.collections.where((e) => e.status == CollectionStatus.cancelled).length}',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
                if (provider.collections.isEmpty)
                  const SizedBox(
                    height: 300,
                    child: ManagerEmptyState(
                      icon: Icons.payments_outlined,
                      title: 'Tahsilat kaydi yok',
                      subtitle: 'Ilk tahsilat kaydini ekleyebilirsiniz.',
                    ),
                  )
                else
                  ...provider.collections.map(
                    (record) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.success.withValues(alpha: 0.12),
                          child: const Icon(Icons.payments,
                              color: AppColors.success),
                        ),
                        title: Text(record.payerName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${record.cashAccountName} • ${record.allocationMode.label}',
                            ),
                            Text(
                              '${dateFormat.format(record.collectionDate)} • Makbuz: ${record.receiptNo}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Text(
                          formatCurrency(record.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        onTap: () => _showCollectionDetail(context, record),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showCollectionDetail(BuildContext context, CollectionRecord record) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.payerName,
                    style: Theme.of(context).textTheme.titleLarge),
                Text('Makbuz: ${record.receiptNo}'),
                const SizedBox(height: 8),
                ...record.allocations.map(
                  (line) => ListTile(
                    dense: true,
                    title: Text('Borc ID: ${line.dueId}'),
                    subtitle:
                        Text('Kalan: ${formatCurrency(line.remainingAfter)}'),
                    trailing: Text(formatCurrency(line.allocatedAmount)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Makbuz Onizle'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Tamam'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final amountController = TextEditingController(text: '1250');
    Map<String, String> selectedMember = ManagerFinanceMockData.members.first;
    Map<String, String> selectedAccount = ManagerFinanceMockData.accounts.first;
    AllocationMode selectedMode = AllocationMode.oldestFirst;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tahsilat Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Map<String, String>>(
                      initialValue: selectedMember,
                      decoration: const InputDecoration(labelText: 'Uye'),
                      items: ManagerFinanceMockData.members
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item['name']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedMember = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Map<String, String>>(
                      initialValue: selectedAccount,
                      decoration: const InputDecoration(labelText: 'Kasa'),
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
                        setState(() => selectedAccount = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<AllocationMode>(
                      initialValue: selectedMode,
                      decoration:
                          const InputDecoration(labelText: 'Kapama Modu'),
                      items: AllocationMode.values
                          .map(
                            (mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedMode = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Tutar'),
                      keyboardType: TextInputType.number,
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

                    await context
                        .read<ManagerFinanceProvider>()
                        .createCollection(
                          payerId: selectedMember['id']!,
                          payerName: selectedMember['name']!,
                          amount: amount,
                          allocationMode: selectedMode,
                          cashAccountId: selectedAccount['id']!,
                          cashAccountName: selectedAccount['name']!,
                        );

                    if (context.mounted) {
                      Navigator.pop(context);
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
