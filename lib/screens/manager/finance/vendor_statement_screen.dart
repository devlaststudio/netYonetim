import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class VendorStatementScreen extends StatefulWidget {
  const VendorStatementScreen({super.key});

  @override
  State<VendorStatementScreen> createState() => _VendorStatementScreenState();
}

class _VendorStatementScreenState extends State<VendorStatementScreen> {
  String _selectedVendorId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.vendorStatementLines.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final lines = provider.getVendorStatements(_selectedVendorId);

    final debit = lines.fold<double>(0, (sum, line) => sum + line.debit);
    final credit = lines.fold<double>(0, (sum, line) => sum + line.credit);

    return ManagerPageScaffold(
      title: 'Cari Hesap Ekstresi',
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Filtre',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedVendorId,
                    decoration:
                        const InputDecoration(labelText: 'Firma Secimi'),
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Tum Firmalar')),
                      ...ManagerFinanceMockData.vendors.map(
                        (vendor) => DropdownMenuItem(
                          value: vendor['id'],
                          child: Text(vendor['name']!),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedVendorId = value ?? '');
                    },
                  ),
                ),
                ManagerSectionCard(
                  title: 'Cari Ozet',
                  child: ManagerKpiGrid(
                    items: [
                      ManagerKpiItem(
                        label: 'Toplam Borc',
                        value: formatCurrency(debit),
                        color: AppColors.error,
                      ),
                      ManagerKpiItem(
                        label: 'Toplam Odeme',
                        value: formatCurrency(credit),
                        color: AppColors.success,
                      ),
                      ManagerKpiItem(
                        label: 'Net Acik',
                        value: formatCurrency(debit - credit),
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
                      icon: Icons.business_center_outlined,
                      title: 'Cari kaydi yok',
                      subtitle: 'Secili filtre icin hareket bulunmuyor.',
                    ),
                  )
                else
                  Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Tarih')),
                          DataColumn(label: Text('Firma')),
                          DataColumn(label: Text('Tip')),
                          DataColumn(label: Text('Borc')),
                          DataColumn(label: Text('Alacak')),
                          DataColumn(label: Text('Bakiye')),
                        ],
                        rows: lines
                            .map(
                              (line) => DataRow(
                                cells: [
                                  DataCell(Text(DateFormat('dd.MM.yyyy')
                                      .format(line.date))),
                                  DataCell(Text(line.vendorName)),
                                  DataCell(Text(line.entryType)),
                                  DataCell(Text(formatCurrency(line.debit))),
                                  DataCell(Text(formatCurrency(line.credit))),
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
