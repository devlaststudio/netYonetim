import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/navigation/dashboard_embed_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/custom_colors.dart';
import '../../data/mock/member_mock_data.dart';

class SmartMemberQueryScreen extends StatefulWidget {
  const SmartMemberQueryScreen({super.key});

  @override
  State<SmartMemberQueryScreen> createState() => _SmartMemberQueryScreenState();
}

enum _QueryScope {
  allMembers,
  activeOwnersAndTenants,
  currentResidents,
  owners,
  tenants,
  activeOwners,
  activeTenants,
  formerOwners,
  formerTenants,
}

class _SmartMemberQueryScreenState extends State<SmartMemberQueryScreen> {
  static const List<_FieldOption> _propertyFieldOptions = [
    _FieldOption(key: 'block', label: 'Blok Tanımı'),
    _FieldOption(key: 'unitNo', label: 'Kapı No'),
    _FieldOption(key: 'duesGroup', label: 'Aidat Grubu'),
    _FieldOption(key: 'floor', label: 'Kat'),
    _FieldOption(key: 'squareMeter', label: 'Metrekare'),
    _FieldOption(key: 'landShare', label: 'Arsa Payı'),
    _FieldOption(key: 'fuelMeterNo', label: 'Yakıt Sayaç No'),
    _FieldOption(key: 'hotWaterMeterNo', label: 'Sıcak Su Sayaç No'),
    _FieldOption(key: 'coldWaterMeterNo', label: 'Soğuk Su Sayaç No'),
    _FieldOption(key: 'electricMeterNo', label: 'Elektrik Sayaç No'),
  ];

  static const List<_FieldOption> _memberFieldOptions = [
    _FieldOption(key: 'gender', label: 'Cinsiyet'),
    _FieldOption(key: 'fullName', label: 'Ad Soyad'),
    _FieldOption(key: 'entryDate', label: 'Giriş Tarihi'),
    _FieldOption(key: 'exitDate', label: 'Çıkış Tarihi'),
    _FieldOption(key: 'share', label: 'Hisse'),
    _FieldOption(key: 'balance', label: 'Bakiye'),
    _FieldOption(key: 'tcKimlik', label: 'Tc Kimlik Numarası'),
    _FieldOption(key: 'phone1', label: 'Cep Telefonu 1'),
    _FieldOption(key: 'phone2', label: 'Cep Telefonu 2'),
    _FieldOption(key: 'email1', label: 'Eposta Adresi 1'),
    _FieldOption(key: 'email2', label: 'Eposta Adresi 2'),
    _FieldOption(key: 'birthDate', label: 'Doğum Tarihi'),
    _FieldOption(key: 'bloodGroup', label: 'Kan Grubu'),
    _FieldOption(key: 'sector', label: 'Sektör'),
    _FieldOption(key: 'workPlace', label: 'İş Yeri'),
    _FieldOption(key: 'workAddress', label: 'İş Adresi'),
    _FieldOption(key: 'homeAddress', label: 'Ev Adresi'),
    _FieldOption(key: 'note', label: 'Not'),
  ];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final List<String> _bloodGroups = const [
    'A Rh+',
    'A Rh-',
    'B Rh+',
    'B Rh-',
    'AB Rh+',
    'AB Rh-',
    '0 Rh+',
    '0 Rh-',
  ];

  late final List<MemberData> _allMembers;
  late List<MemberData> _queryResults;

