import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/accounting_provider.dart';
import '../../../data/models/accounting_entry_model.dart';
import '../../../widgets/accounting/accounting_drawer.dart';
import '../../../widgets/accounting/transaction_list_widget.dart';

class IncomeExpenseScreen extends StatefulWidget {
  const IncomeExpenseScreen({super.key});

  @override
  State<IncomeExpenseScreen> createState() => _IncomeExpenseScreenState();
}

class _IncomeExpenseScreenState extends State<IncomeExpenseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelir & Gider'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Gelir'),
            Tab(text: 'Gider'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      drawer: const AccountingDrawer(
        currentRoute: '/accounting/income-expense',
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Kayıt'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(provider.filteredEntries),
                _buildTransactionList(provider.incomeEntries),
                _buildTransactionList(provider.expenseEntries),
              ],
            ),
    );
  }

  Widget _buildTransactionList(List<AccountingEntryModel> entries) {
    if (entries.isEmpty) {
      return const Center(child: Text('Kayıt bulunamadı'));
    }

    return TransactionListWidget(
      entries: entries,
      onTap: (entry) => _showEntryDetail(entry),
      onEdit: (entry) => _showEditEntryDialog(entry),
      onDelete: (entry) => _confirmDelete(entry),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final provider = context.read<AccountingProvider>();
    final formKey = GlobalKey<FormState>();

    EntryType selectedType = EntryType.expense;
    String? selectedAccountId;
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final documentController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    PaymentMethodType? selectedPaymentMethod;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final accounts = selectedType == EntryType.income
              ? provider.incomeAccounts
              : provider.expenseAccounts;

          return AlertDialog(
            title: const Text('Yeni Kayıt Ekle'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<EntryType>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'İşlem Tipi',
                      ),
                      items: EntryType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == EntryType.income ? 'Gelir' : 'Gider',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          selectedAccountId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedAccountId,
                      decoration: const InputDecoration(labelText: 'Hesap'),
                      items: accounts.map((account) {
                        return DropdownMenuItem(
                          value: account.id,
                          child: Text('${account.code} - ${account.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedAccountId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Hesap seçiniz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Açıklama'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Açıklama giriniz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Tutar',
                        prefixText: '₺',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Tutar giriniz';
                        if (double.tryParse(value!) == null) {
                          return 'Geçerli bir tutar giriniz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: documentController,
                      decoration: const InputDecoration(
                        labelText: 'Belge No (Opsiyonel)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final account = provider.getAccountById(selectedAccountId!);
                    final entry = AccountingEntryModel(
                      id: 'entry-${DateTime.now().millisecondsSinceEpoch}',
                      accountId: account!.id,
                      accountCode: account.code,
                      accountName: account.name,
                      entryType: selectedType,
                      amount: double.parse(amountController.text),
                      transactionDate: selectedDate,
                      description: descriptionController.text,
                      documentNumber: documentController.text.isNotEmpty
                          ? documentController.text
                          : null,
                      paymentMethod: selectedPaymentMethod,
                      createdBy: 'current-user',
                      createdAt: DateTime.now(),
                    );

                    await provider.addEntry(entry);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kayıt eklendi')),
                      );
                    }
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEntryDetail(AccountingEntryModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Hesap:', '${entry.accountCode} - ${entry.accountName}'),
            _DetailRow('Tutar:', '₺${entry.amount.toStringAsFixed(2)}'),
            _DetailRow(
              'Tarih:',
              DateFormat('dd/MM/yyyy').format(entry.transactionDate),
            ),
            if (entry.documentNumber != null)
              _DetailRow('Belge No:', entry.documentNumber!),
            if (entry.paymentMethod != null)
              _DetailRow('Ödeme Yöntemi:', entry.paymentMethodDisplayName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showEditEntryDialog(AccountingEntryModel entry) {
    // Implement edit dialog similar to add dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Düzenleme özelliği yakında eklenecek')),
    );
  }

  void _confirmDelete(AccountingEntryModel entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kayıt Silme'),
        content: Text(
          '${entry.description} kaydını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AccountingProvider>().deleteEntry(entry.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kayıt silindi')));
      }
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: const Text('Filtreleme özellikleri yakında eklenecek.'),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
