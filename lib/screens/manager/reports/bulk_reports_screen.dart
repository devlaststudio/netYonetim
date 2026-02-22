import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../../../data/providers/manager_reports_provider.dart';
import '../../../services/report_export_service.dart';
import '../shared/manager_common_widgets.dart';

class BulkReportsScreen extends StatefulWidget {
  const BulkReportsScreen({super.key});

  @override
  State<BulkReportsScreen> createState() => _BulkReportsScreenState();
}

class _BulkReportsScreenState extends State<BulkReportsScreen> {
  final ReportExportService _exportService = ReportExportService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ManagerReportsProvider>();
    final financeProvider = context.watch<ManagerFinanceProvider>();

    return ManagerPageScaffold(
      title: 'Toplu Raporlar',
      child: reportsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Rapor Donemi',
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(context, true),
                          icon: const Icon(Icons.calendar_today),
                          label:
                              Text(DateFormat('dd.MM.yyyy').format(_startDate)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(context, false),
                          icon: const Icon(Icons.calendar_today),
                          label:
                              Text(DateFormat('dd.MM.yyyy').format(_endDate)),
                        ),
                      ),
                    ],
                  ),
                ),
                ManagerSectionCard(
                  title: 'Rapor Tipleri',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ReportTypeKey.values
                        .map(
                          (type) => ActionChip(
                            avatar: const Icon(Icons.insights, size: 16),
                            label: Text(type.label),
                            onPressed: () => _generateReport(
                              context,
                              type,
                              financeProvider,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (reportsProvider.reports.isEmpty)
                  const SizedBox(
                    height: 280,
                    child: ManagerEmptyState(
                      icon: Icons.bar_chart,
                      title: 'Uretilmis rapor yok',
                      subtitle: 'Rapor tipi secip olusturabilirsiniz.',
                    ),
                  )
                else
                  ...reportsProvider.reports.map(
                    (report) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE9F0FF),
                          child: Icon(Icons.description_outlined,
                              color: AppColors.primary),
                        ),
                        title: Text(report.type.label),
                        subtitle: Text(
                          '${DateFormat('dd.MM.yyyy').format(report.startDate)} - ${DateFormat('dd.MM.yyyy').format(report.endDate)}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'preview') {
                              _showPreview(context, report);
                              return;
                            }

                            final fileName = value == 'pdf'
                                ? await _exportService.exportPdf(report)
                                : await _exportService.exportExcel(report);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Olusturuldu: $fileName')),
                              );
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'preview', child: Text('Onizleme')),
                            PopupMenuItem(
                                value: 'pdf', child: Text('PDF Disa Aktar')),
                            PopupMenuItem(
                                value: 'excel',
                                child: Text('Excel Disa Aktar')),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _pickDate(BuildContext context, bool start) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: start ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected == null) return;

    setState(() {
      if (start) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _generateReport(
    BuildContext context,
    ReportTypeKey type,
    ManagerFinanceProvider financeProvider,
  ) async {
    final sourceSummary = <String, double>{
      'toplamTahsilat': financeProvider.totalCollectionAmount,
      'toplamGider': financeProvider.totalExpenseAmount,
      'toplamTahakkuk': financeProvider.totalChargeAmount,
      'toplamTransfer': financeProvider.totalTransferAmount,
    };

    await context.read<ManagerReportsProvider>().generateReport(
          type: type,
          startDate: _startDate,
          endDate: _endDate,
          sourceSummary: sourceSummary,
        );
  }

  void _showPreview(BuildContext context, ManagerReportItem report) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(report.type.label),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('dd.MM.yyyy').format(report.startDate)} - ${DateFormat('dd.MM.yyyy').format(report.endDate)}',
                ),
                const SizedBox(height: 12),
                ...report.summary.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          formatCurrency(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}
