import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/mock/member_mock_data.dart'; // To get blocks

class PropertyAddSheet extends StatefulWidget {
  const PropertyAddSheet({super.key});

  @override
  State<PropertyAddSheet> createState() => _PropertyAddSheetState();
}

class _PropertyAddSheetState extends State<PropertyAddSheet> {
  String? _selectedBlock;
  String? _selectedAidatGroup;
  String _status = 'DOLU';

  final List<String> _aidatGroups = ['Daire', 'Dükkan', 'Yönetici', 'Ofis'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFirstRow(),
                  const SizedBox(height: 16),
                  _buildSecondRow(),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildCounterRow(),
                  const SizedBox(height: 24),
                  _buildSaveButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_square,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Yeni Taşınmaz Ekle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(
                  Icons.cancel,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Kapat',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for text fields using the generic grey style from screenshot
  Widget _buildField({
    required String label,
    required String hint,
    IconData? suffixIcon,
    Widget? labelTrailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (labelTrailing != null) ...[
              const SizedBox(width: 4),
              Flexible(child: labelTrailing),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5), // Light grey fill
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: AppColors.textSecondary, size: 20)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    Widget? labelTrailing,
    String? hintText,
  }) {
    // Ensure value is in items, otherwise treat as null
    final effectiveValue = (value != null && items.contains(value))
        ? value
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (labelTrailing != null) ...[
              const SizedBox(width: 4),
              Flexible(child: labelTrailing),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveValue,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Text(
                  hintText ?? 'Seçiniz...',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ),
              icon: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreenHelperText(String text, IconData icon) {
    return InkWell(
      onTap: () {}, // Future add functionality
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF7CB342)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7CB342),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 16.0;
        final double width = (constraints.maxWidth - (spacing * 3)) / 4;
        final bool isSmall = constraints.maxWidth < 600;

        if (isSmall) {
          final blockItems = MemberMockData.getBlocks()
              .where((b) => b != 'TÜM BLOKLAR')
              .toList();
          return Column(
            children: [
              _buildDropdown(
                label: 'Blok',
                value: _selectedBlock,
                items: blockItems,
                hintText: 'Blok Seçiniz...',
                onChanged: (val) {
                  setState(() => _selectedBlock = val);
                },
                labelTrailing: _buildGreenHelperText(
                  'Blok Ekle',
                  Icons.add_circle,
                ),
              ),
              const SizedBox(height: 16),
              _buildField(label: 'Kapı No', hint: '0'),
              const SizedBox(height: 16),
              _buildField(label: 'Metrekare', hint: '0,00'),
              const SizedBox(height: 16),
              _buildField(label: 'Kişi Sayısı', hint: '0'),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: width,
              child: _buildDropdown(
                label: 'Blok',
                value: _selectedBlock,
                items: ['A Blok', 'B Blok', 'C Blok', 'D Blok'],
                hintText: 'Blok Seçiniz...',
                onChanged: (val) {
                  setState(() => _selectedBlock = val);
                },
                labelTrailing: _buildGreenHelperText(
                  'Blok Ekle',
                  Icons.add_circle,
                ),
              ),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Kapı No', hint: '0'),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Metrekare', hint: '0,00'),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Kişi Sayısı', hint: '0'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecondRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 16.0;
        final double width = (constraints.maxWidth - (spacing * 3)) / 4;
        final bool isSmall = constraints.maxWidth < 600;

        if (isSmall) {
          return Column(
            children: [
              _buildDropdown(
                label: 'Aidat Grubu',
                value: _selectedAidatGroup,
                items: _aidatGroups,
                hintText: 'Aidat Grubu Seçiniz...',
                onChanged: (val) {
                  setState(() => _selectedAidatGroup = val);
                },
                labelTrailing: _buildGreenHelperText(
                  'Aidat Grubu Ekle',
                  Icons.add_circle,
                ),
              ),
              const SizedBox(height: 16),
              _buildField(label: 'Kat', hint: '0', suffixIcon: Icons.add),
              const SizedBox(height: 16),
              _buildField(label: 'Arsa Payı', hint: '0,00'),
              const SizedBox(height: 16),
              _buildField(label: 'Araç Sayısı', hint: '0'),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: width,
              child: _buildDropdown(
                label: 'Aidat Grubu',
                value: _selectedAidatGroup,
                items: _aidatGroups,
                hintText: 'Aidat Grubu Seçiniz...',
                onChanged: (val) {
                  setState(() => _selectedAidatGroup = val);
                },
                labelTrailing: _buildGreenHelperText(
                  'Aidat Grubu Ekle',
                  Icons.add_circle,
                ),
              ),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Kat', hint: '+   0'),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Arsa Payı', hint: '0,00'),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Araç Sayısı', hint: '0'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCounterRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 16.0;
        final double width = (constraints.maxWidth - (spacing * 4)) / 5;
        final bool isSmall = constraints.maxWidth < 800;

        if (isSmall) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildField(label: 'Yakıt Sayaç No', hint: '0'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(label: 'Sıcak Su Sayaç No', hint: '0'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField(label: 'Soğuk Su Sayaç No', hint: '0'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(label: 'Elektrik Sayaç No', hint: '0'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Durumu',
                value: _status,
                items: ['DOLU', 'BOŞ'],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: width,
              child: _buildField(label: 'Yakıt Sayaç No', hint: '0'),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Sıcak Su Sayaç No', hint: '0'),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Soğuk Su Sayaç No', hint: '0'),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildField(label: 'Elektrik Sayaç No', hint: '0'),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: width,
              child: _buildDropdown(
                label: 'Durumu',
                value: _status,
                items: ['DOLU', 'BOŞ'],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
                labelTrailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    const Flexible(
                      child: Text(
                        'Yardım',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.check_circle, size: 18),
        label: const Text('Kaydet'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF8BC34A,
          ), // Distinct light green matching the screenshot
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
