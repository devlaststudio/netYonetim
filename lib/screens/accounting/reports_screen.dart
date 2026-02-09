import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/accounting_provider.dart';
import '../../../data/models/financial_report_model.dart';
import '../../../widgets/accounting/accounting_drawer.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mali Raporlar')),
      drawer: const AccountingDrawer(currentRoute: '/accounting/reports'),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateReportDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Rapor Oluştur'),
      ),
      body: _buildReportsContent(),
    );
  }

  Widget _buildReportsContent() {
    return Builder(
      builder: (context) {
        final provider = context.watch<AccountingProvider>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rapor Tipleri',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildReportTypeCard(
                context,
                ReportType.balanceSheet,
                Icons.account_balance,
                'Mizan',
                'Hesap bakiyeleri listesi',
                AppColors.primary,
              ),
              _buildReportTypeCard(
                context,
                ReportType.incomeStatement,
                Icons.trending_up,
                'Gelir-Gider Tablosu',
                'Dönemsel özet rapor',
                AppColors.success,
              ),
              _buildReportTypeCard(
                context,
                ReportType.debtStatus,
                Icons.money_off,
                'Borç Durum Raporu',
                'Açık borçlar listesi',
                AppColors.warning,
              ),
              _buildReportTypeCard(
                context,
                ReportType.collectionReport,
                Icons.payments,
                'Tahsilat Raporu',
                'Dönemsel tahsilat analizi',
                AppColors.info,
              ),
              _buildReportTypeCard(
                context,
                ReportType.expenseAnalysis,
                Icons.pie_chart,
                'Gider Analizi',
                'Kategori bazlı dağılım',
                AppColors.error,
              ),
              _buildReportTypeCard(
                context,
                ReportType.cashFlow,
                Icons.account_balance_wallet,
                'Kasa Raporu',
                'Nakit akış takibi',
                AppColors.secondary,
              ),
              const SizedBox(height: 24),
              if (provider.reports.isNotEmpty) ...[
                const Text(
                  'Son Raporlar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...provider.reports.map(
                  (report) => _buildReportCard(context, report),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportTypeCard(
    BuildContext context,
    ReportType type,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showGenerateReportDialog(context, type),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, FinancialReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          report.typeDisplayName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(report.startDate)} - ${DateFormat('dd/MM/yyyy').format(report.endDate)}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export yakında eklenecek')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Excel export yakında eklenecek'),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () => _showReportDetail(context, report),
      ),
    );
  }

  void _showGenerateReportDialog(
    BuildContext context, [
    ReportType? preselectedType,
  ]) {
    final provider = context.read<AccountingProvider>();
    ReportType selectedType = preselectedType ?? ReportType.incomeStatement;
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rapor Oluştur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ReportType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Rapor Tipi'),
                items: ReportType.values.map((type) {
                  final typeDisplayName = _getReportTypeDisplayName(type);
                  return DropdownMenuItem(
                    value: type,
                    child: Text(typeDisplayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Başlangıç Tarihi'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => startDate = date);
                  }
                },
              ),
              ListTile(
                title: const Text('Bitiş Tarihi'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => endDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final report = await provider.generateReport(
                  type: selectedType,
                  startDate: startDate,
                  endDate: endDate,
                  generatedBy: 'current-user',
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  _showReportDetail(context, report);
                }
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetail(BuildContext context, FinancialReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
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
                  Expanded(
                    child: Text(
                      report.typeDisplayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                '${DateFormat('dd/MM/yyyy').format(report.startDate)} - ${DateFormat('dd/MM/yyyy').format(report.endDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      'Toplam Gelir:',
                      '₺${report.summary.totalIncome.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    _SummaryRow(
                      'Toplam Gider:',
                      '₺${report.summary.totalExpense.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    _SummaryRow(
                      'Net Gelir:',
                      '₺${report.summary.netIncome.toStringAsFixed(2)}',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Detaylar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    Text('İşlem Sayısı: ${report.summary.transactionCount}'),
                    const SizedBox(height: 8),
                    if (report.summary.categoryBreakdown != null) ...[
                      const Text(
                        'Kategori Dağılımı:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ...report.summary.categoryBreakdown!.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(
                                '₺${entry.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }

  String _getReportTypeDisplayName(ReportType type) {
    switch (type) {
      case ReportType.balanceSheet:
        return 'Mizan';
      case ReportType.incomeStatement:
        return 'Gelir-Gider Tablosu';
      case ReportType.debtStatus:
        return 'Borç Durum Raporu';
      case ReportType.collectionReport:
        return 'Tahsilat Raporu';
      case ReportType.expenseAnalysis:
        return 'Gider Analizi';
      case ReportType.cashFlow:
        return 'Kasa Raporu';
      case ReportType.auditReport:
        return 'Denetim Raporu';
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _SummaryRow(this.label, this.value, {this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
