import 'dart:async';

import '../data/models/manager/manager_models.dart';

class ReportExportService {
  Future<String> exportPdf(ManagerReportItem report) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return '${report.type.name}_${report.generatedAt.millisecondsSinceEpoch}.pdf';
  }

  Future<String> exportExcel(ManagerReportItem report) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return '${report.type.name}_${report.generatedAt.millisecondsSinceEpoch}.xlsx';
  }
}
