import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_model.dart';

class RecipientGridPanel extends StatefulWidget {
  final ValueChanged<int> onSelectionChanged;
  final bool isMobile;

  const RecipientGridPanel({
    super.key,
    required this.onSelectionChanged,
    this.isMobile = false,
  });

  @override
  State<RecipientGridPanel> createState() => _RecipientGridPanelState();
}

class _RecipientGridPanelState extends State<RecipientGridPanel> {
  // Mock recipients state
  final List<UserModel> _recipients = [
    UserModel(
      id: 'usr1',
      email: '',
      firstName: 'Zeynep',
      lastName: 'Demir',
      phone: '(532) 300-00-00',
      role: UserRole.resident,
      siteId: '',
      unitNo: '02',
      blockName: 'A Blok',
    ),
    UserModel(
      id: 'usr2',
      email: '',
      firstName: 'Hüseyin',
      lastName: 'Yıldırım',
      phone: '(532) 500-00-00',
      role: UserRole.resident,
      siteId: '',
      unitNo: '03',
      blockName: 'A Blok',
    ),
    UserModel(
      id: 'usr3',
      email: '',
      firstName: 'Hasan',
      lastName: 'Çetin',
      phone: '(532) 700-00-00',
      role: UserRole.resident,
      siteId: '',
      unitNo: '04',
      blockName: 'A Blok',
    ),
    UserModel(
      id: 'usr4',
      email: '',
      firstName: 'Ramazan',
      lastName: 'Aslan',
      phone: '(532) 900-00-00',
      role: UserRole.resident,
      siteId: '',
      unitNo: '06',
      blockName: 'A Blok',
    ),
  ];
  final Set<String> _selectedIds = {}; // Use a unique identifier
  bool _selectAll = false;

  String? _selectedBlock;
  String? _selectedStatus;
  String? _selectedDebt;

  final List<String> _blocks = ['Tümü', 'A Blok', 'B Blok', 'C Blok'];
  final List<String> _statuses = ['Tümü', 'Aktif Malik', 'Kiracı'];
  final List<String> _debts = [
    'Tümü',
    'Borcu olan',
    'Vadesi geçmiş borcu olan',
    'Borcu olmayan',
    '1.000 TL\'den fazla borcu olan',
    '5.000 TL\'den fazla borcu olan',
    '10.000 TL\'den fazla borcu olan',
    '15.000 TL\'den fazla borcu olan',
    '20.000 TL\'den fazla borcu olan',
  ];

  String _messageContent =
      'Sayın [Sakin Adı],\n\n[Blok-Daire] nolu bağımsız bölümünüze ait [Tutar] TL tutarında vadesi geçmiş aidat borcunuz bulunmaktadır. Ödemenizi mobil uygulama üzerinden veya banka kanalıyla yapabilirsiniz.\n\nİyi günler dileriz.\n\nSite Yönetimi';

  void _toggleSelectAll(bool? value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectAll = value ?? false;
        if (_selectAll) {
          _selectedIds.addAll(_recipients.map((e) => e.id));
        } else {
          _selectedIds.clear();
        }
        widget.onSelectionChanged(_selectedIds.length);
      });
    });
  }

  void _toggleRecipient(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
      _selectAll = _selectedIds.length == _recipients.length;
      widget.onSelectionChanged(_selectedIds.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // MESAJ ÖNİZLEME (New Top Section)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '4. MESAJ ÖNİZLEME',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMessagePreview(),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter Bar
          _buildFilterBar(),

          const Divider(height: 1),

          // Data Table area
          if (widget.isMobile)
            SizedBox(
              height: 400, // Fixed height specifically for the list on mobile
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: _buildListView(),
              ),
            )
          else
            Expanded(child: _buildDesktopTableView()),

          if (!widget.isMobile) _buildDesktopFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      // Keep alignment perfectly synced to horizontal container constraints of the DataTable below
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildDropdown(
              'TÜM BLOKLAR',
              _blocks,
              _selectedBlock,
              (v) => setState(() => _selectedBlock = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _buildDropdown(
              'AKTİF MALİK VE KİRACI',
              _statuses,
              _selectedStatus,
              (v) => setState(() => _selectedStatus = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: _buildDropdown(
              'BORCU OLAN',
              _debts,
              _selectedDebt,
              (v) => setState(() => _selectedDebt = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _recipients.length,
      itemBuilder: (context, index) {
        final r = _recipients[index];
        final id = r.id;
        final isSelected = _selectedIds.contains(id);
        final fullName = '${r.firstName} ${r.lastName}'.trim();

        return Column(
          children: [
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: isSelected,
              onChanged: (val) => _toggleRecipient(id, val),
              activeColor: AppColors.primary,
              title: Text(
                fullName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                '${r.blockName} • D:${r.unitNo} • ${r.roleDisplayName}',
              ),
              secondary: const Text(
                '500,00 ₺ (B)', // Fixed mock value matching images
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget _buildDesktopTableView() {
    return Column(
      children: [
        _buildDesktopTableHeader(),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: _recipients.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _buildDesktopTableRow(_recipients[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTableHeader() {
    return Container(
      height: 46,
      color: AppColors.primary.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Checkbox(
              value: _selectAll,
              onChanged: _toggleSelectAll,
              activeColor: AppColors.primary,
            ),
          ),
          Expanded(flex: 2, child: _buildColumnLabel('Blok')),
          Expanded(flex: 1, child: _buildColumnLabel('Kapı')),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildColumnLabel('Durumu')),
          Expanded(flex: 3, child: _buildColumnLabel('Ad Soyad')),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _buildColumnLabel('Telefon 1')),
          Expanded(flex: 3, child: _buildColumnLabel('Borç Bakiye')),
        ],
      ),
    );
  }

  Widget _buildDesktopTableRow(UserModel r) {
    final id = r.id;
    final isSelected = _selectedIds.contains(id);
    final fullName = '${r.firstName} ${r.lastName}'.trim();

    return InkWell(
      onTap: () => _toggleRecipient(id, !isSelected),
      child: Container(
        height: 46,
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Checkbox(
                value: isSelected,
                onChanged: (val) => _toggleRecipient(id, val),
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                r.blockName ?? '',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                r.unitNo ?? '',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Text(
                r.roleDisplayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                fullName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Text(
                r.phone,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: const Text(
                '500,00 ₺ (B)',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
    );
  }

  Widget _buildDesktopFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Seçilen Kişi Adedi: ${_selectedIds.length}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          ElevatedButton.icon(
            onPressed: _selectedIds.isNotEmpty ? () {} : null,
            icon: const Icon(Icons.send_rounded),
            label: Text('${_selectedIds.length} Kişiye Gönder'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _messageContent,
            style: const TextStyle(
              color: AppColors.textPrimary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Karakter: ${_messageContent.length} / 160 (1 SMS)',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: _openEditMessageDialog,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Düzenle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEditMessageDialog() {
    final TextEditingController controller = TextEditingController(
      text: _messageContent,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Mesajı Düzenle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Container(
            width: 500,
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Mesaj metnini girin...',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _messageContent = controller.text;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}
