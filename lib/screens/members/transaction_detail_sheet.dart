import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class TransactionDetailSheet extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onDelete;
  final ValueChanged<Map<String, dynamic>> onUpdate;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends State<TransactionDetailSheet> {
  final _currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  bool _isEditing = false;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.transaction['description'],
    );
    // Amount determines which field is used (debt vs paid)
    // For simplicity, we assume we edit the non-zero one or the primary one.
    double amount = widget.transaction['debt'] > 0
        ? widget.transaction['debt']
        : widget.transaction['paid'];
    _amountController = TextEditingController(text: amount.toString());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final newAmount = double.tryParse(_amountController.text) ?? 0;
    final isDebt = widget.transaction['debt'] > 0;

    final updatedTransaction = Map<String, dynamic>.from(widget.transaction);
    updatedTransaction['description'] = _descriptionController.text;
    if (isDebt) {
      updatedTransaction['debt'] = newAmount;
    } else {
      updatedTransaction['paid'] = newAmount;
    }
    // Recalculate balance logic would ideally be done in parent, but for mock,
    // we just pass the updated data back.

    widget.onUpdate(updatedTransaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final isDebt = tx['debt'] > 0;
    final amount = isDebt ? tx['debt'] : tx['paid'];
    final type = isDebt ? 'Borç (Tahakkuk)' : 'Tahsilat (Ödeme)';
    final color = isDebt ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'İşlem Detayı',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          if (_isEditing) ...[
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Tutar',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ] else ...[
            _detailRow('Tarih', DateFormat('dd.MM.yyyy').format(tx['date'])),
            _detailRow('İşlem Tipi', type, valueColor: color),
            _detailRow('Makbuz No', tx['receiptNo']),
            _detailRow('Kasa', tx['safe']),
            _detailRow('Açıklama', tx['description']),
            _detailRow(
              'Tutar',
              _currencyFormat.format(amount),
              valueStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Confirm delete
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('İşlemi Sil'),
                          content: const Text(
                            'Bu işlemi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                widget.onDelete();
                                Navigator.pop(context); // Close sheet
                              },
                              child: const Text(
                                'Sil',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'Sil',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Güncelle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }
}
