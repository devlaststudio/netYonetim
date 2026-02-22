import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/navigation/dashboard_embed_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/member_mock_data.dart';
import 'member_detail_screen.dart';
import 'member_add_screen.dart';
import 'member_account_activity_screen.dart';
import 'collection_sheet.dart';
import '../../core/theme/custom_colors.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  late List<MemberData> _allMembers;
  String _searchQuery = '';
  String _activeStatusFilter = 'Aktif Malik ve Kiracı';
  String _activeBlockFilter = 'TÜM BLOKLAR';
  String _activeBalanceFilter = 'Tümü';

  final Set<String> _selectedIds = {};

  final _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _allMembers = MemberMockData.getMembers();
  }

  List<MemberData> get _filteredMembers {
    return _allMembers.where((m) {
      // Search filter
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          m.fullName.toLowerCase().contains(query) ||
          m.block.toLowerCase().contains(query) ||
          m.unitNo.toLowerCase().contains(query) ||
          m.phone.contains(query);

      // Block filter
      final matchesBlock =
          _activeBlockFilter == 'TÜM BLOKLAR' || m.block == _activeBlockFilter;

      // Status filter
      bool matchesStatus = true;
      switch (_activeStatusFilter) {
        case 'Malik':
          matchesStatus = m.status == MemberStatus.malik;
          break;
        case 'Kiracı':
          matchesStatus = m.status == MemberStatus.kiraci;
          break;
        case 'Aktif Malik ve Kiracı':
          matchesStatus = m.status != MemberStatus.bosDaire;
          break;
        case 'Boş Daire':
          matchesStatus = m.status == MemberStatus.bosDaire;
          break;
        case 'Tümü':
          matchesStatus = true;
          break;
      }

      // Balance filter
      bool matchesBalance = true;
      if (_activeBalanceFilter == 'Borçlu') {
        matchesBalance =
            m.totalBalance < 0; // Borç = negative balance typically?
        // Wait, current logic: hasDebt = totalBalance > 0 in UI?
        // Let's check _buildResidentCard: final hasDebt = member.totalBalance > 0;
        // So Debt means Balance > 0?
        matchesBalance = m.totalBalance > 0;
      } else if (_activeBalanceFilter == 'Alacaklı') {
        matchesBalance = m.totalBalance < 0;
      } else if (_activeBalanceFilter == 'Bakiyesiz') {
        matchesBalance = m.totalBalance == 0;
      }

      return matchesSearch && matchesBlock && matchesStatus && matchesBalance;
    }).toList();
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

  void _clearSelections() {
    setState(() => _selectedIds.clear());
  }

  void _toggleSelectAll() {
    final filtered = _filteredMembers;
    final allSelected =
        filtered.isNotEmpty &&
        filtered.every((m) => _selectedIds.contains(m.id));

    setState(() {
      if (allSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(filtered.map((m) => m.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMembers;
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
                'Sakinler & Daireler',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kIsWeb) ...[
                _buildWebFilterSection(filtered.length),
              ] else ...[
                _buildSearchBar(),
                _buildListHeader(filtered.length),
              ],
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    10,
                    1,
                    10,
                    _selectedIds.isNotEmpty ? 140 : 1,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildResidentCard(filtered[index]);
                  },
                ),
              ),
            ],
          ),
          if (_selectedIds.isNotEmpty) _buildSelectionFooter(),
        ],
      ),
      floatingActionButton: _selectedIds.isEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MemberAddScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
    );
  }

  Widget _buildSearchBar() {
    final hasActiveFilters =
        _activeBlockFilter != 'TÜM BLOKLAR' ||
        _activeStatusFilter != 'Aktif Malik ve Kiracı' ||
        _activeBalanceFilter != 'Tümü';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'İsim, blok, daire no ara...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _showFilterBottomSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasActiveFilters ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasActiveFilters
                      ? AppColors.primary
                      : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (hasActiveFilters ? AppColors.primary : Colors.black)
                        .withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: hasActiveFilters
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        initialBlock: _activeBlockFilter,
        initialStatus: _activeStatusFilter,
        initialBalance: _activeBalanceFilter,
        onApply: (block, status, balance) {
          setState(() {
            _activeBlockFilter = block;
            _activeStatusFilter = status;
            _activeBalanceFilter = balance;
          });
        },
      ),
    );
  }

  Widget _buildListHeader(int count) {
    final filtered = _filteredMembers;
    final allSelected =
        count > 0 && filtered.every((m) => _selectedIds.contains(m.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: allSelected,
                  onChanged: (_) => _toggleSelectAll(),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tümünü Seç',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($count)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Text(
                'Blok No',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.expand_more, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResidentCard(MemberData member) {
    final isSelected = _selectedIds.contains(member.id);
    final hasDebt = member.totalBalance > 0;

    // Boş daire → özel sönük kart
    if (member.status == MemberStatus.bosDaire) {
      return _buildEmptyApartmentCard(member);
    }

    if (kIsWeb) {
      return _buildWebResidentCard(member, isSelected, hasDebt);
    } else {
      return _buildMobileResidentCard(member, isSelected, hasDebt);
    }
  }

  /// WEB: Tablo başlığı ve Filtre satırı
  Widget _buildWebFilterSection(int count) {
    final filtered = _filteredMembers;
    final allSelected =
        count > 0 && filtered.every((m) => _selectedIds.contains(m.id));

    return Column(
      children: [
        // 1. Koyu Başlık Satırı
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: CustomColors.tableHeaderColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
              // Kolon 1: Blok / No / Ad Soyad
              const Expanded(
                flex: 3,
                child: Text(
                  'Daire & Sakin Bilgileri',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Kolon 2: Durumu
              const Expanded(
                flex: 2,
                child: Text(
                  'Durumu',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Kolon 3: İşlemler
              const Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    'İşlemler',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Kolon 4: Bakiye
              const Expanded(
                flex: 2,
                child: Text(
                  'Bakiye',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Filtre Input Satırı
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 42), // Checkbox area
              // Filtre 1: Blok Dropdown + Search
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Blok Dropdown
                    SizedBox(
                      width: 100, // Fixed width for block dropdown
                      height: 32,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _activeBlockFilter,
                            isExpanded: true,
                            icon: const Icon(Icons.expand_more, size: 16),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                            ),
                            items: MemberMockData.getBlocks().map((block) {
                              return DropdownMenuItem(
                                value: block,
                                child: Text(
                                  block,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _activeBlockFilter = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Search Field
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Ara...',
                            hintStyle: const TextStyle(fontSize: 11),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 8,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Filtre 2: Durum Dropdown
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activeStatusFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more, size: 16),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                        items: MemberMockData.getStatusFilters().map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _activeStatusFilter = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Filtre 3: İşlemler (Boş veya Spacer)
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 32,
                  child: Center(
                    child: Text(
                      'TÜMÜ',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Filtre 4: Bakiye Dropdown
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activeBalanceFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more, size: 16),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                        items: ['Tümü', 'Borçlu', 'Alacaklı', 'Bakiyesiz'].map((
                          b,
                        ) {
                          return DropdownMenuItem(
                            value: b,
                            child: Text(b, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _activeBalanceFilter = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Boş daire kartı — sönük, minimal
  Widget _buildEmptyApartmentCard(MemberData member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Boş daire ikonu
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.home_outlined,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 10),
          // Blok - Daire No
          Text(
            '${member.block}-${member.unitNo}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          // Boş Daire badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.textTertiary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'Boş Daire',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Web: Mevcut davranış — checkbox + tam kart
  Widget _buildWebResidentCard(
    MemberData member,
    bool isSelected,
    bool hasDebt,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(member.id),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ── Kolon 1: Blok-Daire + İsim ──
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Text(
                    '${member.block}-${member.unitNo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      member.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Kolon 2: Durum badge ──
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: member.status == MemberStatus.malik
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFF2ECC71).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: member.status == MemberStatus.malik
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : const Color(0xFF2ECC71).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    member.status.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: member.status == MemberStatus.malik
                          ? AppColors.primary
                          : const Color(0xFF2ECC71),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Kolon 3: Aksiyon ikonları ──
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionIcon(
                    icon: Icons.phone_outlined,
                    color: const Color(0xFF7F8C8D),
                    onTap: () {},
                  ),
                  _actionIcon(
                    icon: Icons.description_outlined,
                    color: const Color(0xFF2980B9),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MemberAccountActivityScreen(member: member),
                        ),
                      );
                    },
                  ),
                  _actionIcon(
                    icon: Icons.format_list_bulleted,
                    color: const Color(0xFFE67E22),
                    onTap: () {
                      _showDebtBreakdownSheet(member);
                    },
                  ),
                  _actionIcon(
                    icon: Icons.receipt_long_outlined,
                    color: const Color(0xFF27AE60),
                    onTap: () {
                      _showCollectionSheet(member);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Kolon 4: Bakiye ──
            Expanded(flex: 2, child: _buildBalanceBadge(hasDebt, member)),
          ],
        ),
      ),
    );
  }

  /// Mobil: Checkbox yok, long-press ile seçim, seçili ise kompakt kart
  Widget _buildMobileResidentCard(
    MemberData member,
    bool isSelected,
    bool hasDebt,
  ) {
    final inSelectionMode = _selectedIds.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (inSelectionMode) {
          _toggleSelection(member.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemberDetailScreen(member: member),
            ),
          );
        }
      },
      onLongPress: () => _toggleSelection(member.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 5),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isSelected ? 5 : 3,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(isSelected ? 10 : 16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: isSelected
            ? _buildCompactSelectedRow(member, hasDebt)
            : _buildFullMobileCardContent(member, hasDebt),
      ),
    );
  }

  /// Seçili kompakt satır: ✓ Blok-DaireNo İsim ············ Bakiye
  Widget _buildCompactSelectedRow(MemberData member, bool hasDebt) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          '${member.block}-${member.unitNo}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            member.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildBalanceBadge(hasDebt, member),
      ],
    );
  }

  /// Mobil tam kart içeriği (checkbox hariç, overflow-proof)
  Widget _buildFullMobileCardContent(MemberData member, bool hasDebt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Block-Unit + Name
        Row(
          children: [
            Text(
              '${member.block}-${member.unitNo}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                member.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Row 2: Status badge + ⋯ menu + balance
        Row(
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: member.status == MemberStatus.malik
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : const Color(0xFF2ECC71).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: member.status == MemberStatus.malik
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : const Color(0xFF2ECC71).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                member.status.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: member.status == MemberStatus.malik
                      ? AppColors.primary
                      : const Color(0xFF2ECC71),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // ⋯ More menu
            _buildMobileActionMenu(member),

            const Spacer(),

            // Balance badge
            _buildBalanceBadge(hasDebt, member),
          ],
        ),
      ],
    );
  }

  /// Mobil ⋯ popup menüsü
  Widget _buildMobileActionMenu(MemberData member) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_horiz,
          size: 20,
          color: AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.surface,
        elevation: 8,
        onSelected: (value) {
          switch (value) {
            case 'phone':
              // TODO: Implement phone call
              break;
            case 'account_summary':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MemberAccountActivityScreen(member: member),
                ),
              );
              break;
            case 'debt_breakdown':
              _showDebtBreakdownSheet(member);
              break;
            case 'collection':
              _showCollectionSheet(member);
              break;
          }
        },
        itemBuilder: (context) => [
          _buildPopupItem(
            'phone',
            Icons.phone_outlined,
            'Ara',
            const Color(0xFF7F8C8D),
          ),
          _buildPopupItem(
            'account_summary',
            Icons.description_outlined,
            'Hesap Özeti',
            const Color(0xFF2980B9),
          ),
          _buildPopupItem(
            'debt_breakdown',
            Icons.format_list_bulleted,
            'Borç Dökümü',
            const Color(0xFFE67E22),
          ),
          _buildPopupItem(
            'collection',
            Icons.receipt_long_outlined,
            'Tahsilat',
            const Color(0xFF27AE60),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Bakiye badge (ortak)
  Widget _buildBalanceBadge(bool hasDebt, MemberData member) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        '${hasDebt ? "-" : ""}${_currencyFormat.format(member.totalBalance.abs())}',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: hasDebt ? AppColors.error : AppColors.success,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: color),
    );
  }

  void _showDebtBreakdownSheet(MemberData member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                        color: const Color(0xFFE67E22).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Color(0xFFE67E22),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Borç Dökümü',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            member.fullName,
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
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),

              // Debt summary cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _debtSummaryCard(
                      'Aidat',
                      member.aidatBalance,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _debtSummaryCard(
                      'Yakıt',
                      member.yakitBalance,
                      const Color(0xFFE67E22),
                    ),
                    const SizedBox(width: 10),
                    _debtSummaryCard(
                      'Demirbaş',
                      member.demirbasBalance,
                      AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: member.totalBalance > 0
                        ? AppColors.error.withValues(alpha: 0.06)
                        : AppColors.success.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: member.totalBalance > 0
                          ? AppColors.error.withValues(alpha: 0.2)
                          : AppColors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Bakiye',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(member.totalBalance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: member.totalBalance > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Transaction list
              Expanded(
                child: member.transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Henüz borç kaydı bulunmuyor',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: member.transactions.length,
                        separatorBuilder: (_, a) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final t = member.transactions[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_upward,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              t.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '${t.block} - No: ${t.unitNo} • ${DateFormat('dd.MM.yyyy').format(t.dueDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Text(
                              _currencyFormat.format(t.debit),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _debtSummaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _currencyFormat.format(amount),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCollectionSheet(MemberData member) {
    // 1. Aynı kişiye ait (TC Kimlik No eşleşen) diğer taşınmazları bul
    // Eğer TC boş ise sadece kendisini alır.
    final allProperties = _allMembers.where((m) {
      if (m.tcKimlik.isEmpty) return m.id == member.id;
      return m.tcKimlik == member.tcKimlik;
    }).toList();

    // Listede kendisi yoksa ekle (teorik olarak olmalı ama güvenli olsun)
    if (!allProperties.any((m) => m.id == member.id)) {
      allProperties.add(member);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CollectionSheet(member: member, allProperties: allProperties);
      },
    );
  }

  Widget _buildSelectionFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedIds.length} Seçili',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _clearSelections,
                  child: const Text('Temizle'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    Icons.chat_bubble_outline,
                    'Mesaj',
                    true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(Icons.add_card, 'Borç Ekle', false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, bool primary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: primary ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: primary ? null : Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: primary ? Colors.white : AppColors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: primary ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String initialBlock;
  final String initialStatus;
  final String initialBalance;
  final Function(String, String, String) onApply;

  const _FilterBottomSheet({
    required this.initialBlock,
    required this.initialStatus,
    required this.initialBalance,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedBlock;
  late String _selectedStatus;
  late String _selectedBalance;

  @override
  void initState() {
    super.initState();
    _selectedBlock = widget.initialBlock;
    _selectedStatus = widget.initialStatus;
    _selectedBalance = widget.initialBalance;
  }

  void _reset() {
    setState(() {
      _selectedBlock = 'TÜM BLOKLAR';
      _selectedStatus = 'Aktif Malik ve Kiracı';
      _selectedBalance = 'Tümü';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrele',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(onPressed: _reset, child: const Text('Temizle')),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Block Filter
          const Text(
            'Blok Seçimi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MemberMockData.getBlocks().map((block) {
              final isSelected = _selectedBlock == block;
              return ChoiceChip(
                label: Text(block),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedBlock = block);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Status Filter
          const Text(
            'Durum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MemberMockData.getStatusFilters().map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedStatus = status);
                    },
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Balance Filter
          const Text(
            'Bakiye Durumu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Tümü', 'Borçlu', 'Alacaklı', 'Bakiyesiz'].map((
              balance,
            ) {
              final isSelected = _selectedBalance == balance;
              return ChoiceChip(
                label: Text(balance),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedBalance = balance);
                },
                selectedColor: AppColors.info,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  _selectedBlock,
                  _selectedStatus,
                  _selectedBalance,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Filtreleri Uygula',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
