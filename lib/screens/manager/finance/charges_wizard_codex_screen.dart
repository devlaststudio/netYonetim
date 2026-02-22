import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/responsive_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

enum _ChargeWizardMode { individual, bulk, automatic }

enum _PayerType { tenant, owner }

class ChargesWizardCodexScreen extends StatefulWidget {
  const ChargesWizardCodexScreen({super.key});

  @override
  State<ChargesWizardCodexScreen> createState() =>
      _ChargesWizardCodexScreenState();
}

class _ChargesWizardCodexScreenState extends State<ChargesWizardCodexScreen> {
  _ChargeWizardMode _wizardMode = _ChargeWizardMode.individual;
  _PayerType _payerType = _PayerType.tenant;

  ChargeCalculationMethod _selectedMethod = ChargeCalculationMethod.duesGroup;
  ChargeMainType _selectedMainType = ChargeMainType.dues;
  SchedulerFrequency _scheduleFrequency = SchedulerFrequency.monthly;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
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

  DateTime _dueDate = DateTime.now().add(const Duration(days: 10));
  bool _isScheduled = false;

  String _selectedDuesGroup = ManagerFinanceMockData.chargeDuesGroups.first;
  String _selectedProject = ManagerFinanceMockData.operatingProjects.first;
  String _selectedProjectLine =
      ManagerFinanceMockData.operatingProjectLines.first;
  _TargetOption? _selectedTarget;

  @override
  void initState() {
    super.initState();
    _selectedTarget = _targetOptions.first;
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
    _titleController.dispose();
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

  List<_TargetOption> _filteredTargets() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _targetOptions.take(6).toList();
    }

