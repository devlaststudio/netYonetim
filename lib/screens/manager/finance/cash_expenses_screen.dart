import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class CashExpensesScreen extends StatefulWidget {
  const CashExpensesScreen({super.key});

  @override
  State<CashExpensesScreen> createState() => _CashExpensesScreenState();
}

class _CashExpensesScreenState extends State<CashExpensesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.cashExpenses.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final dateFormat = DateFormat('dd.MM.yyyy');

    return ManagerPageScaffold(
      title: 'Kasa Giderleri',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Gider Ekle'),
      ),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Gider Ozeti',
                  child: ManagerKpiGrid(
                    items: [
                      ManagerKpiItem(
                        label: 'Toplam Gider',
                        value: formatCurrency(provider.totalExpenseAmount),
                        color: AppColors.error,
                      ),
                      ManagerKpiItem(
                        label: 'Kayit Sayisi',
                        value: '${provider.cashExpenses.length}',
                        color: AppColors.primary,
                      ),
                      ManagerKpiItem(
                        label: 'Odendi',
                        value:
                            '${provider.cashExpenses.where((e) => e.paymentStatus == ExpensePaymentStatus.paid).length}',
                        color: AppColors.success,
                      ),
                      ManagerKpiItem(
                        label: 'Taslak',
                        value:
                            '${provider.cashExpenses.where((e) => e.paymentStatus == ExpensePaymentStatus.draft).length}',
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),
                if (provider.cashExpenses.isEmpty)
                  const SizedBox(
                    height: 300,
                    child: ManagerEmptyState(
                      icon: Icons.money_off_csred_outlined,
                      title: 'Gider kaydi yok',
                      subtitle: 'Yeni gider olusturabilirsiniz.',
                    ),
                  )
                else
                  ...provider.cashExpenses.map(
                    (expense) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFEFEF),
                          child:
                              Icon(Icons.receipt_long, color: AppColors.error),
                        ),
                        title: Text(expense.vendorName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${expense.category} • ${expense.cashAccountName}'),
                            Text(
                              '${dateFormat.format(expense.expenseDate)} • Belge: ${expense.documentNo ?? '-'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Text(
                          formatCurrency(expense.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final amountController = TextEditingController(text: '2300');
    final docController = TextEditingController(text: 'FTR-2026-1');

    Map<String, String> selectedVendor = ManagerFinanceMockData.vendors.first;
    Map<String, String> selectedAccount = ManagerFinanceMockData.accounts.first;
    String selectedCategory = 'Personel';

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Yeni Gider Kaydi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Map<String, String>>(
                      initialValue: selectedVendor,
                      decoration: const InputDecoration(labelText: 'Tedarikci'),
                      items: ManagerFinanceMockData.vendors
                          .map(
                            (vendor) => DropdownMenuItem(
                              value: vendor,
                              child: Text(vendor['name']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedVendor = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: const [
                        'Personel',
                        'Bakim Onarim',
                        'Guvenlik',
                        'Temizlik',
                        'Ortak Alan',
                      ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Map<String, String>>(
                      initialValue: selectedAccount,
                      decoration: const InputDecoration(labelText: 'Kasa'),
                      items: ManagerFinanceMockData.accounts
                          .map(
                            (account) => DropdownMenuItem(
                              value: account,
                              child: Text(account['name']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedAccount = value);
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
                      controller: docController,
                      decoration: const InputDecoration(labelText: 'Belge No'),
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
                        .createCashExpense(
                          vendorId: selectedVendor['id']!,
                          vendorName: selectedVendor['name']!,
                          category: selectedCategory,
                          amount: amount,
                          cashAccountId: selectedAccount['id']!,
                          cashAccountName: selectedAccount['name']!,
                          documentNo: docController.text,
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
