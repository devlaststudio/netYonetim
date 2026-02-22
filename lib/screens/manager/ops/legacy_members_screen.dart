import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_ops_provider.dart';
import '../shared/manager_common_widgets.dart';

class LegacyMembersScreen extends StatefulWidget {
  const LegacyMembersScreen({super.key});

  @override
  State<LegacyMembersScreen> createState() => _LegacyMembersScreenState();
}

class _LegacyMembersScreenState extends State<LegacyMembersScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all';
  String _blockFilter = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerOpsProvider>();
    if (!provider.isLoading && provider.legacyMembers.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerOpsProvider>();
    final blockLabels = {
      'all',
      ...provider.legacyMembers
          .map((record) => _extractBlockLabel(record.unitLabel)),
    }.toList();

    final filtered = provider.legacyMembers.where((record) {
      final matchesSearch = _searchQuery.isEmpty ||
          record.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          record.unitLabel.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType = _typeFilter == 'all' ||
          (_typeFilter == 'owner' &&
              record.occupancyType == LegacyOccupancyType.owner) ||
          (_typeFilter == 'tenant' &&
              record.occupancyType == LegacyOccupancyType.tenant);

      final matchesBlock = _blockFilter == 'all' ||
          _extractBlockLabel(record.unitLabel) == _blockFilter;

      return matchesSearch && matchesType && matchesBlock;
    }).toList()
      ..sort((a, b) => b.moveOutDate.compareTo(a.moveOutDate));

    final ownerCount = filtered
        .where((record) => record.occupancyType == LegacyOccupancyType.owner)
        .length;
    final tenantCount = filtered
        .where((record) => record.occupancyType == LegacyOccupancyType.tenant)
        .length;
    final last12MonthCount = filtered
        .where(
          (record) => record.moveOutDate
              .isAfter(DateTime.now().subtract(const Duration(days: 365))),
        )
        .length;

    return ManagerPageScaffold(
      title: 'Eski Uye Gorunumu',
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Filtreler',
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Ad soyad veya daire ara',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value.trim());
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration:
                                  const InputDecoration(labelText: 'Uye Tipi'),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _typeFilter,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'all',
                                        child: Text('Tum Tipler')),
                                    DropdownMenuItem(
                                        value: 'owner',
                                        child: Text('Eski Malik')),
                                    DropdownMenuItem(
                                        value: 'tenant',
                                        child: Text('Eski Kiraci')),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _typeFilter = value);
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InputDecorator(
                              decoration:
                                  const InputDecoration(labelText: 'Blok'),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _blockFilter,
                                  isExpanded: true,
                                  items: blockLabels
                                      .map(
                                        (block) => DropdownMenuItem(
                                          value: block,
                                          child: Text(
                                            block == 'all'
                                                ? 'Tum Bloklar'
                                                : block,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _blockFilter = value);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ManagerSectionCard(
                  title: 'Kayit Ozeti',
                  child: ManagerKpiGrid(
                    items: [
                      ManagerKpiItem(
                        label: 'Toplam Kayit',
                        value: '${filtered.length}',
                        color: AppColors.primary,
                      ),
                      ManagerKpiItem(
                        label: 'Eski Malik',
                        value: '$ownerCount',
                        color: AppColors.info,
                      ),
                      ManagerKpiItem(
                        label: 'Eski Kiraci',
                        value: '$tenantCount',
                        color: AppColors.success,
                      ),
                      ManagerKpiItem(
                        label: 'Son 12 Ay Cikis',
                        value: '$last12MonthCount',
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
                  const SizedBox(
                    height: 280,
                    child: ManagerEmptyState(
                      icon: Icons.person_search_outlined,
                      title: 'Kayit bulunamadi',
                      subtitle: 'Filtreye uygun eski uye kaydi yok.',
                    ),
                  )
                else
                  ...filtered.map(
                    (record) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor:
                              record.occupancyType == LegacyOccupancyType.owner
                                  ? AppColors.info.withValues(alpha: 0.12)
                                  : AppColors.success.withValues(alpha: 0.12),
                          child: Icon(
                            record.occupancyType == LegacyOccupancyType.owner
                                ? Icons.home_work_outlined
                                : Icons.person_outline,
                            color: record.occupancyType ==
                                    LegacyOccupancyType.owner
                                ? AppColors.info
                                : AppColors.success,
                          ),
                        ),
                        title: Text(record.fullName),
                        subtitle: Text(
                          '${record.occupancyType.label} • ${record.unitLabel}\nCikis: ${DateFormat('dd.MM.yyyy').format(record.moveOutDate)} • Neden: ${record.reason}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLegacyDetail(context, record),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _extractBlockLabel(String unitLabel) {
    final parts = unitLabel.split(' ');
    if (parts.length < 2) {
      return unitLabel;
    }
    return '${parts[0]} ${parts[1]}';
  }

  void _showLegacyDetail(BuildContext context, LegacyMemberRecord record) {
    showModalBottomSheet<void>(
      context: context,
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
                Text(record.fullName,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('${record.occupancyType.label} • ${record.unitLabel}'),
                const SizedBox(height: 6),
                Text(
                    'Giris: ${DateFormat('dd.MM.yyyy').format(record.moveInDate)}'),
                Text(
                    'Cikis: ${DateFormat('dd.MM.yyyy').format(record.moveOutDate)}'),
                Text('Cikis Nedeni: ${record.reason}'),
                Text('Telefon: ${record.phone ?? '-'}'),
                if (record.note != null && record.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Not: ${record.note!}'),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
