import 'package:flutter/material.dart';

import '../models/manager/manager_models.dart';

class ManagerReportsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdatedAt;

  final List<ManagerReportItem> _reports = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdatedAt => _lastUpdatedAt;
  List<ManagerReportItem> get reports => _reports;

  Future<ManagerReportItem> generateReport({
    required ReportTypeKey type,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, double>? sourceSummary,
  }) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final summary = sourceSummary ?? _buildFallbackSummary(type);
      final report = ManagerReportItem(
        id: 'mrp-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        startDate: startDate,
        endDate: endDate,
        generatedAt: DateTime.now(),
        summary: summary,
      );

      _reports.insert(0, report);
      _errorMessage = null;
      _lastUpdatedAt = DateTime.now();
      return report;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Map<String, double> _buildFallbackSummary(ReportTypeKey type) {
    switch (type) {
      case ReportTypeKey.cashStatus:
        return {
          'nakit': 186500,
          'banka': 820550,
          'bekleyenGelir': 94500,
          'bekleyenGider': 36200,
        };
      case ReportTypeKey.monthlyIncomeExpense:
        return {
          'gelir': 382400,
          'gider': 214900,
          'net': 167500,
        };
      case ReportTypeKey.accrualMovements:
        return {
          'tahakkuk': 450000,
          'iptal': 18500,
          'netTahakkuk': 431500,
        };
      case ReportTypeKey.collection:
        return {
          'tahsilat': 367200,
          'gecikmeTahsilati': 21900,
          'iade': 1500,
        };
      case ReportTypeKey.unitStatement:
        return {
          'borc': 124000,
          'odeme': 103000,
          'bakiye': 21000,
        };
      case ReportTypeKey.vendorStatement:
        return {
          'borc': 84000,
          'odeme': 51000,
          'acik': 33000,
        };
      case ReportTypeKey.auditor:
        return {
          'tespit': 6,
          'tamamlanan': 4,
          'acik': 2,
        };
      case ReportTypeKey.warningLetter:
        return {
          'olusturulan': 35,
          'gonderilen': 30,
          'bekleyen': 5,
        };
      case ReportTypeKey.noDebt:
        return {
          'olusturulan': 28,
          'onaylanan': 26,
          'iptal': 2,
        };
      case ReportTypeKey.posBank:
        return {
          'posTahsilat': 194000,
          'bankaTahsilat': 272000,
          'masraf': 9500,
        };
      case ReportTypeKey.budgetComparison:
        return {
          'tahmini': 520000,
          'fiili': 498300,
          'fark': -21700,
        };
    }
  }

  void clearReports() {
    _reports.clear();
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
