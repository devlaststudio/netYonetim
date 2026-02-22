import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/responsive_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

// Grup seçenekleri (çoktan seçmeli)
class _GroupOption {
  final String id;
  final String label;
  final IconData icon;
  final int estimatedCount;

  const _GroupOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.estimatedCount,
  });
}

const _predefinedGroups = [
  _GroupOption(
    id: 'aktif_malik_kiraci',
    label: 'Aktif Malikler ve Kiracilar',
    icon: Icons.groups,
    estimatedCount: 120,
  ),
  _GroupOption(
    id: 'malikler',
    label: 'Malikler',
    icon: Icons.real_estate_agent_outlined,
    estimatedCount: 80,
  ),
  _GroupOption(
    id: 'kiracilar',
    label: 'Kiracilar',
    icon: Icons.person_outline,
    estimatedCount: 40,
  ),
  _GroupOption(
    id: 'tum_1_1',
    label: 'Tum 1+1 Grubu',
    icon: Icons.apartment,
    estimatedCount: 30,
  ),
  _GroupOption(
    id: 'tum_2_1',
    label: 'Tum 2+1 Grubu',
    icon: Icons.apartment,
    estimatedCount: 45,
  ),
  _GroupOption(
    id: 'tum_3_1',
    label: 'Tum 3+1 Grubu',
    icon: Icons.apartment,
    estimatedCount: 35,
  ),
  _GroupOption(
    id: 'bos_daireler',
    label: 'Bos Daireler',
    icon: Icons.door_front_door_outlined,
    estimatedCount: 10,
  ),
  _GroupOption(
    id: 'a_blok',
    label: 'A Blok',
    icon: Icons.domain,
    estimatedCount: 40,
  ),
  _GroupOption(
    id: 'b_blok',
    label: 'B Blok',
    icon: Icons.domain,
    estimatedCount: 40,
  ),
  _GroupOption(
    id: 'c_blok',
    label: 'C Blok',
    icon: Icons.domain,
    estimatedCount: 40,
  ),
];

enum _PayerType { tenant, owner }

class ChargesWizardCodexScreen extends StatefulWidget {
  const ChargesWizardCodexScreen({super.key});

  @override
  State<ChargesWizardCodexScreen> createState() =>
      _ChargesWizardCodexScreenState();
}

class _ChargesWizardCodexScreenState extends State<ChargesWizardCodexScreen> {
  _PayerType _payerType = _PayerType.tenant;

  // Çoktan seçmeli hedef listesi (başlangıçta boş)
  final List<_GroupOption> _selectedGroups = [];
  final List<_TargetOption> _selectedIndividuals = [];
  final List<_TargetOption> _selectedExceptionIndividuals = [];

  ChargeCalculationMethod _selectedMethod =
      ChargeCalculationMethod.manualAmount;
  ChargeMainType _selectedMainType = ChargeMainType.dues;
  SchedulerFrequency _scheduleFrequency = SchedulerFrequency.monthly;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchExceptionController =
      TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _manualAmountController = TextEditingController(
    text: '50000',
  );

