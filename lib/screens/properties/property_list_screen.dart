import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/navigation/dashboard_embed_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/custom_colors.dart';
import '../../data/mock/member_mock_data.dart';
import '../members/member_account_activity_screen.dart';
import '../members/collection_sheet.dart';
import '../members/charge_add_sheet.dart'; // Added import
import '../members/member_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class PropertyItem {
  final String block;
  final String unitNo;
  final MemberData? owner;
  final MemberData? tenant;

  PropertyItem({
    required this.block,
    required this.unitNo,
    this.owner,
    this.tenant,
  });

  // Derived properties
  MemberData? get resident => tenant ?? owner; // Tenant if exists, else Owner
  bool get isEmpty =>
      owner == null &&
      tenant == null; // Should not happen based on logic, but good to have
  bool get isOccupied =>
      !isEmpty &&
      (tenant != null ||
          (owner != null && owner!.status != MemberStatus.bosDaire));
  // If owner status is 'bosDaire', treated as Empty.

  // Balance logic: Sum of owner + tenant balances? Or just resident?
  // User asked for "bakiye ile filtreleme". Usually debt follows the unit or the active resident.
  // Let's sum owner and tenant balances for the Property Balance.
  double get totalBalance =>
      (owner?.totalBalance ?? 0) + (tenant?.totalBalance ?? 0);

  String get id => '${block}_$unitNo'; // Unique ID for selection
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late List<PropertyItem> _allProperties;
  String _unitSearchQuery = '';
  String _nameSearchQuery = '';
  String _activeBlockFilter = 'TÜM BLOKLAR';
  String _activeStatusFilter = 'Tümü';
  String _activeBalanceFilter = 'Tümü';

  String? _expandedPropertyId;
  String? _expandedRole; // 'owner' or 'tenant'

  final Set<String> _selectedIds = {};
  final ScrollController _horizontalScrollController = ScrollController();

  final _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
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
        // If owner
        propertyMap[key] = PropertyItem(
          block: current.block,
          unitNo: current.unitNo,
          owner: m,
          tenant: current.tenant,
        );
      } else if (m.status == MemberStatus.kiraci) {
        // If tenant
        propertyMap[key] = PropertyItem(
          block: current.block,
          unitNo: current.unitNo,
          owner: current.owner,
          tenant: m,
        );
      } else if (m.status == MemberStatus.bosDaire) {
        // Treat as owner for data structure, but status will be empty
        propertyMap[key] = PropertyItem(
          block: current.block,
          unitNo: current.unitNo,
          owner: m, // Owner entry with empty status
          tenant: current.tenant,
        );
      }
    }

    _allProperties = propertyMap.values.toList();

    // Sort by Block then Unit
    _allProperties.sort((a, b) {
      int blockHeader = a.block.compareTo(b.block);
      if (blockHeader != 0) return blockHeader;
      // Unit sort (try parse int)
      int? uA = int.tryParse(a.unitNo);
      int? uB = int.tryParse(b.unitNo);
      if (uA != null && uB != null) return uA.compareTo(uB);
      return a.unitNo.compareTo(b.unitNo);
    });
  }

  List<PropertyItem> get _filteredProperties {
    return _allProperties.where((p) {
      // Unit Filter (Search by No)
      final unitQuery = _unitSearchQuery.toLowerCase();
      final matchesUnit =
          unitQuery.isEmpty ||
          p.block.toLowerCase().contains(unitQuery) ||
          p.unitNo.toLowerCase().contains(unitQuery);

      // Name Filter (Search by Name)
      final nameQuery = _nameSearchQuery.toLowerCase();
      final matchesName =
          nameQuery.isEmpty ||
          (p.owner?.fullName.toLowerCase().contains(nameQuery) ?? false) ||
          (p.tenant?.fullName.toLowerCase().contains(nameQuery) ?? false);

      // Block Filter
      final matchesBlock =
          _activeBlockFilter == 'TÜM BLOKLAR' || p.block == _activeBlockFilter;

      // Status Filter
      // 'Dolu', 'Boş', 'Tümü'
      bool matchesStatus = true;
      final isRealEmpty =
          (p.owner?.status == MemberStatus.bosDaire) && p.tenant == null;

      if (_activeStatusFilter == 'Dolu') {
        matchesStatus = !isRealEmpty;
      } else if (_activeStatusFilter == 'Boş') {
        matchesStatus = isRealEmpty;
      }

      // Balance Filter
      bool matchesBalance = true;
      final balance = p.totalBalance;
      if (_activeBalanceFilter == 'Borçlu') {
        matchesBalance = balance > 0;
      } else if (_activeBalanceFilter == 'Alacaklı') {
        matchesBalance = balance < 0;
      } else if (_activeBalanceFilter == 'Bakiyesiz') {
        matchesBalance = balance == 0;
      }

      return matchesUnit &&
          matchesName &&
          matchesBlock &&
          matchesStatus &&
          matchesBalance;
    }).toList();
  }

  void _toggleSelectAll() {
    final filtered = _filteredProperties;
    final allSelected =
        filtered.isNotEmpty &&
        filtered.every((p) => _selectedIds.contains(p.id));

    setState(() {
      if (allSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(filtered.map((p) => p.id));
      }
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleExpandCard(String id, String role) {
    setState(() {
      if (_expandedPropertyId == id && _expandedRole == role) {
        // Collapse if already expanded for the same role
        _expandedPropertyId = null;
        _expandedRole = null;
      } else {
        // Expand new role
        _expandedPropertyId = id;
        _expandedRole = role;
      }
    });
  }

  // --- Helper Methods ---

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 20,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size, color: color),
    );
  }

  void _showChargeAddSheet(PropertyItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ChargeAddSheet(propertyItem: item),
        );
      },
    );
  }

  void _showCollectionSheet(MemberData member) {
    // 1. Aynı kişiye ait (TC Kimlik No eşleşen) diğer taşınmazları bul
    // Using Owner for property lookup if tenant is same?
    // In PropertyList, we will iterate over _allProperties to find matches.

    // We need to find properties where this member is either Owner or Tenant.
    // Assuming member.id is unique per unit relation, or we match by TC/Name.
    // If member has TC, match by TC.

    final allProperties = MemberMockData.getMembers().where((m) {
      if (m.tcKimlik.isNotEmpty && member.tcKimlik.isNotEmpty) {
        return m.tcKimlik == member.tcKimlik;
      }
      return m.id == member.id;
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CollectionSheet(member: member, allProperties: allProperties);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProperties;
    // Dashboard içine gömüldüğünde AppBar'ı gizle
    final isEmbedded = DashboardEmbedScope.hideBackButton(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isEmbedded
          ? null
          : AppBar(
              centerTitle: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              title: const Text(
                'Taşınmaz Listesi',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: kIsWeb
          ? LayoutBuilder(
              builder: (context, constraints) {
                const double minWidth = 1000.0;
                // If screen is wide enough, use screen width. If not, user scrolls horizontally.
                final contentWidth = constraints.maxWidth < minWidth
                    ? minWidth
                    : constraints.maxWidth;

                return Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: contentWidth,
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          _buildWebFilterSection(filtered.length),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildPropertyCard(filtered[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Column(
              children: [
                _buildMobileFilterSection(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildPropertyCard(filtered[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWebFilterSection(int count) {
    final filtered = _filteredProperties;
    final allSelected =
        count > 0 && filtered.every((p) => _selectedIds.contains(p.id));

    return Column(
      children: [
        // Header Row
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: CustomColors.tableHeaderColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Checkbox(
                  value: allSelected,
                  onChanged: (_) => _toggleSelectAll(),
                  checkColor: AppColors.primary,
                  activeColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text('Taşınmaz', style: _headerStyle),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                  ), // Slight padding to shift right
                  child: const Text('Malik', style: _headerStyle),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                flex: 3,
                child: Text('Sakin / Kiracı', style: _headerStyle),
              ),
              const SizedBox(width: 12),
              const Expanded(
                flex: 2,
                child: Center(child: Text('İşlemler', style: _headerStyle)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                flex: 2,
                child: Text(
                  'Bakiye',
                  textAlign: TextAlign.right,
                  style: _headerStyle,
                ),
              ),
            ],
          ),
        ),
        // Filter Row
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 42),
              // Block & Unit Filter
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 32,
                      child: _buildDropdown(
                        value: _activeBlockFilter,
                        items: MemberMockData.getBlocks(),
                        onChanged: (val) =>
                            setState(() => _activeBlockFilter = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: TextField(
                          onChanged: (val) => setState(
                            () => _unitSearchQuery = val,
                          ), // Use _unitSearchQuery
                          decoration: _filterInputDecoration(
                            'No...',
                          ), // Changed hint
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Name Search & Status Filter (Combined Flex 6)
              Expanded(
                flex: 6,
                child: Row(
                  children: [
                    // Name Search (Covers Malik and part of Sakin visually)
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 32,
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _nameSearchQuery = val),
                          decoration: _filterInputDecoration('Ad Soyad Ara...'),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Filter
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 32,
                        child: Row(
                          children: [
                            const Text(
                              'Durum: ',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Expanded(
                              child: _buildDropdown(
                                value: _activeStatusFilter,
                                items: ['Tümü', 'Dolu', 'Boş'],
                                onChanged: (val) =>
                                    setState(() => _activeStatusFilter = val!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              const Expanded(flex: 2, child: SizedBox()), // Actions
              const SizedBox(width: 12),
              // Balance Filter
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 32,
                  child: _buildDropdown(
                    value: _activeBalanceFilter,
                    items: ['Tümü', 'Borçlu', 'Alacaklı', 'Bakiyesiz'],
                    onChanged: (val) =>
                        setState(() => _activeBalanceFilter = val!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _headerStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  InputDecoration _filterInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, size: 16),
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
          items: items
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMobileFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _nameSearchQuery = val),
              decoration: InputDecoration(
                hintText: 'Ad Soyad Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _showMobileFilterSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              child: const Icon(Icons.filter_list, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrele',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Blok',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _activeBlockFilter,
                    items: MemberMockData.getBlocks(),
                    onChanged: (val) {
                      setState(() => _activeBlockFilter = val!);
                      setStateSheet(() => _activeBlockFilter = val!);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Durum',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _activeStatusFilter,
                    items: ['Tümü', 'Dolu', 'Boş'],
                    onChanged: (val) {
                      setState(() => _activeStatusFilter = val!);
                      setStateSheet(() => _activeStatusFilter = val!);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bakiye Durumu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _activeBalanceFilter,
                    items: ['Tümü', 'Borçlu', 'Alacaklı', 'Bakiyesiz'],
                    onChanged: (val) {
                      setState(() => _activeBalanceFilter = val!);
                      setStateSheet(() => _activeBalanceFilter = val!);
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Uygula',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPropertyCard(PropertyItem item) {
    final isSelected = _selectedIds.contains(item.id);
    final isRealEmpty =
        (item.owner?.status == MemberStatus.bosDaire) && item.tenant == null;

    if (kIsWeb) {
      final mainCard = Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: isRealEmpty
              ? AppColors.surface.withOpacity(0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            MemberData? primary;
            MemberData? secondary;

            if (item.tenant != null &&
                item.owner != null &&
                item.owner!.status != MemberStatus.bosDaire) {
              primary = item.owner;
              secondary = item.tenant;
            } else {
              primary = item.resident ?? item.owner;
            }

            if (primary != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MemberDetailScreen(member: primary!, tenant: secondary),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(item.id),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Taşınmaz
                Expanded(
                  flex: 2,
                  child: Text(
                    '${item.block} - ${item.unitNo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Malik
                Expanded(
                  flex: 3,
                  child:
                      item.owner != null &&
                          item.owner!.status != MemberStatus.bosDaire
                      ? Row(
                          children: [
                            _actionIcon(
                              icon: Icons.edit_square,
                              color: AppColors.textSecondary,
                              size: 14,
                              onTap: () => _toggleExpandCard(item.id, 'owner'),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.owner!.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            _actionIcon(
                              icon: Icons.add_box,
                              color: AppColors.textSecondary,
                              size: 14,
                              onTap: () => _toggleExpandCard(item.id, 'owner'),
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                '-',
                                style: TextStyle(color: AppColors.textTertiary),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 12),
                // Sakin
                Expanded(
                  flex: 3,
                  child: item.tenant != null
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: _actionIcon(
                                icon: Icons.edit_square,
                                color: AppColors.textSecondary,
                                size: 14,
                                onTap: () =>
                                    _toggleExpandCard(item.id, 'tenant'),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.tenant!.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'Kiracı',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : (item.owner != null &&
                            item.owner!.status != MemberStatus.bosDaire)
                      ? Row(
                          children: [
                            _actionIcon(
                              icon: Icons.add_box,
                              color: AppColors.textSecondary,
                              size: 14,
                              onTap: () => _toggleExpandCard(item.id, 'tenant'),
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'Malik Oturuyor',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            _actionIcon(
                              icon: Icons.add_box,
                              color: AppColors.textSecondary,
                              size: 14,
                              onTap: () => _toggleExpandCard(item.id, 'tenant'),
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'BOŞ',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 12),
                // İşlemler
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionIcon(
                        icon: Icons.phone_outlined,
                        color: const Color(0xFF7F8C8D),
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _actionIcon(
                        icon: Icons.description_outlined,
                        color: const Color(0xFF2980B9),
                        onTap: () {
                          if (item.resident != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemberAccountActivityScreen(
                                  member: item.resident!,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _actionIcon(
                        icon: Icons.format_list_bulleted,
                        color: const Color(0xFFE67E22),
                        onTap: () {
                          if (item.isEmpty || !item.isOccupied) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Boş daireye borç eklenemez.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          _showChargeAddSheet(item);
                        },
                      ),
                      const SizedBox(width: 12),
                      _actionIcon(
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFF27AE60),
                        onTap: () {
                          if (item.resident != null) {
                            _showCollectionSheet(item.resident!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Bakiye
                Expanded(
                  flex: 2,
                  child: Text(
                    _currencyFormat.format(item.totalBalance),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: item.totalBalance > 0
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      return Column(
        children: [
          mainCard,
          if (_expandedPropertyId == item.id) _buildQuickReplaceCard(item),
        ],
      );
    } else {
      // Mobile Card Implementation
      final mainCard = Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            MemberData? primary;
            MemberData? secondary;

            if (item.tenant != null &&
                item.owner != null &&
                item.owner!.status != MemberStatus.bosDaire) {
              primary = item.owner;
              secondary = item.tenant;
            } else {
              primary = item.resident ?? item.owner;
            }

            if (primary != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MemberDetailScreen(member: primary!, tenant: secondary),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Block - Unit | Status
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isRealEmpty
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isRealEmpty
                            ? 'BOŞ'
                            : (item.tenant != null ? 'Kiracı' : 'Malik'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isRealEmpty
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                // Body: Owner/Resident Info
                Row(
                  children: [
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
                          Row(
                            children: [
                              _actionIcon(
                                icon:
                                    item.owner != null &&
                                        item.owner!.status !=
                                            MemberStatus.bosDaire
                                    ? Icons.edit_square
                                    : Icons.add_box,
                                color: AppColors.textSecondary,
                                size: 14,
                                onTap: () =>
                                    _toggleExpandCard(item.id, 'owner'),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.owner?.fullName ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sakin',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              _actionIcon(
                                icon: item.tenant != null
                                    ? Icons.edit_square
                                    : Icons.add_box,
                                color: AppColors.textSecondary,
                                size: 14,
                                onTap: () =>
                                    _toggleExpandCard(item.id, 'tenant'),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.tenant?.fullName ??
                                      (isRealEmpty ? '-' : 'Malik Oturuyor'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Balance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Bakiye',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(item.totalBalance),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: item.totalBalance > 0
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _mobileActionButton(
                      icon: Icons.phone_outlined,
                      label: 'Ara',
                      color: const Color(0xFF7F8C8D),
                      onTap: () {},
                    ),
                    _mobileActionButton(
                      icon: Icons.description_outlined,
                      label: 'Ekstre',
                      color: const Color(0xFF2980B9),
                      onTap: () {
                        if (item.resident != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberAccountActivityScreen(
                                member: item.resident!,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    _mobileActionButton(
                      icon: Icons.format_list_bulleted,
                      label: 'Borç Ekle',
                      color: const Color(0xFFE67E22),
                      onTap: () {
                        if (item.isEmpty || !item.isOccupied) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Boş daireye borç eklenemez.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        _showChargeAddSheet(item);
                      },
                    ),
                    _mobileActionButton(
                      icon: Icons.receipt_long_outlined,
                      label: 'Tahsilat',
                      color: const Color(0xFF27AE60),
                      onTap: () {
                        if (item.resident != null) {
                          _showCollectionSheet(item.resident!);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      return Column(
        children: [
          mainCard,
          if (_expandedPropertyId == item.id) _buildQuickReplaceCard(item),
        ],
      );
    }
  }

  Widget _buildQuickReplaceCard(PropertyItem item) {
    bool isOwner = _expandedRole == 'owner';
    MemberData? targetMember = isOwner ? item.owner : item.tenant;

    if (targetMember == null && !isOwner) {
      // Adding a new tenant — show a simple form
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_add_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Yeni Kiracı Ekle',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => _toggleExpandCard(item.id, _expandedRole!),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(label: 'Ad Soyad', initialValue: ''),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'TC Kimlik No',
                      initialValue: '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(label: 'Telefon', initialValue: ''),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _toggleExpandCard(item.id, _expandedRole!),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _toggleExpandCard(item.id, _expandedRole!);
                    },
                    icon: const Icon(Icons.save, size: 14),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Default to owner if somehow null and isOwner
    MemberData? m = targetMember;

    bool hasDebt = m != null && m.totalBalance > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              children: [
                Icon(
                  isOwner ? Icons.home_work_outlined : Icons.person_outline,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isOwner ? 'Malik Değiştir' : 'Kiracı Değiştir',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => _toggleExpandCard(item.id, _expandedRole!),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
              ],
            ),
            const Divider(height: 16),

            // --- Current Member Info (read-only) ---
            if (m != null) ...[
              Text(
                isOwner ? 'Mevcut Malik' : 'Mevcut Kiracı',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        m.fullName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.phone,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      m.phone,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (!isOwner) ...[
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          // remove tenant logic
                          _toggleExpandCard(item.id, _expandedRole!);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_remove,
                                size: 12,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Çıkar',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // --- New Member Form ---
            Text(
              isOwner ? 'Yeni Malik' : 'Yeni Kiracı',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(label: 'Ad Soyad', initialValue: ''),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'TC Kimlik No',
                    initialValue: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(label: 'Telefon', initialValue: ''),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _toggleExpandCard(item.id, _expandedRole!),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: hasDebt
                      ? 'Kişinin borcu bulunduğu için doğrudan değiştirilemez.'
                      : '',
                  child: ElevatedButton.icon(
                    onPressed: hasDebt
                        ? null
                        : () {
                            // replace logic
                            _toggleExpandCard(item.id, _expandedRole!);
                          },
                    icon: const Icon(Icons.swap_horiz, size: 14),
                    label: const Text('Değiştir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        ),
        const SizedBox(height: 2),
        TextFormField(
          initialValue: initialValue,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _mobileActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
