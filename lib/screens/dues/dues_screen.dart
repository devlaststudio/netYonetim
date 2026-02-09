import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/due_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/providers/app_provider.dart';
import 'package:intl/intl.dart';

class DuesScreen extends StatefulWidget {
  const DuesScreen({super.key});

  @override
  State<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends State<DuesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPaymentSheet(BuildContext context, DueModel due) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PaymentSheet(due: due),
    );
  }

  void _showPayAllSheet(BuildContext context) {
    final provider = context.read<AppProvider>();
    final totalAmount = provider.totalDebt;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _PaymentSheet(totalAmount: totalAmount, isPayAll: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borçlarım'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bekleyen'),
            Tab(text: 'Ödenen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Bekleyen borçlar
          _OpenDuesTab(
            dues: provider.openDues,
            totalDebt: provider.totalDebt,
            currencyFormat: currencyFormat,
            onPayDue: (due) => _showPaymentSheet(context, due),
            onPayAll: () => _showPayAllSheet(context),
          ),
          // Ödenen borçlar
          _PaidDuesTab(dues: provider.paidDues, currencyFormat: currencyFormat),
        ],
      ),
    );
  }
}

class _OpenDuesTab extends StatelessWidget {
  final List<DueModel> dues;
  final double totalDebt;
  final NumberFormat currencyFormat;
  final Function(DueModel) onPayDue;
  final VoidCallback onPayAll;

  const _OpenDuesTab({
    required this.dues,
    required this.totalDebt,
    required this.currencyFormat,
    required this.onPayDue,
    required this.onPayAll,
  });

  @override
  Widget build(BuildContext context) {
    if (dues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.success.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Harika! 🎉',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Ödenmemiş borcunuz bulunmuyor',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Total debt summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Toplam Borç',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(totalDebt),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPayAll,
                  icon: const Icon(Icons.payment),
                  label: const Text('Tümünü Öde'),
                ),
              ),
            ],
          ),
        ),

        // Due list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dues.length,
            itemBuilder: (context, index) {
              final due = dues[index];
              return _DueCard(
                due: due,
                currencyFormat: currencyFormat,
                onPay: () => onPayDue(due),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PaidDuesTab extends StatelessWidget {
  final List<DueModel> dues;
  final NumberFormat currencyFormat;

  const _PaidDuesTab({required this.dues, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    if (dues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz ödeme geçmişi yok',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dues.length,
      itemBuilder: (context, index) {
        final due = dues[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            title: Text(due.description),
            subtitle: Text(
              due.paidDate != null
                  ? 'Ödendi: ${DateFormat('dd MMM yyyy').format(due.paidDate!)}'
                  : due.periodDisplay,
            ),
            trailing: Text(
              currencyFormat.format(due.amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DueCard extends StatelessWidget {
  final DueModel due;
  final NumberFormat currencyFormat;
  final VoidCallback onPay;

  const _DueCard({
    required this.due,
    required this.currencyFormat,
    required this.onPay,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    due.typeDisplayName,
                    style: TextStyle(
                      color: _getTypeColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: due.isOverdue
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    due.statusDisplayName,
                    style: TextStyle(
                      color: due.isOverdue
                          ? AppColors.error
                          : AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              due.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Vade: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(due.dueDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFormat.format(due.amount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (due.delayFee != null && due.delayFee! > 0)
                      Text(
                        '+${currencyFormat.format(due.delayFee)} gecikme',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                      ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(onPressed: onPay, child: const Text('Öde')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (due.type) {
      case DueType.aidat:
        return AppColors.primary;
      case DueType.su:
        return Colors.blue;
      case DueType.elektrik:
        return Colors.amber;
      case DueType.dogalgaz:
        return Colors.orange;
      case DueType.demirbas:
        return Colors.purple;
      case DueType.diger:
        return AppColors.textSecondary;
    }
  }
}

class _PaymentSheet extends StatefulWidget {
  final DueModel? due;
  final double? totalAmount;
  final bool isPayAll;

  const _PaymentSheet({this.due, this.totalAmount, this.isPayAll = false});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  int _selectedMethod = 0;
  final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  double get amount =>
      widget.isPayAll ? widget.totalAmount! : widget.due!.remainingAmount;

  double get commission => _selectedMethod == 0 ? amount * 0.0189 : 0;
  double get total => amount + commission;

  Future<void> _processPayment() async {
    final provider = context.read<AppProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success;
    if (widget.isPayAll) {
      success = await provider.payAllDues(
        _selectedMethod == 0
            ? PaymentMethod.creditCard
            : PaymentMethod.bankTransfer,
      );
    } else {
      success = await provider.payDue(
        widget.due!,
        _selectedMethod == 0
            ? PaymentMethod.creditCard
            : PaymentMethod.bankTransfer,
      );
    }

    if (mounted) {
      Navigator.of(context).pop(); // Close loading
      Navigator.of(context).pop(); // Close sheet

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(success ? 'Ödeme başarılı! ✅' : 'Ödeme başarısız'),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text('Ödeme Yap', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            widget.isPayAll
                ? 'Tüm borçlarınızı ödeyin'
                : widget.due!.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Ödenecek Tutar',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(total),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (commission > 0)
                  Text(
                    '(${currencyFormat.format(commission)} komisyon dahil)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment methods
          Text('Ödeme Yöntemi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // Credit card
          _PaymentMethodTile(
            icon: Icons.credit_card,
            title: 'Kredi/Banka Kartı',
            subtitle: 'Komisyon: %1.89',
            isSelected: _selectedMethod == 0,
            onTap: () => setState(() => _selectedMethod = 0),
          ),
          const SizedBox(height: 8),

          // Bank transfer
          _PaymentMethodTile(
            icon: Icons.account_balance,
            title: 'Havale/EFT',
            subtitle: 'Komisyon: Ücretsiz',
            isSelected: _selectedMethod == 1,
            onTap: () => setState(() => _selectedMethod = 1),
          ),
          const SizedBox(height: 24),

          // Pay button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _processPayment,
              child: Text('${currencyFormat.format(total)} Öde'),
            ),
          ),
          const SizedBox(height: 8),

          // Security note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                'Güvenli ödeme',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
