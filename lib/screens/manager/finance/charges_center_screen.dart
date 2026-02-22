import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/dashboard_embed_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class ChargesCenterScreen extends StatefulWidget {
  const ChargesCenterScreen({super.key});

  @override
  State<ChargesCenterScreen> createState() => _ChargesCenterScreenState();
}

class _ChargesCenterScreenState extends State<ChargesCenterScreen> {
  bool _isMethodDrawerExpanded = true;

  ChargeMainType _selectedMainType = ChargeMainType.dues;
  ChargeCalculationMethod _selectedMethod = ChargeCalculationMethod.duesGroup;
  ChargeScope _selectedScope = ChargeScope.allUnits;
  ChargeDistributionType _selectedDistribution = ChargeDistributionType.equal;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _periodController = TextEditingController(
    text: '2026-02',
  );
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _duesGroupAmountController =
      TextEditingController(text: '95000');
  final TextEditingController _projectAmountController = TextEditingController(
    text: '72000',
  );
  final TextEditingController _manualAmountController = TextEditingController(
    text: '50000',
  );
  final TextEditingController _sqmUnitAmountController = TextEditingController(
    text: '18',
  );
  final TextEditingController _landShareUnitAmountController =
      TextEditingController(text: '22');
  final TextEditingController _personCountController = TextEditingController(
    text: '120',
  );
  final TextEditingController _personUnitAmountController =
      TextEditingController(text: '750');
  final TextEditingController _equalShareTotalController =
      TextEditingController(text: '120000');
  final TextEditingController _equalShareUnitCountController =
      TextEditingController(text: '120');

  String _selectedDuesGroup = ManagerFinanceMockData.chargeDuesGroups.first;
  String _selectedProject = ManagerFinanceMockData.operatingProjects.first;
  String _selectedProjectLine =
      ManagerFinanceMockData.operatingProjectLines.first;