    return _targetOptions
        .where(
          (target) =>
              target.label.toLowerCase().contains(query) ||
              target.subtitle.toLowerCase().contains(query),
        )
        .take(6)
        .toList();
  }

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
          _buildModeAndTargetCard(),
          _buildCategoryAndPayerCard(),
          _buildMethodDetailCard(),
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
            flex: 7,
            child: Column(
              children: [
                _buildMethodSelectorCard(),
                _buildModeAndTargetCard(),
                _buildMethodDetailCard(),
                _buildPlanningCard(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              children: [_buildCategoryAndPayerCard(), _buildSummaryCard()],
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

  Widget _buildModeAndTargetCard() {
    final targets = _filteredTargets();

    return ManagerSectionCard(
      title: 'Kisi / Daire Secimi',
      trailing: TextButton(
        onPressed: () {
          setState(() {
            _searchController.clear();
          });
        },
        child: const Text('Favori Listeler'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModeSelector(),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              hintText: 'Ad, soyad veya daire no ara...',
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
          const SizedBox(height: 10),
          if (targets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Filtreye uygun kayit bulunamadi.'),
            )
          else
            ...targets.map(
              (target) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedTarget?.id == target.id
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      target.subtitle == 'Daire'
                          ? Icons.apartment_outlined
                          : Icons.person_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(target.label),
                  subtitle: Text(target.subtitle),
                  trailing: _selectedTarget?.id == target.id
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedTarget = target;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndPayerCard() {
    return ManagerSectionCard(
      title: 'Odeme Sorumlusu ve Kategori',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<_PayerType>(
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
          const SizedBox(height: 14),
          Wrap(
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
        ],
      ),
    );
  }

  Widget _buildMethodDetailCard() {
    return ManagerSectionCard(
      title: 'Yonteme Gore Alanlar',
      child: _buildMethodFields(),
    );
  }

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
                child: _buildReadOnlyValue(
                  label: 'Tutar',
                  value: formatCurrency(_computeChargeAmount()),
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
                      },
                    ),
                  ],
                ),
                if (_isScheduled) ...[
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
          _buildSummaryRow('Secim Modu', _modeLabel(_wizardMode)),
          _buildSummaryRow('Yontem', _selectedMethod.label),
          _buildSummaryRow('Kategori', _selectedMainType.label),
          _buildSummaryRow('Kapsam', scope.label),
          _buildSummaryRow('Dagitim', distribution.label),
          _buildSummaryRow('Hedef', _selectedTarget?.label ?? 'Tum kayitlar'),
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

  Widget _buildModeSelector() {
    return SegmentedButton<_ChargeWizardMode>(
      segments: const [
        ButtonSegment<_ChargeWizardMode>(
          value: _ChargeWizardMode.individual,
          icon: Icon(Icons.person_outline),
          label: Text('Bireysel'),
        ),
        ButtonSegment<_ChargeWizardMode>(
          value: _ChargeWizardMode.bulk,
          icon: Icon(Icons.group_work_outlined),
          label: Text('Toplu'),
        ),
        ButtonSegment<_ChargeWizardMode>(
          value: _ChargeWizardMode.automatic,
          icon: Icon(Icons.settings_suggest_outlined),
          label: Text('Otomatik'),
        ),
      ],
      selected: {_wizardMode},
      onSelectionChanged: (selection) {
        setState(() {
          _wizardMode = selection.first;
          if (_wizardMode == _ChargeWizardMode.automatic) {
            _isScheduled = true;
          }
        });
      },
    );
  }

  Widget _buildMethodFields() {
    switch (_selectedMethod) {
      case ChargeCalculationMethod.duesGroup:
        return Column(
          children: [
            _buildDropdownInput<String>(
              initialValue: _selectedDuesGroup,
              label: 'Aidat Grubu',
              items: ManagerFinanceMockData.chargeDuesGroups
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedDuesGroup = value);
              },
            ),
            const SizedBox(height: 10),
            _amountInput(
              controller: _duesGroupAmountController,
              label: 'Toplam Tutar',
            ),
          ],
        );
      case ChargeCalculationMethod.operatingProject:
        return Column(
          children: [
            _buildDropdownInput<String>(
              initialValue: _selectedProject,
              label: 'Isletme Projesi',
              items: ManagerFinanceMockData.operatingProjects
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedProject = value);
              },
            ),
            const SizedBox(height: 10),
            _buildDropdownInput<String>(
              initialValue: _selectedProjectLine,
              label: 'Proje Kalemi',
              items: ManagerFinanceMockData.operatingProjectLines
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedProjectLine = value);
              },
            ),
            const SizedBox(height: 10),
            _amountInput(
              controller: _projectAmountController,
              label: 'Toplam Tutar',
            ),
          ],
        );
      case ChargeCalculationMethod.manualAmount:
        return _amountInput(
          controller: _manualAmountController,
          label: 'Toplam Borclandirma Tutari',
        );
      case ChargeCalculationMethod.bySquareMeter:
        return _amountInput(
          controller: _sqmUnitAmountController,
          label: 'm2 Basina Tutar',
          suffixText: '₺',
        );
      case ChargeCalculationMethod.byLandShare:
        return _amountInput(
          controller: _landShareUnitAmountController,
          label: 'Arsa Payi Katsayi Tutari',
          suffixText: '₺',
        );
      case ChargeCalculationMethod.byPersonCount:
        return Column(
          children: [
            _amountInput(
              controller: _personCountController,
              label: 'Kisi Sayisi',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _amountInput(
              controller: _personUnitAmountController,
              label: 'Kisi Basi Tutar',
            ),
          ],
        );
      case ChargeCalculationMethod.equalShare:
        return Column(
          children: [
            _amountInput(
              controller: _equalShareTotalController,
              label: 'Toplam Tutar',
            ),
            const SizedBox(height: 10),
            _amountInput(
              controller: _equalShareUnitCountController,
              label: 'Paylasim Adedi',
              keyboardType: TextInputType.number,
            ),
          ],
        );
    }
  }

  Widget _amountInput({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
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
    );
  }

  Widget _buildReadOnlyValue({required String label, required String value}) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
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
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

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
        ? '${_selectedMainType.label} - ${_modeLabel(_wizardMode)}'
        : _titleController.text.trim();
    final scope = _scopeByMode();
    final distribution = _distributionForMethod(_selectedMethod);

    if (_wizardMode == _ChargeWizardMode.automatic && _isScheduled) {
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
      period: DateFormat('yyyy-MM').format(_dueDate),
      dueDate: _dueDate,
      amount: amount,
      methodParameters: _buildMethodParameters(amount),
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
    switch (_selectedMethod) {
      case ChargeCalculationMethod.duesGroup:
        return _parse(_duesGroupAmountController.text);
      case ChargeCalculationMethod.operatingProject:
        return _parse(_projectAmountController.text);
      case ChargeCalculationMethod.manualAmount:
        return _parse(_manualAmountController.text);
      case ChargeCalculationMethod.bySquareMeter:
        return _parse(_sqmUnitAmountController.text) * _estimatedSquareMeter();
      case ChargeCalculationMethod.byLandShare:
        return _parse(_landShareUnitAmountController.text) *
            _estimatedLandShare();
      case ChargeCalculationMethod.byPersonCount:
        return _parse(_personCountController.text) *
            _parse(_personUnitAmountController.text);
      case ChargeCalculationMethod.equalShare:
        return _parse(_equalShareTotalController.text);
    }
  }

  double _estimatedSquareMeter() {
    if (_wizardMode == _ChargeWizardMode.individual) {
      return 120;
    }
    return ManagerFinanceMockData.units.length * 120;
  }

  double _estimatedLandShare() {
    if (_wizardMode == _ChargeWizardMode.individual) {
      return 35;
    }
    return ManagerFinanceMockData.units.length * 35;
  }

  double _parse(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  ChargeScope _scopeByMode() {
    switch (_wizardMode) {
      case _ChargeWizardMode.individual:
        return ChargeScope.person;
      case _ChargeWizardMode.bulk:
        return ChargeScope.allUnits;
      case _ChargeWizardMode.automatic:
        return ChargeScope.budgetBased;
    }
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
    return {
      'secimModu': _modeLabel(_wizardMode),
      'odemeSorumlusu': _payerType == _PayerType.tenant
          ? 'Kiraci'
          : 'Kat Maliki',
      'hedef': _selectedTarget?.label ?? 'Tum Daireler',
      'yontem': _selectedMethod.label,
      'hesaplananTutar': amount.toStringAsFixed(2),
      if (_descriptionController.text.trim().isNotEmpty)
        'aciklama': _descriptionController.text.trim(),
      if (_isScheduled) 'planli': _frequencyLabel(_scheduleFrequency),
    };
  }

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

  String _modeLabel(_ChargeWizardMode mode) {
    switch (mode) {
      case _ChargeWizardMode.individual:
        return 'Bireysel';
      case _ChargeWizardMode.bulk:
        return 'Toplu';
      case _ChargeWizardMode.automatic:
        return 'Otomatik';
    }
  }

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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(16),
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
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontSize: 13,
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