  DateTime _accrualDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 10));
  bool _isScheduled = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.chargeBatches.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchExceptionController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _manualAmountController.dispose();
    super.dispose();
  }

  List<_TargetOption> get _targetOptions {
    final unitTargets = ManagerFinanceMockData.units
        .map(
          (unit) => _TargetOption(
            id: unit['id']!,
            label: unit['label']!,
            subtitle: 'Daire',
          ),
        )
        .toList();

    final memberTargets = ManagerFinanceMockData.members
        .map(
          (member) => _TargetOption(
            id: member['id']!,
            label: member['name']!,
            subtitle: 'Kisi',
          ),
        )
        .toList();

    return [...memberTargets, ...unitTargets];
  }

  // _filteredTargets artık kullanılmıyor — arama sonuçları doğrudan _buildModeAndTargetCard içinde hesaplanıyor

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final isInitialLoading =
        provider.isLoading && provider.chargeBatches.isEmpty;

    return ManagerPageScaffold(
      title: 'Borclandirma Wizart Codex',
      actions: [
        IconButton(
          tooltip: 'Veriyi Yenile',
          onPressed: provider.loadMockData,
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 1080;
                      final isMobile = ResponsiveBreakpoints.isMobileWidth(
                        constraints.maxWidth,
                      );

                      if (!isWide) {
                        return _buildSingleColumn(isMobile: isMobile);
                      }

                      return _buildWideLayout();
                    },
                  ),
                ),
                _buildBottomActionButton(context),
              ],
            ),
    );
  }

  Widget _buildSingleColumn({required bool isMobile}) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, isMobile ? 16 : 20),
      child: Column(
        children: [
          _buildMethodSelectorCard(),
          _buildPaymentGroupCard(),
          _buildExceptionMembersCard(),
          _buildModeAndTargetCard(),
          _buildPayerCard(),
          _buildPlanningCard(),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildMethodSelectorCard(),
                _buildPaymentGroupCard(),
                _buildExceptionMembersCard(),
                _buildModeAndTargetCard(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildPayerCard(),
                _buildPlanningCard(),
                _buildSummaryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelectorCard() {
    return ManagerSectionCard(
      title: 'Borclandirma Yontemi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mevcut borclandirma yontemlerinden birini secin.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ChargeCalculationMethod.values
                .map(
                  (method) => ChoiceChip(
                    avatar: Icon(
                      method.icon,
                      size: 16,
                      color: _selectedMethod == method
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    label: Text(
                      _methodShortLabel(method),
                      style: TextStyle(
                        color: _selectedMethod == method
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: _selectedMethod == method
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: _selectedMethod == method,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _selectedMethod == method
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() {
                        _selectedMethod = method;
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExceptionMembersCard() {
    final searchQuery = _searchExceptionController.text.trim().toLowerCase();

    // Arama sonuçları (Sadece kişileri/daireleri filtrele)
    List<_TargetOption> searchResults = [];
    if (searchQuery.isNotEmpty) {
      searchResults = _targetOptions
          .where(
            (t) =>
                (t.label.toLowerCase().contains(searchQuery) ||
                    t.subtitle.toLowerCase().contains(searchQuery)) &&
                !_selectedExceptionIndividuals.any((st) => st.id == t.id),
          )
          .take(5)
          .toList();
    }

    final totalSelected = _selectedExceptionIndividuals.length;

    return ManagerSectionCard(
      title: 'Istisna Uyeler',
      trailing: totalSelected > 0
          ? TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedExceptionIndividuals.clear();
                });
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Temizle'),
            )
          : const SizedBox.shrink(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Unified Search Input ---
          TextField(
            controller: _searchExceptionController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              hintText: 'Isim, soyisim veya daire no ara...',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),

          // --- Dropdown / Arama Sonuçları ---
          if (searchQuery.isNotEmpty && searchResults.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final item = searchResults[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      child: Icon(
                        item.subtitle == 'Daire'
                            ? Icons.apartment_outlined
                            : Icons.person_outline,
                        size: 14,
                        color: AppColors.error,
                      ),
                    ),
                    title: Text(
                      item.label,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedExceptionIndividuals.add(item);
                        _searchExceptionController.clear();
                      });
                    },
                  );
                },
              ),
            ),
          ],

          // --- Seçilen Exception Tag'leri (Chips) ---
          if (_selectedExceptionIndividuals.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'Istisna Tutulanlar ($totalSelected kisi)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedExceptionIndividuals.map((target) {
                return Chip(
                  avatar: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Icon(
                      target.subtitle == 'Daire'
                          ? Icons.apartment_outlined
                          : Icons.person_outline,
                      size: 10,
                      color: AppColors.error,
                    ),
                  ),
                  label: Text(
                    target.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.error,
                  ),
                  onDeleted: () => setState(
                    () => _selectedExceptionIndividuals.removeWhere(
                      (t) => t.id == target.id,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  labelPadding: const EdgeInsets.only(right: 6, left: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeAndTargetCard() {
    final searchQuery = _searchController.text.trim().toLowerCase();

    // Arama sonuçları (Hem grupları hem kişileri filtrele)
    List<dynamic> searchResults = [];
    if (searchQuery.isNotEmpty) {
      // 1. Gruplar
      searchResults.addAll(
        _predefinedGroups.where(
          (g) =>
              g.label.toLowerCase().contains(searchQuery) &&
              !_selectedGroups.any((sg) => sg.id == g.id),
        ),
      );
      // 2. Bireyler
      searchResults.addAll(
        _targetOptions
            .where(
              (t) =>
                  (t.label.toLowerCase().contains(searchQuery) ||
                      t.subtitle.toLowerCase().contains(searchQuery)) &&
                  !_selectedIndividuals.any((st) => st.id == t.id),
            )
            .take(5),
      );
    } else {
      // Arama yoksa sadece seçilmeyen grupları göster
      searchResults.addAll(
        _predefinedGroups.where(
          (g) => !_selectedGroups.any((sg) => sg.id == g.id),
        ),
      );
    }

    final totalSelected =
        _selectedGroups.fold<int>(0, (sum, g) => sum + g.estimatedCount) +
        _selectedIndividuals.length;

    return ManagerSectionCard(
      title: 'Kisi / Daire Secimi',
      trailing: totalSelected > 0
          ? TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedGroups.clear();
                  _selectedIndividuals.clear();
                });
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Temizle'),
            )
          : const SizedBox.shrink(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Unified Search Input ---
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              hintText: 'Grup, isim, soyisim veya daire no ara...',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),

          // --- Dropdown / Arama Sonuçları ---
          if (searchQuery.isNotEmpty && searchResults.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final item = searchResults[index];

                  if (item is _GroupOption) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        item.icon,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Grup • ~${item.estimatedCount} kisi',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedGroups.add(item);
                          _searchController.clear();
                        });
                      },
                    );
                  } else if (item is _TargetOption) {
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          item.subtitle == 'Daire'
                              ? Icons.apartment_outlined
                              : Icons.person_outline,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        item.label,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndividuals.add(item);
                          _searchController.clear();
                        });
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],

          // --- Seçilen Tag'ler (Chips) ---
          if (_selectedGroups.isNotEmpty ||
              _selectedIndividuals.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedGroups.map(
                  (group) => Chip(
                    avatar: Icon(
                      group.icon,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      group.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(
                      () =>
                          _selectedGroups.removeWhere((g) => g.id == group.id),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    labelPadding: const EdgeInsets.only(right: 6, left: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ..._selectedIndividuals.map(
                  (target) => Chip(
                    avatar: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        target.subtitle == 'Daire'
                            ? Icons.apartment_outlined
                            : Icons.person_outline,
                        size: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    label: Text(
                      target.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppColors.surfaceVariant,
                    side: BorderSide(color: AppColors.border),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(
                      () => _selectedIndividuals.removeWhere(
                        (t) => t.id == target.id,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    labelPadding: const EdgeInsets.only(right: 6, left: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (searchQuery.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 32,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Henuz secim yapilamadi',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Grup (Malikler, A Blok vb.) veya kisi/daire eklemek icin yukarida arama yapin.',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Ödeme grubu seçimi (Aidat, Yakıt, Demirbaş vb.) — en üstte gösterilir
  Widget _buildPaymentGroupCard() {
    return ManagerSectionCard(
      title: 'Odeme Grubu',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: ChargeMainType.values
            .map(
              (type) => _CategoryTile(
                label: type.label,
                icon: type.icon,
                selected: _selectedMainType == type,
                onTap: () => setState(() => _selectedMainType = type),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Ödeme sorumlusu seçimi (Sakin / Kat Maliki)
  Widget _buildPayerCard() {
    return ManagerSectionCard(
      title: 'Odeme Sorumlusu',
      child: SegmentedButton<_PayerType>(
        segments: const [
          ButtonSegment<_PayerType>(
            value: _PayerType.tenant,
            icon: Icon(Icons.person_outline),
            label: Text('Sakin (Kiraci)'),
          ),
          ButtonSegment<_PayerType>(
            value: _PayerType.owner,
            icon: Icon(Icons.real_estate_agent_outlined),
            label: Text('Kat Maliki'),
          ),
        ],
        selected: {_payerType},
        onSelectionChanged: (selection) {
          setState(() => _payerType = selection.first);
        },
      ),
    );
  }

  // _buildPlanningCard...

  Widget _buildPlanningCard() {
    return ManagerSectionCard(
      title: 'Planlama ve Aciklama',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Islem Basligi',
                    hintText: 'Orn: Mart Aidat Tahakkuku',
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Toplam Tutar',
                    suffixText: '₺',
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: _pickAccrualDate,
                  controller: TextEditingController(
                    text: DateFormat('dd.MM.yyyy').format(_accrualDate),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Tahakkuk Tarihi',
                    suffixIcon: const Icon(
                      Icons.calendar_month,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: _pickDueDate,
                  controller: TextEditingController(
                    text: DateFormat('dd.MM.yyyy').format(_dueDate),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Son Odeme',
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zamanlanmis Islem',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text('Her donemde otomatik tekrar olusturur.'),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isScheduled,
                      onChanged: (value) {
                        setState(() => _isScheduled = value);
                        if (value && _titleController.text.isEmpty) {
                          _titleController.text =
                              'Zamanlanmis ${_selectedMainType.label}';
                        }
                      },
                    ),
                  ],
                ),
                if (_isScheduled) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Islem Ismi',
                      hintText: 'Orn: Aylik Aidat Otomatigi',
                      prefixIcon: const Icon(Icons.label_important_outline),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownInput<SchedulerFrequency>(
                    initialValue: _scheduleFrequency,
                    label: 'Tekrar Sikligi',
                    items: SchedulerFrequency.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(_frequencyLabel(item)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _scheduleFrequency = value);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Aciklama (Opsiyonel)',
              hintText: 'Islem detaylarini buraya ekleyin...',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final amount = _computeChargeAmount();
    final scope = _scopeByMode();
    final distribution = _distributionForMethod(_selectedMethod);
    final period = DateFormat('yyyy-MM').format(_dueDate);

    return ManagerSectionCard(
      title: 'Islem Ozet',
      child: Column(
        children: [
          _buildSummaryRow('Yontem', _selectedMethod.label),
          _buildSummaryRow('Kategori', _selectedMainType.label),
          _buildSummaryRow('Kapsam', scope.label),
          _buildSummaryRow('Dagitim', distribution.label),
          _buildSummaryRow(
            'Hedef',
            _selectedGroups.isEmpty && _selectedIndividuals.isEmpty
                ? 'Henuz secilmedi'
                : '${_selectedGroups.length} grup, ${_selectedIndividuals.length} kisi',
          ),
          _buildSummaryRow('Donem', period),
          const Divider(height: 20),
          _buildSummaryRow(
            'Toplam',
            formatCurrency(amount),
            valueStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _submit(context),
            icon: const Icon(Icons.playlist_add_check),
            label: const Text('Borclandirma Olustur'),
          ),
        ),
      ),
    );
  }

  // _buildModeSelector kaldırıldı — çoktan seçmeli hedef sistemi ile değiştirildi

  // _buildMethodFields ve _buildMethodDetailCard kaldırıldı — manuel tutar planlama kartına taşındı

  String _methodShortLabel(ChargeCalculationMethod method) {
    switch (method) {
      case ChargeCalculationMethod.duesGroup:
        return 'Aidat Grubu';
      case ChargeCalculationMethod.operatingProject:
        return 'Isletme Projesi';
      case ChargeCalculationMethod.manualAmount:
        return 'Tutar Girerek';
      case ChargeCalculationMethod.bySquareMeter:
        return 'Metrekare';
      case ChargeCalculationMethod.byLandShare:
        return 'Arsa Payi';
      case ChargeCalculationMethod.byPersonCount:
        return 'Kisi Sayisi';
      case ChargeCalculationMethod.equalShare:
        return 'Esit Paylasim';
    }
  }

  // Temizlik: Artık kullanılmayan yardımcı widgetlar kaldırıldı.

  Widget _buildDropdownInput<T>({
    required T initialValue,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value:
          initialValue, // Use 'value' instead of 'initialValue' for DropdownButtonFormField
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildSummaryRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  valueStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAccrualDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _accrualDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) {
      return;
    }

    setState(() => _accrualDate = picked);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) {
      return;
    }

    setState(() => _dueDate = picked);
  }

  Future<void> _submit(BuildContext context) async {
    final amount = _computeChargeAmount();
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gecerli bir tutar girmeniz gerekiyor.')),
      );
      return;
    }

    final provider = context.read<ManagerFinanceProvider>();
    final title = _titleController.text.trim().isEmpty
        ? (_isScheduled
              ? 'Zamanlanmis ${_selectedMainType.label}'
              : '${_selectedMainType.label} - ${_selectedGroups.length + _selectedIndividuals.length} hedef')
        : _titleController.text.trim();
    final scope = _scopeByMode();
    final distribution = _distributionForMethod(_selectedMethod);

    if (_isScheduled) {
      await provider.addAutoChargeRule(
        name: title,
        scope: scope,
        distributionType: distribution,
        frequency: _scheduleFrequency,
        amount: amount,
        dueDay: _dueDate.day,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Otomatik borclandirma kurali eklendi.')),
      );
      return;
    }

    await provider.createChargeBatch(
      title: title,
      mainType: _selectedMainType,
      calculationMethod: _selectedMethod,
      scope: scope,
      distribution: distribution,
      period: DateFormat('yyyy-MM').format(_accrualDate),
      dueDate: _dueDate,
      accrualDate: _accrualDate,
      amount: amount,
      methodParameters: {
        ..._buildMethodParameters(amount),
        if (_selectedExceptionIndividuals.isNotEmpty)
          'istisnalar': _selectedExceptionIndividuals
              .map((e) => e.label)
              .join(', '),
      },
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Borclandirma olusturuldu: ${formatCurrency(amount)}'),
      ),
    );
  }

  double _computeChargeAmount() {
    return _parse(_manualAmountController.text);
  }

  double _parse(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  ChargeScope _scopeByMode() {
    if (_selectedIndividuals.isNotEmpty && _selectedGroups.isEmpty) {
      return ChargeScope.person;
    }
    return ChargeScope.allUnits;
  }

  ChargeDistributionType _distributionForMethod(
    ChargeCalculationMethod method,
  ) {
    switch (method) {
      case ChargeCalculationMethod.bySquareMeter:
        return ChargeDistributionType.sqm;
      case ChargeCalculationMethod.byLandShare:
      case ChargeCalculationMethod.byPersonCount:
        return ChargeDistributionType.custom;
      case ChargeCalculationMethod.equalShare:
      case ChargeCalculationMethod.duesGroup:
        return ChargeDistributionType.equal;
      case ChargeCalculationMethod.operatingProject:
      case ChargeCalculationMethod.manualAmount:
        return ChargeDistributionType.fixed;
    }
  }

  Map<String, String> _buildMethodParameters(double amount) {
    final hedefLabel = _selectedGroups.isEmpty && _selectedIndividuals.isEmpty
        ? 'Henuz secilmedi'
        : '${_selectedGroups.map((g) => g.label).join(', ')}${_selectedIndividuals.isNotEmpty ? ', ${_selectedIndividuals.map((t) => t.label).join(', ')}' : ''}';

    return {
      'odemeSorumlusu': _payerType == _PayerType.tenant
          ? 'Kiraci'
          : 'Kat Maliki',
      'hedef': hedefLabel,
      'yontem': _selectedMethod.label,
      'hesaplananTutar': amount.toStringAsFixed(2),
      if (_descriptionController.text.trim().isNotEmpty)
        'aciklama': _descriptionController.text.trim(),
      if (_isScheduled) 'planli': _frequencyLabel(_scheduleFrequency),
    };
  }

  // _methodShortLabel kaldırıldı — arayüzden çıkarıldı

  // _modeLabel kaldırıldı — çoktan seçmeli hedef sistemi ile değiştirildi

  String _frequencyLabel(SchedulerFrequency value) {
    switch (value) {
      case SchedulerFrequency.daily:
        return 'Gunluk';
      case SchedulerFrequency.weekly:
        return 'Haftalik';
      case SchedulerFrequency.monthly:
        return 'Aylik';
    }
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : Border.all(color: AppColors.border.withValues(alpha: 0.3)),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TargetOption {
  final String id;
  final String label;
  final String subtitle;

  const _TargetOption({
    required this.id,
    required this.label,
    required this.subtitle,
  });
}