  String _selectedBlock = ManagerFinanceMockData.blockOptions.first;
  String _selectedUnitGroup = ManagerFinanceMockData.unitGroupOptions.first;
  Map<String, String> _selectedPerson = ManagerFinanceMockData.members.first;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 15));

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
    _titleController.dispose();
    _periodController.dispose();
    _descriptionController.dispose();
    _duesGroupAmountController.dispose();
    _projectAmountController.dispose();
    _manualAmountController.dispose();
    _sqmUnitAmountController.dispose();
    _landShareUnitAmountController.dispose();
    _personCountController.dispose();
    _personUnitAmountController.dispose();
    _equalShareTotalController.dispose();
    _equalShareUnitCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;

    // Dashboard içine gömüldüğünde AppBar'ı gizle
    final isEmbedded = DashboardEmbedScope.hideBackButton(context);

    return Scaffold(
      appBar: isEmbedded
          ? null
          : AppBar(
              title: const Text('Borclandirma Merkezi'),
              actions: [
                IconButton(
                  tooltip: 'Veriyi Yenile',
                  onPressed: provider.loadMockData,
                  icon: const Icon(Icons.refresh),
                ),
                if (!isDesktop)
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Borclandirma Yontemleri',
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu_open),
                    ),
                  ),
              ],
            ),
      drawer: isDesktop
          ? null
          : Drawer(child: _buildMethodDrawer(isDesktop: false)),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _submitChargeBatch(context),
        icon: const Icon(Icons.playlist_add_check),
        label: const Text('Borclandir'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final content = _buildMainContent(provider, isDesktop);
                if (!isDesktop) {
                  return content;
                }

                return Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: _isMethodDrawerExpanded ? 330 : 92,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          right: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: _buildMethodDrawer(isDesktop: true),
                    ),
                    Expanded(child: content),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildMainContent(ManagerFinanceProvider provider, bool isDesktop) {
    final computedAmount = _computeChargeAmount();
    final targetCount = _estimateTargetCount();
    final estimatedPerTarget = targetCount == 0
        ? 0.0
        : computedAmount / targetCount.toDouble();

    return RefreshIndicator(
      onRefresh: provider.loadMockData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!isDesktop)
            ManagerSectionCard(
              title: 'Secili Borclandirma Yontemi',
              trailing: IconButton(
                tooltip: 'Yontem Menusu',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.tune),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Icon(_selectedMethod.icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedMethod.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ManagerSectionCard(
            title: 'Ana Tur ve Hedefleme',
            child: Column(
              children: [
                DropdownButtonFormField<ChargeMainType>(
                  initialValue: _selectedMainType,
                  decoration: const InputDecoration(labelText: 'Ana Tur'),
                  items: ChargeMainType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedMainType = value);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ChargeScope>(
                  initialValue: _selectedScope,
                  decoration: const InputDecoration(
                    labelText: 'Borclandirma Kapsami',
                  ),
                  items: ChargeScope.values
                      .map(
                        (scope) => DropdownMenuItem(
                          value: scope,
                          child: Text(scope.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedScope = value);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ChargeDistributionType>(
                  initialValue: _selectedDistribution,
                  decoration: const InputDecoration(labelText: 'Dagitim Tipi'),
                  items: ChargeDistributionType.values
                      .map(
                        (distribution) => DropdownMenuItem(
                          value: distribution,
                          child: Text(distribution.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedDistribution = value);
                  },
                ),
                const SizedBox(height: 10),
                _buildScopeSpecificField(),
              ],
            ),
          ),
          ManagerSectionCard(
            title: 'Yonteme Gore Alanlar',
            child: _buildMethodFields(),
          ),
          ManagerSectionCard(
            title: 'Genel Bilgiler',
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Borclandirma Basligi',
                    hintText: 'Orn: 2026 Subat Aidat Tahakkuku',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _periodController,
                  decoration: const InputDecoration(
                    labelText: 'Donem',
                    hintText: '2026-02',
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Vade: ${DateFormat('dd.MM.yyyy').format(_dueDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Aciklama',
                    hintText: 'Borclandirma notu',
                  ),
                ),
              ],
            ),
          ),
          ManagerSectionCard(
            title: 'Tahmini Sonuc',
            child: ManagerKpiGrid(
              items: [
                ManagerKpiItem(
                  label: 'Toplam Borclandirma',
                  value: formatCurrency(computedAmount),
                  color: AppColors.primary,
                ),
                ManagerKpiItem(
                  label: 'Hedef Kayit',
                  value: '$targetCount',
                  color: AppColors.info,
                ),
                ManagerKpiItem(
                  label: 'Kayit Basi Tutar',
                  value: formatCurrency(estimatedPerTarget),
                  color: AppColors.success,
                ),
                ManagerKpiItem(
                  label: 'Ana Tur',
                  value: _selectedMainType.label,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
          _buildAutoRulesCard(provider),
          _buildRecentBatchesCard(provider),
        ],
      ),
    );
  }

  Widget _buildScopeSpecificField() {
    switch (_selectedScope) {
      case ChargeScope.block:
        return DropdownButtonFormField<String>(
          initialValue: _selectedBlock,
          decoration: const InputDecoration(labelText: 'Blok Secimi'),
          items: ManagerFinanceMockData.blockOptions
              .map(
                (block) => DropdownMenuItem(value: block, child: Text(block)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedBlock = value);
          },
        );
      case ChargeScope.unitGroup:
        return DropdownButtonFormField<String>(
          initialValue: _selectedUnitGroup,
          decoration: const InputDecoration(labelText: 'Daire Grubu'),
          items: ManagerFinanceMockData.unitGroupOptions
              .map(
                (group) => DropdownMenuItem(value: group, child: Text(group)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedUnitGroup = value);
          },
        );
      case ChargeScope.person:
        return DropdownButtonFormField<Map<String, String>>(
          initialValue: _selectedPerson,
          decoration: const InputDecoration(labelText: 'Kisi Secimi'),
          items: ManagerFinanceMockData.members
              .map(
                (member) => DropdownMenuItem(
                  value: member,
                  child: Text(member['name']!),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedPerson = value);
          },
        );
      case ChargeScope.allUnits:
      case ChargeScope.excelImport:
      case ChargeScope.budgetBased:
        return const Align(
          alignment: Alignment.centerLeft,
          child: Text('Bu kapsam icin ek filtre gerekmiyor.'),
        );
    }
  }

  Widget _buildMethodFields() {
    switch (_selectedMethod) {
      case ChargeCalculationMethod.duesGroup:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedDuesGroup,
              decoration: const InputDecoration(labelText: 'Aidat Grubu'),
              items: ManagerFinanceMockData.chargeDuesGroups
                  .map(
                    (group) =>
                        DropdownMenuItem(value: group, child: Text(group)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedDuesGroup = value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _duesGroupAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Toplam Tutar',
                prefixText: '₺',
              ),
            ),
          ],
        );
      case ChargeCalculationMethod.operatingProject:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedProject,
              decoration: const InputDecoration(labelText: 'Isletme Projesi'),
              items: ManagerFinanceMockData.operatingProjects
                  .map(
                    (project) =>
                        DropdownMenuItem(value: project, child: Text(project)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedProject = value);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedProjectLine,
              decoration: const InputDecoration(labelText: 'Proje Kalemi'),
              items: ManagerFinanceMockData.operatingProjectLines
                  .map(
                    (line) => DropdownMenuItem(value: line, child: Text(line)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedProjectLine = value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _projectAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Proje Kalem Tutari',
                prefixText: '₺',
              ),
            ),
          ],
        );
      case ChargeCalculationMethod.manualAmount:
        return TextField(
          controller: _manualAmountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Toplam Borclandirma Tutari',
            prefixText: '₺',
          ),
        );
      case ChargeCalculationMethod.bySquareMeter:
        final sqmTotal = _estimateSquareMeterTotal();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _sqmUnitAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'm2 Birim Tutar',
                prefixText: '₺',
              ),
            ),
            const SizedBox(height: 8),
            Text('Tahmini toplam m2: ${sqmTotal.toStringAsFixed(0)}'),
          ],
        );
      case ChargeCalculationMethod.byLandShare:
        final landShareTotal = _estimateLandShareTotal();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _landShareUnitAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Arsa Payi Birim Tutar',
                prefixText: '₺',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tahmini toplam arsa payi: ${landShareTotal.toStringAsFixed(0)}',
            ),
          ],
        );
      case ChargeCalculationMethod.byPersonCount:
        return Column(
          children: [
            TextField(
              controller: _personCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kisi Sayisi'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _personUnitAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kisi Basi Tutar',
                prefixText: '₺',
              ),
            ),
          ],
        );
      case ChargeCalculationMethod.equalShare:
        return Column(
          children: [
            TextField(
              controller: _equalShareTotalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Toplam Tutar',
                prefixText: '₺',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _equalShareUnitCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Paylastirilacak Kayit Sayisi',
              ),
            ),
          ],
        );
    }
  }

  Widget _buildAutoRulesCard(ManagerFinanceProvider provider) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return ManagerSectionCard(
      title: 'Otomatik Borclandirma Kurallari',
      trailing: TextButton(
        onPressed: () => _showCreateAutoRuleDialog(context),
        child: const Text('Kural Ekle'),
      ),
      child: provider.autoChargeRules.isEmpty
          ? const ManagerEmptyState(
              icon: Icons.schedule_outlined,
              title: 'Otomatik kural yok',
              subtitle: 'Yeni bir otomatik borclandirma kurali ekleyin.',
            )
          : Column(
              children: provider.autoChargeRules
                  .map(
                    (rule) => ListTile(
                      dense: true,
                      leading: Icon(
                        rule.isActive
                            ? Icons.schedule_send
                            : Icons.schedule_outlined,
                        color: rule.isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      title: Text(rule.name),
                      subtitle: Text(
                        '${rule.scope.label} • ${rule.distributionType.label} • ${rule.frequency.label}\nSonraki: ${dateFormat.format(rule.nextRunAt)}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Simdi Calistir',
                            icon: const Icon(Icons.play_arrow),
                            onPressed: rule.isActive
                                ? () => context
                                      .read<ManagerFinanceProvider>()
                                      .runAutoChargeRuleNow(rule.id)
                                : null,
                          ),
                          Switch(
                            value: rule.isActive,
                            onChanged: (value) => context
                                .read<ManagerFinanceProvider>()
                                .toggleAutoChargeRule(rule.id, value),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildRecentBatchesCard(ManagerFinanceProvider provider) {
    if (provider.chargeBatches.isEmpty) {
      return const SizedBox(
        height: 300,
        child: ManagerEmptyState(
          icon: Icons.account_tree_outlined,
          title: 'Borclandirma kaydi yok',
          subtitle: 'Yeni bir batch olusturabilirsiniz.',
        ),
      );
    }

    return ManagerSectionCard(
      title: 'Son Borclandirma Kayitlari',
      child: Column(
        children: provider.chargeBatches
            .map(
              (batch) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: batch.status.color.withValues(alpha: 0.12),
                    child: Icon(batch.mainType.icon, color: batch.status.color),
                  ),
                  title: Text(batch.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${batch.mainType.label} • ${batch.calculationMethod.label}',
                      ),
                      Text(
                        '${batch.scope.label} • ${batch.distributionType.label} • ${batch.period}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Vade: ${DateFormat('dd.MM.yyyy').format(batch.dueDate)} • ${batch.items.length} kayit',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ManagerStatusChip(
                        label: batch.status.label,
                        color: batch.status.color,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatCurrency(batch.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  onTap: () => _showBatchDetail(context, batch),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMethodDrawer({required bool isDesktop}) {
    final showLabels = !isDesktop || _isMethodDrawerExpanded;

    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Row(
            children: [
              if (showLabels)
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Yontem Menusu',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              if (isDesktop)
                IconButton(
                  tooltip: _isMethodDrawerExpanded ? 'Daralt' : 'Genislet',
                  onPressed: () {
                    setState(() {
                      _isMethodDrawerExpanded = !_isMethodDrawerExpanded;
                    });
                  },
                  icon: Icon(
                    _isMethodDrawerExpanded
                        ? Icons.keyboard_double_arrow_left
                        : Icons.keyboard_double_arrow_right,
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(showLabels ? 12 : 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF9BBB59)),
              ),
              child: ListView.separated(
                itemCount: ChargeCalculationMethod.values.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final method = ChargeCalculationMethod.values[index];
                  final selected = method == _selectedMethod;

                  final tile = InkWell(
                    onTap: () {
                      _onMethodSelected(method, isDesktop);
                    },
                    child: Container(
                      height: 54,
                      padding: EdgeInsets.symmetric(
                        horizontal: showLabels ? 12 : 0,
                      ),
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      child: Row(
                        mainAxisAlignment: showLabels
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Icon(
                            method.icon,
                            size: 20,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          if (showLabels) const SizedBox(width: 10),
                          if (showLabels)
                            Expanded(
                              child: Text(
                                method.label,
                                style: TextStyle(
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );

                  if (!showLabels) {
                    return Tooltip(message: method.label, child: tile);
                  }

                  return tile;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onMethodSelected(ChargeCalculationMethod method, bool isDesktop) {
    setState(() {
      _selectedMethod = method;
      _selectedDistribution = _preferredDistributionForMethod(method);
    });

    if (!isDesktop) {
      Navigator.pop(context);
    }
  }

  ChargeDistributionType _preferredDistributionForMethod(
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

  int _estimateTargetCount() {
    switch (_selectedScope) {
      case ChargeScope.allUnits:
      case ChargeScope.excelImport:
      case ChargeScope.budgetBased:
        return ManagerFinanceMockData.units.length;
      case ChargeScope.block:
        return ManagerFinanceMockData.units
            .where((unit) => unit['label']!.startsWith(_selectedBlock))
            .length;
      case ChargeScope.unitGroup:
        if (_selectedUnitGroup == 'Dukkanlar') {
          return 14;
        }
        if (_selectedUnitGroup == 'Kiracilar') {
          return 72;
        }
        if (_selectedUnitGroup == 'Sadece Malikler') {
          return 86;
        }
        return ManagerFinanceMockData.units.length;
      case ChargeScope.person:
        return 1;
    }
  }

  double _estimateSquareMeterTotal() {
    final targetCount = _estimateTargetCount();
    if (targetCount <= 1) {
      return 135;
    }
    return targetCount * 132;
  }

  double _estimateLandShareTotal() {
    final targetCount = _estimateTargetCount();
    if (targetCount <= 1) {
      return 24;
    }
    return targetCount * 31;
  }

  double _parseDouble(TextEditingController controller) {
    final normalized = controller.text.replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? 0;
  }

  int _parseInt(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  double _computeChargeAmount() {
    switch (_selectedMethod) {
      case ChargeCalculationMethod.duesGroup:
        return _parseDouble(_duesGroupAmountController);
      case ChargeCalculationMethod.operatingProject:
        return _parseDouble(_projectAmountController);
      case ChargeCalculationMethod.manualAmount:
        return _parseDouble(_manualAmountController);
      case ChargeCalculationMethod.bySquareMeter:
        return _parseDouble(_sqmUnitAmountController) *
            _estimateSquareMeterTotal();
      case ChargeCalculationMethod.byLandShare:
        return _parseDouble(_landShareUnitAmountController) *
            _estimateLandShareTotal();
      case ChargeCalculationMethod.byPersonCount:
        return _parseDouble(_personUnitAmountController) *
            _parseInt(_personCountController);
      case ChargeCalculationMethod.equalShare:
        return _parseDouble(_equalShareTotalController);
    }
  }

  Map<String, String> _buildMethodParameters(double computedAmount) {
    final parameters = <String, String>{
      'anaTur': _selectedMainType.label,
      'yontem': _selectedMethod.label,
      'hesaplananTutar': computedAmount.toStringAsFixed(2),
      'kapsam': _selectedScope.label,
    };

    switch (_selectedScope) {
      case ChargeScope.block:
        parameters['blok'] = _selectedBlock;
        break;
      case ChargeScope.unitGroup:
        parameters['grup'] = _selectedUnitGroup;
        break;
      case ChargeScope.person:
        parameters['kisi'] = _selectedPerson['name'] ?? '';
        break;
      case ChargeScope.allUnits:
      case ChargeScope.excelImport:
      case ChargeScope.budgetBased:
        break;
    }

    switch (_selectedMethod) {
      case ChargeCalculationMethod.duesGroup:
        parameters['aidatGrubu'] = _selectedDuesGroup;
        break;
      case ChargeCalculationMethod.operatingProject:
        parameters['isletmeProjesi'] = _selectedProject;
        parameters['projeKalemi'] = _selectedProjectLine;
        break;
      case ChargeCalculationMethod.manualAmount:
        parameters['manuelTutar'] = _manualAmountController.text;
        break;
      case ChargeCalculationMethod.bySquareMeter:
        parameters['m2Birim'] = _sqmUnitAmountController.text;
        parameters['toplamM2'] = _estimateSquareMeterTotal().toStringAsFixed(0);
        break;
      case ChargeCalculationMethod.byLandShare:
        parameters['arsaPayiBirim'] = _landShareUnitAmountController.text;
        parameters['toplamArsaPayi'] = _estimateLandShareTotal()
            .toStringAsFixed(0);
        break;
      case ChargeCalculationMethod.byPersonCount:
        parameters['kisiSayisi'] = _personCountController.text;
        parameters['kisiBasi'] = _personUnitAmountController.text;
        break;
      case ChargeCalculationMethod.equalShare:
        parameters['esitPaylasimToplam'] = _equalShareTotalController.text;
        parameters['paylasimAdedi'] = _equalShareUnitCountController.text;
        break;
    }

    return parameters;
  }

  Future<void> _submitChargeBatch(BuildContext context) async {
    final computedAmount = _computeChargeAmount();

    if (computedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lutfen gecerli bir borclandirma tutari girin.'),
        ),
      );
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? '${_periodController.text.trim()} ${_selectedMainType.label} Tahakkuku'
        : _titleController.text.trim();

    final period = _periodController.text.trim().isEmpty
        ? '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}'
        : _periodController.text.trim();

    final financeProvider = context.read<ManagerFinanceProvider>();

    await financeProvider.createChargeBatch(
      title: title,
      mainType: _selectedMainType,
      calculationMethod: _selectedMethod,
      scope: _selectedScope,
      distribution: _selectedDistribution,
      period: period,
      dueDate: _dueDate,
      amount: computedAmount,
      methodParameters: _buildMethodParameters(computedAmount),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Borclandirma olusturuldu: ${formatCurrency(computedAmount)}',
        ),
      ),
    );
  }

  void _showBatchDetail(BuildContext context, ChargeBatch batch) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        batch.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  '${batch.mainType.label} • ${batch.calculationMethod.label}',
                ),
                Text(
                  '${batch.scope.label} • ${batch.distributionType.label} • ${batch.period}',
                ),
                const SizedBox(height: 8),
                if (batch.methodParameters.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: batch.methodParameters.entries
                        .take(6)
                        .map(
                          (entry) =>
                              Chip(label: Text('${entry.key}: ${entry.value}')),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: batch.items.length,
                    itemBuilder: (context, index) {
                      final item = batch.items[index];
                      return ListTile(
                        dense: true,
                        title: Text(item.unitLabel),
                        trailing: Text(formatCurrency(item.amount)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context
                              .read<ManagerFinanceProvider>()
                              .cancelChargeBatch(batch.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Iptal Et'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await context
                              .read<ManagerFinanceProvider>()
                              .regenerateChargeBatch(batch.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Yeniden Uret'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateAutoRuleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController(text: '350000');
    final dueDayController = TextEditingController(text: '10');
    ChargeScope selectedScope = ChargeScope.allUnits;
    ChargeDistributionType selectedDistribution = ChargeDistributionType.equal;
    SchedulerFrequency selectedFrequency = SchedulerFrequency.monthly;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Otomatik Borclandirma Kurali'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Kural Adi'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<ChargeScope>(
                      initialValue: selectedScope,
                      decoration: const InputDecoration(labelText: 'Kapsam'),
                      items: ChargeScope.values
                          .map(
                            (scope) => DropdownMenuItem(
                              value: scope,
                              child: Text(scope.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedScope = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<ChargeDistributionType>(
                      initialValue: selectedDistribution,
                      decoration: const InputDecoration(labelText: 'Dagitim'),
                      items: ChargeDistributionType.values
                          .map(
                            (distribution) => DropdownMenuItem(
                              value: distribution,
                              child: Text(distribution.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedDistribution = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<SchedulerFrequency>(
                      initialValue: selectedFrequency,
                      decoration: const InputDecoration(labelText: 'Siklik'),
                      items: SchedulerFrequency.values
                          .map(
                            (frequency) => DropdownMenuItem(
                              value: frequency,
                              child: Text(frequency.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedFrequency = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Aylik Tutar',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dueDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Vade Gunu (1-28)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Vazgec'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    final dueDay = int.tryParse(dueDayController.text);
                    if (amount == null ||
                        amount <= 0 ||
                        dueDay == null ||
                        dueDay < 1 ||
                        dueDay > 28) {
                      return;
                    }

                    await context
                        .read<ManagerFinanceProvider>()
                        .addAutoChargeRule(
                          name: nameController.text.isEmpty
                              ? 'Otomatik Tahakkuk'
                              : nameController.text,
                          scope: selectedScope,
                          distributionType: selectedDistribution,
                          frequency: selectedFrequency,
                          amount: amount,
                          dueDay: dueDay,
                        );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
