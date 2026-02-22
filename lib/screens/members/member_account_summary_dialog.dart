import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/member_mock_data.dart';
import 'package:intl/intl.dart';
import '../../core/theme/custom_colors.dart';

class MemberAccountSummaryDialog extends StatefulWidget {
  final MemberData member;

  const MemberAccountSummaryDialog({super.key, required this.member});

  @override
  State<MemberAccountSummaryDialog> createState() =>
      _MemberAccountSummaryDialogState();
}

class _MemberAccountSummaryDialogState
    extends State<MemberAccountSummaryDialog> {
  bool _useDateRange = false;
  bool _showBulkSingleLine = true;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 1000, // Fixed width for desktop-like feel
        height: 800,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(currencyFormat),

                    const SizedBox(height: 16),

                    // Date Filter
                    Row(
                      children: [
                        Checkbox(
                          value: _useDateRange,
                          onChanged: (val) => setState(() {
                            _useDateRange = val ?? false;
                            if (!_useDateRange) {
                              _startDate = null;
                              _endDate = null;
                            }
                          }),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Tarih Aralığı Seç',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (_useDateRange) ...[
                          const SizedBox(width: 16),
                          _dateSelector(
                            context: context,
                            label: _startDate == null
                                ? 'Başlangıç Tarihi'
                                : DateFormat('dd.MM.yyyy').format(_startDate!),
                            onTap: () => _selectDate(context, true),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '-',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _dateSelector(
                            context: context,
                            label: _endDate == null
                                ? 'Bitiş Tarihi'
                                : DateFormat('dd.MM.yyyy').format(_endDate!),
                            onTap: () => _selectDate(context, false),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Mock query action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sorgulama yapılıyor...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.search,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Sorgula',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Transaction Table
                    _buildTransactionTable(currencyFormat),

                    const SizedBox(height: 16),

                    // Bottom Options
                    Row(
                      children: [
                        Checkbox(
                          value: _showBulkSingleLine,
                          activeColor: const Color(
                            0xFF7FA84F,
                          ), // Greenish checkbox
                          onChanged: (val) => setState(
                            () => _showBulkSingleLine = val ?? false,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Toplu Tahsilat Hareketlerini Tek Satırda Göster',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.print,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Hesap Özetini Yazdır',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFD32F2F,
                            ), // Red button
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_square,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.member.fullName.toUpperCase()}) Hesap Özeti',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Row(
              children: const [
                Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  'Kapat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(NumberFormat format) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            color: CustomColors.tableHeaderColor, // Custom header color
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _summaryHeaderCell('Bakiye'),
                  _summaryHeaderCell('Aidat'),
                  _summaryHeaderCell('Yakıt'),
                  _summaryHeaderCell('Demirbaş', isLast: true),
                ],
              ),
            ),
          ),
          // Value Row
          Container(
            color: Colors.white,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _summaryValueCell('0,00 ₺ (A)', isBold: true),
                  _summaryValueCell('0,00 ₺ (A)'),
                  _summaryValueCell('0,00 ₺ (A)'),
                  _summaryValueCell('0,00 ₺ (A)', isLast: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryHeaderCell(String text, {bool isLast = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(right: BorderSide(color: Colors.white24)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _summaryValueCell(
    String text, {
    bool isLast = false,
    bool isBold = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTable(NumberFormat format) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            color: CustomColors.tableHeaderColor,
            child: Row(
              children: [
                _tableHeaderCell('Tarih', flex: 2, icon: Icons.sort),
                _tableHeaderCell('Mak.No', flex: 1),
                _tableHeaderCell('Kasa', flex: 2),
                _tableHeaderCell('Açıklama', flex: 5),
                _tableHeaderCell('Borç', flex: 2),
                _tableHeaderCell('Ödenen', flex: 2),
                _tableHeaderCell('Bakiye', flex: 2),
                _tableHeaderCell('İşlem', flex: 1),
                _tableHeaderCell('Mkb', flex: 1, isLast: true),
              ],
            ),
          ),

          // Mock Data Row
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _tableCell(
                  '12-02-2026',
                  flex: 2,
                  color: const Color(0xFFD32F2F),
                ),
                _tableCell('1', flex: 1, color: const Color(0xFFD32F2F)),
                _tableCell(
                  'Nakit Kasa',
                  flex: 2,
                  color: const Color(0xFFD32F2F),
                ),
                _tableCell(
                  'Üyeye Ödenen',
                  flex: 5,
                  align: TextAlign.left,
                  color: const Color(0xFFD32F2F),
                ),
                _tableCell(
                  '100,00',
                  flex: 2,
                  color: const Color(0xFFD32F2F),
                  align: TextAlign.right,
                ),
                _tableCell('', flex: 2),
                _tableCell(
                  '0,00',
                  flex: 2,
                  color: const Color(0xFFD32F2F),
                  align: TextAlign.right,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 48, // Fixed height for alignment
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: const Icon(Icons.print, color: Color(0xFF7FA84F)),
                  ),
                ),
              ],
            ),
          ),

          // Total Row
          Container(
            color: const Color(0xFFCFD8DC), // Light gray footer
            child: Row(
              children: [
                const Spacer(flex: 5), // Tarih(2) + Mak(1) + Kasa(2)
                Expanded(
                  flex: 5, // Açıklama
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    alignment: Alignment.centerRight,
                    child: const Text(
                      'Toplam',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                _tableCell(
                  '100,00',
                  flex: 2, // Borç
                  color: const Color(0xFFD32F2F),
                  align: TextAlign.right,
                  isBold: true,
                ),
                _tableCell(
                  '0,00',
                  flex: 2, // Ödenen
                  align: TextAlign.right,
                  isBold: true,
                ),
                _tableCell(
                  '-100,00',
                  flex: 2, // Bakiye
                  color: const Color(0xFFD32F2F),
                  align: TextAlign.right,
                  isBold: true,
                ),
                const Spacer(flex: 2), // İşlem(1) + Mkb(1)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(
    String text, {
    required int flex,
    IconData? icon,
    bool isLast = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(right: BorderSide(color: Colors.white24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCell(
    String text, {
    required int flex,
    Color? color,
    TextAlign align = TextAlign.center,
    bool isBold = false,
    bool isLast = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 48, // Fixed height for row alignment
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: align == TextAlign.center
            ? Alignment.center
            : (align == TextAlign.right
                  ? Alignment.centerRight
                  : Alignment.centerLeft),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _dateSelector({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
