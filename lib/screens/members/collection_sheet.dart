import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:file_saver/file_saver.dart';
import '../../utils/pdf_generator.dart';
import '../../utils/excel_generator.dart';
import '../printing/universal_print_screen.dart';
import '../printing/documents/collection_receipt.dart';

import '../../data/mock/member_mock_data.dart';

class CollectionSheet extends StatefulWidget {
  final MemberData member;
  final List<MemberData> allProperties;

  const CollectionSheet({
    super.key,
    required this.member,
    required this.allProperties,
  });

  @override
  State<CollectionSheet> createState() => _CollectionSheetState();
}

class _CollectionSheetState extends State<CollectionSheet> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  final _dateFormat = DateFormat('dd.MM.yyyy');

  late MemberData _selectedProperty;
  bool _applyToAll = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _collectionDate = DateTime.now();
  bool _showCommission = false;
  String _selectedCollectionGroup = 'Aidat';
  int _selectedPaymentMethod = 0; // 0: Nakit, 1: Kredi Kartı, 2: Havale/EFT

  Map<String, double> _currentDebts = {};
  Set<String> _selectedDebtTypes = {};

  void _calculateDebts() {
    _currentDebts.clear();

    // Helper to add debt safely
    void addDebt(String type, double amount) {
      if (amount > 0) {
        _currentDebts[type] = (_currentDebts[type] ?? 0) + amount;
      }
    }

    if (_applyToAll) {
      for (var p in widget.allProperties) {
        addDebt('Aidat', p.aidatBalance);
        addDebt('Yakıt', p.yakitBalance);
        addDebt('Demirbaş', p.demirbasBalance);
        // Calculate delay as remainder for now
        double other =
            p.totalBalance -
            (p.aidatBalance + p.yakitBalance + p.demirbasBalance);
        addDebt('Gecikme', other > 0 ? other : 0);
      }
    } else {
      var p = _selectedProperty;
      addDebt('Aidat', p.aidatBalance);
      addDebt('Yakıt', p.yakitBalance);
      addDebt('Demirbaş', p.demirbasBalance);
      double other =
          p.totalBalance -
          (p.aidatBalance + p.yakitBalance + p.demirbasBalance);
      addDebt('Gecikme', other > 0 ? other : 0);
    }
  }

  void _updateAmount() {
    final total = _calculateTotalSelected();
    _amountController.text = total.toStringAsFixed(2);
  }

  double _calculateTotalSelected() {
    double total = 0;
    for (var type in _selectedDebtTypes) {
      final amount = _currentDebts[type]!;
      // Include mock delay in total payment
      final delay = (type == 'Aidat' && amount > 0) ? amount * 0.05 : 0.0;
      total += (amount + delay);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _selectedProperty = widget.member;
    // Default to 'All Properties' if user has multiple
    if (widget.allProperties.length > 1) {
      _applyToAll = true;
    }
    _calculateDebts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commissionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _collectionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _collectionDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tahsilat İşlemi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.member.fullName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Üst Alan: Taşınmaz Seçimi ve Tahsilat Grubu
                  Row(
                    children: [
                      // Sol: Taşınmaz Seçimi (Tümü veya Tekil)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TAŞINMAZ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  // Value logic: 'all' for All Properties, member.id for specific
                                  value: _applyToAll
                                      ? 'all'
                                      : _selectedProperty.id,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.expand_more,
                                    color: AppColors.textSecondary,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      if (newValue == 'all') {
                                        _applyToAll = true;
                                      } else {
                                        _applyToAll = false;
                                        _selectedProperty = widget.allProperties
                                            .firstWhere(
                                              (m) => m.id == newValue,
                                            );
                                      }
                                      _calculateDebts();
                                      _selectedDebtTypes.clear();
                                      _updateAmount();
                                    });
                                  },
                                  items: [
                                    // Option 1: Tüm Taşınmazlar (Varsa birden fazla)
                                    if (widget.allProperties.length > 1)
                                      DropdownMenuItem<String>(
                                        value: 'all',
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.home_work_outlined,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Tümü (${widget.allProperties.length})',
                                            ),
                                          ],
                                        ),
                                      ),
                                    // Option 2..N: Tekil Taşınmazlar
                                    ...widget.allProperties.map((m) {
                                      return DropdownMenuItem<String>(
                                        value: m.id,
                                        child: Text(
                                          '${m.block} - ${m.unitNo}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sağ: Tahsilat Grubu (Aidat, Yakıt, vb.)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TAHSİLAT GRUBU',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCollectionGroup,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.expand_more,
                                    color: AppColors.textSecondary,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(
                                        () =>
                                            _selectedCollectionGroup = newValue,
                                      );
                                    }
                                  },
                                  items: ['Aidat', 'Yakıt', 'Demirbaş', 'Avans']
                                      .map((group) {
                                        return DropdownMenuItem<String>(
                                          value: group,
                                          child: Text(group),
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Bakiye Kartı
                  // 2. Borç Seçim Kartı
                  Container(
                    width: double.infinity, // Ensure full width
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Select All Checkbox
                              SizedBox(
                                width: 40,
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: Checkbox(
                                    value:
                                        _selectedDebtTypes.length ==
                                            _currentDebts.keys.length &&
                                        _currentDebts.isNotEmpty,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedDebtTypes = _currentDebts
                                              .keys
                                              .toSet();
                                        } else {
                                          _selectedDebtTypes.clear();
                                        }
                                        _updateAmount();
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const Expanded(
                                flex: 2,
                                child: Text(
                                  'BORÇ TÜRÜ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Expanded(
                                flex: 2,
                                child: Text(
                                  'BORÇ',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Expanded(
                                flex: 2,
                                child: Text(
                                  'GECİKME',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Expanded(
                                flex: 2,
                                child: Text(
                                  'ÖDEME',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rows
                        if (_currentDebts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Ödenecek borç bulunmamaktadır.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _currentDebts.length,
                            separatorBuilder: (ctx, i) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final type = _currentDebts.keys.elementAt(index);
                              final amount = _currentDebts[type]!;
                              // Mock delay for demo purposes (usually calculated or from API)
                              // If type is 'Aidat' and amount > 0, assume some delay
                              final delay = (type == 'Aidat' && amount > 0)
                                  ? amount * 0.05
                                  : 0.0;
                              final total = amount + delay;
                              final isSelected = _selectedDebtTypes.contains(
                                type,
                              );

                              return Container(
                                color: index % 2 == 0
                                    ? Colors.white60
                                    : Colors.white,

                                padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Transform.scale(
                                        scale: 0.8,
                                        child: Checkbox(
                                          visualDensity: VisualDensity.compact,
                                          value: isSelected,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                _selectedDebtTypes.add(type);
                                              } else {
                                                _selectedDebtTypes.remove(type);
                                              }
                                              _updateAmount();
                                            });
                                          },
                                          activeColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        _currencyFormat.format(amount),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        _currencyFormat.format(delay),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        _currencyFormat.format(total),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        // Footer (Total Selected)
                        if (_currentDebts.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOPLAM ÖDENECEK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _currencyFormat.format(
                                    _calculateTotalSelected(),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Tutar ve Komisyon Alanı
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tahsilat Tutarı
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          cursorColor: AppColors.textPrimary,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          decoration: _buildInputDecoration(
                            labelText: 'Tahsilat Tutarı',
                            hintText: '0,00',
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            prefixText: '₺ ',
                          ),
                        ),
                      ),

                      // Komisyon Ekle Butonu veya Alanı
                      const SizedBox(width: 12),
                      if (!_showCommission)
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: InkWell(
                            onTap: () => setState(() => _showCommission = true),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.success.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _commissionController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            cursorColor: AppColors.textPrimary,
                            decoration: _buildInputDecoration(
                              labelText: 'Komisyon',
                              hintText: '0,00',
                              prefixText: '₺ ',
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showCommission = false;
                                    _commissionController.clear();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. Tarih ve Açıklama
                  TextField(
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: _buildInputDecoration(
                      labelText: 'Tahsilat Tarihi',
                      hintText: _dateFormat.format(_collectionDate),
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: const Icon(
                        Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    controller: TextEditingController(
                      text: _dateFormat.format(_collectionDate),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    cursorColor: AppColors.textPrimary,
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                      labelText: 'Banka / İşlem Açıklaması',
                      hintText: 'Örn: Ocak ayı aidat ödemesi...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Icon(
                          Icons.description_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Ödeme Yöntemi
                  const Text(
                    'ÖDEME YÖNTEMİ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _paymentMethodChip(0, Icons.money, 'Nakit'),
                      const SizedBox(width: 8),
                      _paymentMethodChip(1, Icons.credit_card, 'Kredi Kartı'),
                      const SizedBox(width: 8),
                      _paymentMethodChip(
                        2,
                        Icons.account_balance,
                        'Havale/EFT',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Submit Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement actual save logic
                  Navigator.pop(context);
                  // Show success message first
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tahsilat başarıyla kaydedildi'),
                      backgroundColor: AppColors.success,
                    ),
                  );

                  // Show Print Confirmation Dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('İşlem Başarılı'),
                      content: const Text(
                        'Tahsilat işleminiz başarıyla gerçekleştirildi.\n\nTahsilat makbuzunu yazdırmak ister misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Close sheet
                          },
                          child: const Text(
                            'Hayır',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog

                            // Get payment method string
                            final paymentMethods = [
                              'Nakit',
                              'Kredi Kartı',
                              'Havale/EFT',
                            ];
                            final paymentMethod =
                                paymentMethods[_selectedPaymentMethod];

                            // Navigate to Print Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UniversalPrinterScreen(
                                  title: 'Tahsilat Makbuzu Yazdır',
                                  content: CollectionReceipt(
                                    member: widget.member,
                                    debts: _currentDebts, // Simplified for demo
                                    totalAmount: _calculateTotalSelected(),
                                    date: _collectionDate,
                                    receiptNo:
                                        '2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
                                    description: _descriptionController.text,
                                    paymentMethod: paymentMethod,
                                  ),
                                  onPrint: (note) async {
                                    // Generate PDF
                                    final pdfBytes =
                                        await generateCollectionReceiptPdf(
                                          widget.member,
                                          _currentDebts,
                                          _calculateTotalSelected(),
                                          _collectionDate,
                                          '2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
                                          _descriptionController.text,
                                          note,
                                          paymentMethod,
                                        );

                                    // Print
                                    await Printing.layoutPdf(
                                      onLayout: (PdfPageFormat format) async =>
                                          pdfBytes,
                                      name: 'Tahsilat Makbuzu',
                                    );
                                  },
                                  onPdf: (note) async {
                                    final pdfBytes =
                                        await generateCollectionReceiptPdf(
                                          widget.member,
                                          _currentDebts,
                                          _calculateTotalSelected(),
                                          _collectionDate,
                                          '2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
                                          _descriptionController.text,
                                          note,
                                          paymentMethod,
                                        );

                                    await FileSaver.instance.saveFile(
                                      name: 'tahsilat_makbuzu',
                                      bytes: Uint8List.fromList(pdfBytes),
                                      fileExtension: 'pdf',
                                      mimeType: MimeType.other,
                                      customMimeType: 'application/pdf',
                                    );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'PDF makbuz cihazınıza indirildi.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  onEmail: (note) async {
                                    if (kIsWeb) {
                                      // Web: Open mail client
                                      final String subject =
                                          'Tahsilat Makbuzu - Net Yol Sitesi';
                                      final String body =
                                          'Sayın ${widget.member.fullName},\n\nEkte tahsilat makbuzunuz yer almaktadır.\n\nİyi günler dileriz.';

                                      final String emailPath =
                                          widget.member.email;

                                      // Manually encode query parameters to ensure compatibility
                                      String? encodeQueryParameters(
                                        Map<String, String> params,
                                      ) {
                                        return params.entries
                                            .map(
                                              (e) =>
                                                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                                            )
                                            .join('&');
                                      }

                                      final Uri emailLaunchUri = Uri(
                                        scheme: 'mailto',
                                        path: emailPath,
                                        query: encodeQueryParameters({
                                          'subject': subject,
                                          'body': body,
                                        }),
                                      );

                                      debugPrint(
                                        'Trying to launch email: $emailLaunchUri',
                                      );

                                      try {
                                        if (await canLaunchUrl(
                                          emailLaunchUri,
                                        )) {
                                          await launchUrl(emailLaunchUri);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'E-posta taslağı açıldı. Lütfen indirdiğiniz PDF\'i ekleyiniz.',
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          // Fallback: try launching without checking canLaunchUrl
                                          try {
                                            await launchUrl(emailLaunchUri);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'E-posta açılamadı: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text('Hata: $e')),
                                          );
                                        }
                                      }
                                    } else {
                                      // Mobile/Desktop: Share with attachment
                                      final pdfBytes =
                                          await generateCollectionReceiptPdf(
                                            widget.member,
                                            _currentDebts,
                                            _calculateTotalSelected(),
                                            _collectionDate,
                                            '2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
                                            _descriptionController.text,
                                            note,
                                            paymentMethod,
                                          );

                                      await Printing.sharePdf(
                                        bytes: pdfBytes,
                                        filename: 'tahsilat_makbuzu.pdf',
                                        subject:
                                            'Tahsilat Makbuzu - Net Yol Sitesi',
                                        body:
                                            'Sayın ${widget.member.fullName},\n\nEkte tahsilat makbuzunuz yer almaktadır.\n\nİyi günler dileriz.',
                                        emails: widget.member.email.isNotEmpty
                                            ? [widget.member.email]
                                            : null,
                                      );
                                    }
                                  },
                                  onExcel: (note) async {
                                    final excelBytes =
                                        generateCollectionReceiptExcel(
                                          widget.member,
                                          _currentDebts,
                                          _calculateTotalSelected(),
                                          _collectionDate,
                                          '2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
                                          _descriptionController.text,
                                          note,
                                          paymentMethod,
                                        );

                                    if (excelBytes != null) {
                                      await FileSaver.instance.saveFile(
                                        name: 'tahsilat_makbuzu',
                                        bytes: Uint8List.fromList(excelBytes),
                                        fileExtension: 'xlsx',
                                        mimeType: MimeType.microsoftExcel,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ).then((_) {
                              // Close sheet after returning from print screen
                              if (context.mounted) Navigator.of(context).pop();
                            });
                          },
                          icon: const Icon(Icons.print, size: 18),
                          label: const Text('Evet, Makbuzu Yazdır'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Tahsilatı Tamamla',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.success.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      floatingLabelStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      hintText: hintText,
      alignLabelWithHint: true,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      prefixStyle: prefixText != null
          ? const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            )
          : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textTertiary, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _paymentMethodChip(int index, IconData icon, String label) {
    final isSelected = _selectedPaymentMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withAlpha(70)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primary.withAlpha(200)
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary.withAlpha(200)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
