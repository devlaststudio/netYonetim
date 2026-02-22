import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class UnitStatementScreen extends StatefulWidget {
  const UnitStatementScreen({super.key});

  @override
  State<UnitStatementScreen> createState() => _UnitStatementScreenState();
}

class _UnitStatementScreenState extends State<UnitStatementScreen> {
  String _selectedUnitId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.unitStatementLines.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final lines = provider.getUnitStatements(_selectedUnitId);

    final debt = lines.fold<double>(0, (sum, line) => sum + line.debt);
    final paid = lines.fold<double>(0, (sum, line) => sum + line.paid);

    return ManagerPageScaffold(
      title: 'Daire Hesap Ekstresi',
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Filtre',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnitId,
                    decoration:
                        const InputDecoration(labelText: 'Daire Secimi'),
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Tum Daireler')),
                      ...ManagerFinanceMockData.units.map(
                        (unit) => DropdownMenuItem(
                          value: unit['id'],
                          child: Text(unit['label']!),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedUnitId = value ?? '');
                    },
                  ),
                ),
                ManagerSectionCard(
                  title: 'Ekstre Ozeti',
                  child: ManagerKpiGrid(
                    items: [
                      ManagerKpiItem(
                        label: 'Toplam Borc',
                        value: formatCurrency(debt),
                        color: AppColors.error,
                      ),
                      ManagerKpiItem(
                        label: 'Toplam Odeme',
                        value: formatCurrency(paid),
                        color: AppColors.success,
                      ),
                      ManagerKpiItem(
                        label: 'Net Bakiye',
                        value: formatCurrency(debt - paid),
                        color: AppColors.primary,
                      ),
                      ManagerKpiItem(
                        label: 'Kayit',
                        value: '${lines.length}',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
                if (lines.isEmpty)
                  const SizedBox(
                    height: 260,
                    child: ManagerEmptyState(
                      icon: Icons.description_outlined,
                      title: 'Ekstre kaydi yok',
                      subtitle: 'Secili filtrede hareket bulunmuyor.',
                    ),
                  )
                else
                  Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Tarih')),
                          DataColumn(label: Text('Daire')),
                          DataColumn(label: Text('Aciklama')),
                          DataColumn(label: Text('Borc')),
                          DataColumn(label: Text('Odeme')),
                          DataColumn(label: Text('Bakiye')),
                        ],
                        rows: lines
                            .map(
                              (line) => DataRow(
                                cells: [
                                  DataCell(Text(DateFormat('dd.MM.yyyy')
                                      .format(line.date))),
                                  DataCell(Text(line.unitLabel)),
                                  DataCell(Text(line.description)),
                                  DataCell(Text(formatCurrency(line.debt))),
                                  DataCell(Text(formatCurrency(line.paid))),
                                  DataCell(Text(formatCurrency(line.balance))),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
