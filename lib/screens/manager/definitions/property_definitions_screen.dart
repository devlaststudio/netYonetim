import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/theme/app_theme.dart';
import '../../properties/property_list_screen.dart' show PropertyItem;
import '../../../data/mock/member_mock_data.dart';
import 'sheets/property_add_sheet.dart';

class PropertyDefinitionsScreen extends StatefulWidget {
  const PropertyDefinitionsScreen({super.key});

  @override
  State<PropertyDefinitionsScreen> createState() =>
      _PropertyDefinitionsScreenState();
}

class _PropertyDefinitionsScreenState extends State<PropertyDefinitionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data State
  List<PropertyItem> _allProperties = [];
  String _searchQuery = '';
  String _activeBlockFilter = 'TÜM BLOKLAR';

  // Block Add Form State
  final _blockNameController = TextEditingController();
  final _blockDescController = TextEditingController();

  // Unit-group entry row controllers
  final _entryMetreKareController = TextEditingController();
  final _entryArsaPayiController = TextEditingController();
  final _entryDaireNoController = TextEditingController();
  String _entrySelectedType = '2+1';
  String _entrySelectedAidatGrubu = 'Daire';

  // List of added unit groups
  final List<_UnitGroupEntry> _unitGroups = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _loadProperties();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadProperties() {
    final members = MemberMockData.getMembers();
    final Map<String, PropertyItem> propertyMap = {};

    for (var m in members) {
      final key = '${m.block}_${m.unitNo}';

      if (!propertyMap.containsKey(key)) {
        propertyMap[key] = PropertyItem(block: m.block, unitNo: m.unitNo);
      }

      final current = propertyMap[key]!;

      if (m.status == MemberStatus.malik) {
        propertyMap[key] = PropertyItem(
          block: current.block,
          unitNo: current.unitNo,
          owner: m,
          tenant: current.tenant,
        );
      } else if (m.status == MemberStatus.kiraci) {
        propertyMap[key] = PropertyItem(
          block: current.block,
          unitNo: current.unitNo,
          owner: current.owner,
          tenant: m,
        );
      } else if (m.status == MemberStatus.bosDaire) {
        propertyMap[key] = PropertyItem(
          block: current.block,
          unitNo: current.unitNo,
          owner: m, // Treat empty as owner field
          tenant: current.tenant,
        );
      }
    }

    _allProperties = propertyMap.values.toList();
    _allProperties.sort((a, b) {
      int blockHeader = a.block.compareTo(b.block);
      if (blockHeader != 0) return blockHeader;
      int? uA = int.tryParse(a.unitNo);
      int? uB = int.tryParse(b.unitNo);
      if (uA != null && uB != null) return uA.compareTo(uB);
      return a.unitNo.compareTo(b.unitNo);
    });
  }

  List<PropertyItem> get _filteredProperties {
    return _allProperties.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          p.block.toLowerCase().contains(query) ||
          p.unitNo.toLowerCase().contains(query) ||
          (p.owner?.fullName.toLowerCase().contains(query) ?? false) ||
          (p.tenant?.fullName.toLowerCase().contains(query) ?? false);

      final matchesBlock =
          _activeBlockFilter == 'TÜM BLOKLAR' || p.block == _activeBlockFilter;

      return matchesQuery && matchesBlock;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar Area
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.apartment_outlined), text: 'Blok İşlemleri'),
              Tab(
                icon: Icon(Icons.home_work_outlined),
                text: 'Daire İşlemleri',
              ),
              Tab(icon: Icon(Icons.groups_outlined), text: 'Aidat Grupları'),
            ],
          ),
        ),
        // Tab Content Area
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBlockOperationsTab(),
              _buildUnitOperationsTab(),
              _buildUnitGroupsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlockOperationsTab() {
    final apartmentTypes = [
      '1+0',
      '1+1',
      '2+1',
      '3+1',
      '4+1',
      'Stüdyo',
      'Ofis',
      'Dükkan',
    ];
    final aidatGroups = ['Daire', 'Dükkan', 'Yönetici', 'Ofis'];
    final totalUnits = _unitGroups.fold<int>(
      0,
      (sum, g) => sum + g.daireNolari.length,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YENİ BLOK EKLE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _blockTextField(
                      'Blok Adı *',
                      'Örn: A Blok',
                      _blockNameController,
                    ),
                    const SizedBox(height: 10),
                    _blockTextField(
                      'Açıklama',
                      'Opsiyonel',
                      _blockDescController,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _blockTextField(
                      'Blok Adı *',
                      'Örn: A Blok',
                      _blockNameController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _blockTextField(
                      'Açıklama',
                      'Opsiyonel',
                      _blockDescController,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'DAİRE GRUBU EKLE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Her daire grubunu ayrı ayrı ekleyin (ör: 1+1 daireler, 2+1 daireler)',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTypeDropdown(apartmentTypes)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _blockTextField(
                            'm²',
                            'Örn: 120',
                            _entryMetreKareController,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _blockTextField(
                            'Arsa Payı',
                            'Örn: 2/77',
                            _entryArsaPayiController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _buildAidatGrubuDropdown(aidatGroups)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _blockTextField(
                            'Daire No (virgülle)',
                            'Örn: 1, 2, 3, 5, 7',
                            _entryDaireNoController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            height: 34,
                            child: ElevatedButton.icon(
                              onPressed: _addUnitGroup,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text(
                                'Ekle',
                                style: TextStyle(fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    child: _buildTypeDropdown(apartmentTypes),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: _blockTextField(
                      'm²',
                      'Örn: 120',
                      _entryMetreKareController,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: _blockTextField(
                      'Arsa Payı',
                      'Örn: 2/77',
                      _entryArsaPayiController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: _buildAidatGrubuDropdown(aidatGroups),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _blockTextField(
                      'Daire No (virgülle)',
                      'Örn: 1, 2, 3, 5',
                      _entryDaireNoController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: _addUnitGroup,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text(
                          'Ekle',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_unitGroups.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        _tableHeader('Tip', flex: 1),
                        _tableHeader('m²', flex: 1),
                        _tableHeader('Arsa Payı', flex: 1),
                        _tableHeader('Aidat Gr.', flex: 1),
                        _tableHeader('Daire No', flex: 3),
                        _tableHeader('Adet', flex: 1),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                  ...List.generate(_unitGroups.length, (i) {
                    final g = _unitGroups[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.border, width: 0.5),
                        ),
                        color: i.isEven
                            ? Colors.white
                            : const Color(0xFFFAFBFC),
                      ),
                      child: Row(
                        children: [
                          _tableCell(g.daireTipi, flex: 1, bold: true),
                          _tableCell('${g.metreKare} m²', flex: 1),
                          _tableCell(g.arsaPayi, flex: 1),
                          _tableCell(g.aidatGrubu, flex: 1),
                          _tableCell(g.daireNolari.join(', '), flex: 3),
                          _tableCell(
                            '${g.daireNolari.length}',
                            flex: 1,
                            bold: true,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 32,
                            child: IconButton(
                              onPressed: () =>
                                  setState(() => _unitGroups.removeAt(i)),
                              icon: const Icon(Icons.close, size: 16),
                              color: AppColors.error,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Toplam: $totalUnits daire',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: _unitGroups.isEmpty ? null : () {},
                icon: const Icon(Icons.save_outlined, size: 16),
                label: Text(
                  'Bloğu Kaydet${totalUnits > 0 ? ' ($totalUnits daire)' : ''}',
                  style: const TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 18),
          Text(
            'KAYITLI BLOKLAR',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: MemberMockData.getBlocks()
                .where((b) => b != 'TÜM BLOKLAR')
                .map((b) {
                  return Container(
                    width: 240,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                b,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(
                              Icons.door_front_door_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Daire: 24',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.landscape_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Arsa: 1/48',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: ['2+1', '3+1'].map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  void _addUnitGroup() {
    final daireNoText = _entryDaireNoController.text.trim();
    final metreKare = _entryMetreKareController.text.trim();
    final arsaPayi = _entryArsaPayiController.text.trim();
    if (daireNoText.isEmpty || metreKare.isEmpty || arsaPayi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen tüm alanları doldurun.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    final daireNolari = daireNoText
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (daireNolari.isEmpty) return;
    setState(() {
      _unitGroups.add(
        _UnitGroupEntry(
          daireTipi: _entrySelectedType,
          metreKare: metreKare,
          arsaPayi: arsaPayi,
          aidatGrubu: _entrySelectedAidatGrubu,
          daireNolari: daireNolari,
        ),
      );
      _entryDaireNoController.clear();
      _entryMetreKareController.clear();
      _entryArsaPayiController.clear();
    });
  }

  Widget _buildTypeDropdown(List<String> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daire Tipi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _entrySelectedType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              items: types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _entrySelectedType = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAidatGrubuDropdown(List<String> groups) {
    const groupMeta = {
      'Daire': {'icon': Icons.apartment, 'color': Color(0xFF4A90D9)},
      'Dükkan': {'icon': Icons.storefront, 'color': Color(0xFFE8913A)},
      'Yönetici': {'icon': Icons.admin_panel_settings, 'color': Color(0xFF9C5EC7)},
      'Ofis': {'icon': Icons.business_center, 'color': Color(0xFF2BA89D)},
    };

    Widget buildItem(String g, {bool dense = false}) {
      final meta = groupMeta[g];
      final color = (meta?['color'] as Color?) ?? AppColors.primary;
      final icon = (meta?['icon'] as IconData?) ?? Icons.group;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dense ? 6 : 8,
            height: dense ? 6 : 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: dense ? 4 : 6),
          Icon(icon, size: dense ? 13 : 15, color: color),
          SizedBox(width: dense ? 3 : 5),
          Text(g, style: TextStyle(fontSize: dense ? 12 : 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aidat Grubu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _entrySelectedAidatGrubu,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              selectedItemBuilder: (context) {
                return groups.map((g) => Align(alignment: Alignment.centerLeft, child: buildItem(g, dense: true))).toList();
              },
              items: groups.map((g) {
                final meta = groupMeta[g];
                final color = (meta?['color'] as Color?) ?? AppColors.primary;
                final icon = (meta?['icon'] as IconData?) ?? Icons.group;
                return DropdownMenuItem(
                  value: g,
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 8),
                      Text(g, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) { if (v != null) setState(() => _entrySelectedAidatGrubu = v); },
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _tableCell(
    String text, {
    int flex = 1,
    bool bold = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: color ?? AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _blockTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            filled: true,
            fillColor: const Color(0xFFF1F3F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitOperationsTab() {
    final filtered = _filteredProperties;

    return Column(
      children: [
        // Action Bar (Header)
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              const Text(
                'DAİRE İŞLEMLERİ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.1,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: const Text('Daire Ayarları'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.people_alt_outlined, size: 18),
                    label: const Text('Toplu Üye Sihirbazı'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                    label: const Text('Eski Daire Üyesi Ekle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const PropertyAddSheet(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Yeni Daire'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _activeBlockFilter,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: MemberMockData.getBlocks()
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _activeBlockFilter = val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Ara (Ad, Blok, No)...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Desktop Header if Web
        if (kIsWeb)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Blok / No',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Daire Kat Maliği',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Daire Kiracı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'İşlemler',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // List Section
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildPropertyCard(filtered[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(PropertyItem item) {
    if (kIsWeb) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blok / No
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.block,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.unitNo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Malik
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.owner != null &&
                      item.owner!.status != MemberStatus.bosDaire) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.owner!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.owner!.phone,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Maliği Kaldır',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Malik Tanımla',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Kiracı
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.tenant != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.tenant!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.tenant!.phone,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Kiracıyı Kaldır',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Kiracı Tanımla',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // İşlemler
            Expanded(
              flex: 1,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text(
                    'Daireyi Sil',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: AppColors.textSecondary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile Layout
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.block} Blok - No: ${item.unitNo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text(
                      'Daireyi Sil',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: AppColors.textSecondary,
                      elevation: 0,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  // Malik Half
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Malik',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (item.owner != null &&
                            item.owner!.status != MemberStatus.bosDaire) ...[
                          Text(
                            item.owner!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          Text(
                            item.owner!.phone,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                color: AppColors.error.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Maliği Kaldır',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            '-',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Malik Tanımla',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Kiracı Half
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kiracı',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (item.tenant != null) ...[
                          Text(
                            item.tenant!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          Text(
                            item.tenant!.phone,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                color: AppColors.error.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Kiracıyı Kaldır',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            '-',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: BorderSide(
                                color: Colors.orange.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Kiracı Tanımla',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildUnitGroupsTab() {
    final defaultGroups = ['Daire', 'Dükkan', 'Yönetici', 'Ofis'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title ---
          const Text(
            'YENİ AİDAT GRUBU EKLE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 20),

          // --- Add Form ---
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _blockTextField(
                      'Grup Adı *',
                      'Örn: Daire',
                      TextEditingController(),
                    ),
                    const SizedBox(height: 12),
                    _blockTextField(
                      'Açıklama',
                      'Opsiyonel',
                      TextEditingController(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_circle, size: 20),
                        label: const Text('Grubu Kaydet'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BC34A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _blockTextField(
                      'Grup Adı *',
                      'Örn: Daire',
                      TextEditingController(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _blockTextField(
                      'Açıklama',
                      'Opsiyonel',
                      TextEditingController(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle, size: 20),
                      label: const Text('Grubu Kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // --- Existing Groups ---
          const Text(
            'KAYITLI AİDAT GRUPLARI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: defaultGroups.map((group) {
              final colors = {
                'Daire': Colors.blue,
                'Dükkan': Colors.orange,
                'Yönetici': Colors.purple,
                'Ofis': Colors.teal,
              };
              final color = colors[group] ?? AppColors.primary;

              return Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              group,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {},
                              child: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Varsayılan grup',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _UnitGroupEntry {
  final String daireTipi;
  final String metreKare;
  final String arsaPayi;
  final String aidatGrubu;
  final List<String> daireNolari;

  _UnitGroupEntry({
    required this.daireTipi,
    required this.metreKare,
    required this.arsaPayi,
    required this.aidatGrubu,
    required this.daireNolari,
  });
}
