import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/member_mock_data.dart';
import '../../data/models/manager/manager_models.dart' show ChargeMainType;
import '../properties/property_list_screen.dart' show PropertyItem;

enum _PayerType { tenant, owner }

class ChargeAddSheet extends StatefulWidget {
  final PropertyItem propertyItem;

  const ChargeAddSheet({super.key, required this.propertyItem});

  @override
  State<ChargeAddSheet> createState() => _ChargeAddSheetState();
}

class _ChargeAddSheetState extends State<ChargeAddSheet> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  final _dateFormat = DateFormat('dd.MM.yyyy');

  late _PayerType _payerType;
  ChargeMainType _selectedMainType = ChargeMainType.dues;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  bool get _hasTenant => widget.propertyItem.tenant != null;
  bool get _hasOwner =>
      widget.propertyItem.owner != null &&
      widget.propertyItem.owner!.status != MemberStatus.bosDaire;

  @override
  void initState() {
    super.initState();
    // Default to tenant if exists, otherwise owner
    _payerType = _hasTenant ? _PayerType.tenant : _PayerType.owner;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveCharge() {
    // Basic validation
    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir tutar giriniz.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if the selected payer exists
    if (_payerType == _PayerType.tenant && !_hasTenant) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kiracı bulunmuyor. Lütfen Malik seçin.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_payerType == _PayerType.owner && !_hasOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Malik bulunmuyor.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final amountStr = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountStr) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir tutar giriniz.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // In a real app, this would call a service or provider.
    // For now, trigger success message and pop
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Borç başarıyla eklendi: ${_currencyFormat.format(amount)}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Disable segment buttons if they don't exist
    final Set<_PayerType> enabledSegments = {};
    if (_hasTenant) enabledSegments.add(_PayerType.tenant);
    if (_hasOwner) enabledSegments.add(_PayerType.owner);

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
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Borç / Tahakkuk Ekle',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${widget.propertyItem.block} - ${widget.propertyItem.unitNo}',
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

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sorumlu Seçimi
                  const Text(
                    'Ödeme Sorumlusu',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<_PayerType>(
                      segments: [
                        ButtonSegment<_PayerType>(
                          value: _PayerType.tenant,
                          icon: const Icon(Icons.person_outline),
                          label: Text(
                            _hasTenant
                                ? 'Kiracı: ${widget.propertyItem.tenant!.fullName}'
                                : 'Kiracı (Yok)',
                          ),
                          enabled:
                              true, // Safeguard against selection assertion
                        ),
                        ButtonSegment<_PayerType>(
                          value: _PayerType.owner,
                          icon: const Icon(Icons.real_estate_agent_outlined),
                          label: Text(
                            _hasOwner
                                ? 'Malik: ${widget.propertyItem.owner!.fullName}'
                                : 'Malik (Yok)',
                          ),
                          enabled: true, // Safeguard
                        ),
                      ],
                      selected: {_payerType},
                      onSelectionChanged: (selection) {
                        // Double check just in case, SegmentedButton handles disabled
                        if (selection.first == _PayerType.tenant && !_hasTenant)
                          return;
                        if (selection.first == _PayerType.owner && !_hasOwner)
                          return;

                        setState(() => _payerType = selection.first);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.primary.withValues(alpha: 0.1);
                            }
                            return AppColors.surface;
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.primary;
                            }
                            return AppColors.textSecondary;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kategori
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ChargeMainType.values
                        .map(
                          (type) => _CategoryOption(
                            label: type.label,
                            icon: type.icon,
                            selected: _selectedMainType == type,
                            onTap: () =>
                                setState(() => _selectedMainType = type),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Tutar & Tarih
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Tutar',
                            hintText: '0.00',
                            prefixText: '₺ ',
                            prefixStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: _pickDueDate,
                          controller: TextEditingController(
                            text: _dateFormat.format(_dueDate),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Son Ödeme Tarihi',
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Açıklama
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Açıklama (Opsiyonel)',
                      hintText: 'Borç detaylarını buraya girebilirsiniz...',
                      filled: true,
                      fillColor: AppColors.background,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveCharge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Borç Ekle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Klavye için padding alanı
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on ChargeMainType {
  String get label {
    switch (this) {
      case ChargeMainType.dues:
        return 'Aidat';
      case ChargeMainType.fuel:
        return 'Yakıt';
      case ChargeMainType.fixture:
        return 'Demirbaş';
      case ChargeMainType.maintenance:
        return 'Bakım';
      case ChargeMainType.personnel:
        return 'Personel';
      case ChargeMainType.operating:
        return 'İşletme';
      case ChargeMainType.reserveFund:
        return 'Fon';
      case ChargeMainType.other:
        return 'Diğer';
    }
  }

  IconData get icon {
    switch (this) {
      case ChargeMainType.dues:
        return Icons.house_outlined;
      case ChargeMainType.fuel:
        return Icons.local_fire_department_outlined;
      case ChargeMainType.fixture:
        return Icons.build_outlined;
      case ChargeMainType.maintenance:
        return Icons.settings_outlined;
      case ChargeMainType.personnel:
        return Icons.people_outline;
      case ChargeMainType.operating:
        return Icons.business_center_outlined;
      case ChargeMainType.reserveFund:
        return Icons.savings_outlined;
      case ChargeMainType.other:
        return Icons.more_horiz;
    }
  }
}