  _QueryScope _selectedScope = _QueryScope.allMembers;
  final Set<String> _selectedPropertyFields = {'block', 'unitNo'};
  final Set<String> _selectedMemberFields = {'fullName', 'balance', 'phone1'};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allMembers = MemberMockData.getMembers();
    _queryResults = _applyQuery();
  }

  List<MemberData> _applyQuery() {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final results = _allMembers.where((member) {
      if (!_matchesScope(member)) return false;
      if (normalizedQuery.isEmpty) return true;

      final searchable = <String>[
        member.fullName.toLowerCase(),
        member.block.toLowerCase(),
        member.unitNo.toLowerCase(),
        member.tcKimlik.toLowerCase(),
        member.phone.toLowerCase(),
        member.email.toLowerCase(),
      ];
      return searchable.any((text) => text.contains(normalizedQuery));
    }).toList();

    results.sort((a, b) {
      final blockCompare = a.block.compareTo(b.block);
      if (blockCompare != 0) return blockCompare;

      final unitA = int.tryParse(a.unitNo);
      final unitB = int.tryParse(b.unitNo);
      if (unitA != null && unitB != null) {
        return unitA.compareTo(unitB);
      }
      return a.unitNo.compareTo(b.unitNo);
    });

    return results;
  }

  bool _matchesScope(MemberData member) {
    switch (_selectedScope) {
      case _QueryScope.allMembers:
        return true;
      case _QueryScope.activeOwnersAndTenants:
        return member.status != MemberStatus.bosDaire;
      case _QueryScope.currentResidents:
        return member.status != MemberStatus.bosDaire;
      case _QueryScope.owners:
        return member.status == MemberStatus.malik;
      case _QueryScope.tenants:
        return member.status == MemberStatus.kiraci;
      case _QueryScope.activeOwners:
        return member.status == MemberStatus.malik;
      case _QueryScope.activeTenants:
        return member.status == MemberStatus.kiraci;
      case _QueryScope.formerOwners:
      case _QueryScope.formerTenants:
        return false;
    }
  }

  void _runQuery() {
    setState(() {
      _queryResults = _applyQuery();
    });
  }

  void _resetQuery() {
    setState(() {
      _selectedScope = _QueryScope.allMembers;
      _selectedPropertyFields
        ..clear()
        ..addAll({'block', 'unitNo'});
      _selectedMemberFields
        ..clear()
        ..addAll({'fullName', 'balance', 'phone1'});
      _searchQuery = '';
      _queryResults = _applyQuery();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                'Smart Üye Sorgu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 700 ? 12.0 : 18.0;
          final cardWidth = _calculateCardWidth(
            constraints.maxWidth,
            horizontalPadding,
          );
          final showHorizontalActions = constraints.maxWidth >= 560;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              12,
              horizontalPadding,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroCard(),
                const SizedBox(height: 12),
                _buildSearchBar(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _buildScopeSelectionCard(),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildFieldSelectionCard(
                        title: 'Taşınmaz Bilgileri',
                        options: _propertyFieldOptions,
                        selectedFields: _selectedPropertyFields,
                        onToggle: _togglePropertyField,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildFieldSelectionCard(
                        title: 'Üye Bilgileri',
                        options: _memberFieldOptions,
                        selectedFields: _selectedMemberFields,
                        onToggle: _toggleMemberField,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActions(showHorizontalActions),
                const SizedBox(height: 14),
                _buildResultsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  double _calculateCardWidth(double screenWidth, double horizontalPadding) {
    final contentWidth = screenWidth - (horizontalPadding * 2);

    if (screenWidth >= 1160) {
      return (contentWidth - 24) / 3;
    }
    if (screenWidth >= 760) {
      return (contentWidth - 12) / 2;
    }
    return contentWidth;
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Detaylı Üye Listesi Dökümü',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sorgu kapsamını ve göstermek istediğiniz alanları seçip listeyi hızlıca oluşturabilirsiniz.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: (value) => _searchQuery = value,
        onSubmitted: (_) => _runQuery(),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: 'Ad, blok, daire no, telefon veya TC ile ara',
          suffixIcon: IconButton(
            onPressed: _runQuery,
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: 'Ara',
          ),
        ),
      ),
    );
  }

  Widget _buildScopeSelectionCard() {
    return _buildSectionContainer(
      title: 'Sorgu Seçimi',
      icon: Icons.tune_rounded,
      child: RadioGroup<_QueryScope>(
        groupValue: _selectedScope,
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selectedScope = value);
        },
        child: Column(
          children: _QueryScope.values.map((scope) {
            return RadioListTile<_QueryScope>(
              dense: true,
              visualDensity: const VisualDensity(horizontal: -3, vertical: -2),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              value: scope,
              activeColor: AppColors.primary,
              title: Text(
                _scopeLabel(scope),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFieldSelectionCard({
    required String title,
    required List<_FieldOption> options,
    required Set<String> selectedFields,
    required ValueChanged<String> onToggle,
  }) {
    return _buildSectionContainer(
      title: title,
      icon: Icons.view_column_rounded,
      child: Column(
        children: options.map((field) {
          final isSelected = selectedFields.contains(field.key);
          return CheckboxListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: -3, vertical: -2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            value: isSelected,
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              field.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: (_) => onToggle(field.key),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: CustomColors.tableHeaderColor.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(6, 4, 6, 8), child: child),
        ],
      ),
    );
  }

  Widget _buildActions(bool showHorizontalActions) {
    final children = [
      OutlinedButton.icon(
        onPressed: _resetQuery,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Temizle'),
      ),
      ElevatedButton.icon(
        onPressed: _runQuery,
        icon: const Icon(Icons.search_rounded),
        label: const Text('Sorgula'),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: showHorizontalActions
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [children[0], const SizedBox(width: 8), children[1]],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [children[1], const SizedBox(height: 8), children[0]],
            ),
    );
  }

  Widget _buildResultsSection() {
    final selectedPropertyColumns = _propertyFieldOptions
        .where((field) => _selectedPropertyFields.contains(field.key))
        .toList();
    final selectedMemberColumns = _memberFieldOptions
        .where((field) => _selectedMemberFields.contains(field.key))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.table_chart_rounded,
                size: 20,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sorgu Sonuçları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: 'Kapsam: ${_scopeLabel(_selectedScope)}',
                color: AppColors.primary,
              ),
              _InfoChip(
                label: 'Kayıt: ${_queryResults.length}',
                color: AppColors.secondary,
              ),
              _InfoChip(
                label:
                    'Alan: ${selectedPropertyColumns.length + selectedMemberColumns.length}',
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (selectedPropertyColumns.isEmpty && selectedMemberColumns.isEmpty)
            _buildEmptyResult(
              'En az bir alan seçin',
              'Taşınmaz veya üye alanlarından en az birini seçip sorguyu tekrar çalıştırın.',
            )
          else if (_queryResults.isEmpty)
            _buildEmptyResult(
              'Kayıt bulunamadı',
              'Seçili kapsam için eşleşen veri yok. Filtreleri değiştirip yeniden deneyin.',
            )
          else
            _buildResultTable(
              selectedPropertyColumns: selectedPropertyColumns,
              selectedMemberColumns: selectedMemberColumns,
            ),
          const SizedBox(height: 8),
          Text(
            'Not: Demo veride olmayan alanlar "-" olarak gösterilir.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResult(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildResultTable({
    required List<_FieldOption> selectedPropertyColumns,
    required List<_FieldOption> selectedMemberColumns,
  }) {
    final dataRows = _queryResults.asMap().entries.map((entry) {
      final index = entry.key;
      final member = entry.value;
      return DataRow(
        cells: [
          ...selectedPropertyColumns.map(
            (field) =>
                DataCell(Text(_propertyFieldValue(field.key, member, index))),
          ),
          ...selectedMemberColumns.map(
            (field) =>
                DataCell(Text(_memberFieldValue(field.key, member, index))),
          ),
        ],
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(
              CustomColors.tableHeaderColor.withValues(alpha: 0.95),
            ),
            headingTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            dataTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12.5,
            ),
            dividerThickness: 0.4,
            columnSpacing: 22,
            horizontalMargin: 12,
            columns: [
              ...selectedPropertyColumns.map(
                (field) => DataColumn(label: Text(field.label)),
              ),
              ...selectedMemberColumns.map(
                (field) => DataColumn(label: Text(field.label)),
              ),
            ],
            rows: dataRows,
          ),
        ),
      ),
    );
  }

  void _togglePropertyField(String fieldKey) {
    setState(() {
      if (_selectedPropertyFields.contains(fieldKey)) {
        _selectedPropertyFields.remove(fieldKey);
      } else {
        _selectedPropertyFields.add(fieldKey);
      }
    });
  }

  void _toggleMemberField(String fieldKey) {
    setState(() {
      if (_selectedMemberFields.contains(fieldKey)) {
        _selectedMemberFields.remove(fieldKey);
      } else {
        _selectedMemberFields.add(fieldKey);
      }
    });
  }

  String _scopeLabel(_QueryScope scope) {
    switch (scope) {
      case _QueryScope.allMembers:
        return 'Tüm Üyeler';
      case _QueryScope.activeOwnersAndTenants:
        return 'Aktif Malik Ve Kiracılar';
      case _QueryScope.currentResidents:
        return 'Oturanlar';
      case _QueryScope.owners:
        return 'Malikler';
      case _QueryScope.tenants:
        return 'Kiracılar';
      case _QueryScope.activeOwners:
        return 'Aktif Malikler';
      case _QueryScope.activeTenants:
        return 'Aktif Kiracılar';
      case _QueryScope.formerOwners:
        return 'Eski Malikler';
      case _QueryScope.formerTenants:
        return 'Eski Kiracılar';
    }
  }

  String _propertyFieldValue(String key, MemberData member, int rowIndex) {
    final unitNo = int.tryParse(member.unitNo) ?? (rowIndex + 1);
    final uniquePart = member.id.split('-').last.padLeft(3, '0');

    switch (key) {
      case 'block':
        return member.block;
      case 'unitNo':
        return member.unitNo;
      case 'duesGroup':
        return 'Aidat Grubu ${((unitNo - 1) % 3) + 1}';
      case 'floor':
        return '${((unitNo - 1) ~/ 2) + 1}';
      case 'squareMeter':
        return '${90 + ((unitNo * 7) % 35)} m²';
      case 'landShare':
        return '${18 + ((unitNo * 3) % 22)}/1000';
      case 'fuelMeterNo':
        return 'YKT-$uniquePart';
      case 'hotWaterMeterNo':
        return 'SS-$uniquePart';
      case 'coldWaterMeterNo':
        return 'SOG-$uniquePart';
      case 'electricMeterNo':
        return 'ELK-$uniquePart';
      default:
        return '-';
    }
  }

  String _memberFieldValue(String key, MemberData member, int rowIndex) {
    switch (key) {
      case 'gender':
        return _normalize(member.gender);
      case 'fullName':
        return _normalize(member.fullName);
      case 'entryDate':
        return _dateFormat.format(_entryDate(member, rowIndex));
      case 'exitDate':
        return '-';
      case 'share':
        return '%${(12 + (rowIndex % 6) * 3)}';
      case 'balance':
        return _currencyFormat.format(member.totalBalance);
      case 'tcKimlik':
        return _normalize(member.tcKimlik);
      case 'phone1':
        return _normalize(member.phone);
      case 'phone2':
        return '-';
      case 'email1':
        return _normalize(member.email);
      case 'email2':
        return '-';
      case 'birthDate':
        return _dateFormat.format(
          DateTime(
            1978 + (rowIndex % 19),
            (rowIndex % 12) + 1,
            (rowIndex % 27) + 1,
          ),
        );
      case 'bloodGroup':
        return _bloodGroups[rowIndex % _bloodGroups.length];
      case 'sector':
        return member.profession.isEmpty ? '-' : 'Hizmet';
      case 'workPlace':
        return member.profession.isEmpty ? '-' : '${member.profession} Ofisi';
      case 'workAddress':
        return _normalize(member.address);
      case 'homeAddress':
        return _normalize(member.address);
      case 'note':
        return member.notes.isEmpty
            ? '-'
            : _normalize(member.notes.first.content);
      default:
        return '-';
    }
  }

  DateTime _entryDate(MemberData member, int rowIndex) {
    if (member.transactions.isNotEmpty) {
      return member.transactions.first.date;
    }
    return DateTime(2024, (rowIndex % 12) + 1, (rowIndex % 27) + 1);
  }

  String _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '-';
    return trimmed;
  }
}

class _FieldOption {
  final String key;
  final String label;

  const _FieldOption({required this.key, required this.label});
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
