enum ReportType {
  balanceSheet, // Mizan
  incomeStatement, // Gelir-Gider Tablosu
  debtStatus, // Borç Durum Raporu
  collectionReport, // Tahsilat Raporu
  expenseAnalysis, // Gider Analizi
  cashFlow, // Kasa Raporu
  auditReport, // Denetim Raporu
}

enum ReportPeriod {
  daily, // Günlük
  weekly, // Haftalık
  monthly, // Aylık
  quarterly, // Üç Aylık
  yearly, // Yıllık
  custom, // Özel
}

class FinancialReportModel {
  final String id;
  final ReportType type;
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;
  final String? generatedBy;
  final Map<String, dynamic> data; // Rapor verileri
  final ReportSummary summary; // Özet bilgiler

  FinancialReportModel({
    required this.id,
    required this.type,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    this.generatedBy,
    required this.data,
    required this.summary,
  });

  String get typeDisplayName {
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

  String get periodDisplayName {
    switch (period) {
      case ReportPeriod.daily:
        return 'Günlük';
      case ReportPeriod.weekly:
        return 'Haftalık';
      case ReportPeriod.monthly:
        return 'Aylık';
      case ReportPeriod.quarterly:
        return 'Üç Aylık';
      case ReportPeriod.yearly:
        return 'Yıllık';
      case ReportPeriod.custom:
        return 'Özel';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'generatedAt': generatedAt.toIso8601String(),
      'generatedBy': generatedBy,
      'data': data,
      'summary': summary.toJson(),
    };
  }

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      id: json['id'],
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.incomeStatement,
      ),
      period: ReportPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => ReportPeriod.monthly,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      generatedAt: DateTime.parse(json['generatedAt']),
      generatedBy: json['generatedBy'],
      data: json['data'],
      summary: ReportSummary.fromJson(json['summary']),
    );
  }
}

class ReportSummary {
  final double totalIncome; // Toplam Gelir
  final double totalExpense; // Toplam Gider
  final double netIncome; // Net Gelir
  final double totalDebt; // Toplam Borç
  final double totalCollection; // Toplam Tahsilat
  final int transactionCount; // İşlem Sayısı
  final Map<String, double>? categoryBreakdown; // Kategori bazlı dağılım

  ReportSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netIncome,
    this.totalDebt = 0.0,
    this.totalCollection = 0.0,
    this.transactionCount = 0,
    this.categoryBreakdown,
  });

  double get profitMargin =>
      totalIncome > 0 ? (netIncome / totalIncome * 100) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netIncome': netIncome,
      'totalDebt': totalDebt,
      'totalCollection': totalCollection,
      'transactionCount': transactionCount,
      'categoryBreakdown': categoryBreakdown,
    };
  }

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalIncome: (json['totalIncome'] ?? 0.0).toDouble(),
      totalExpense: (json['totalExpense'] ?? 0.0).toDouble(),
      netIncome: (json['netIncome'] ?? 0.0).toDouble(),
      totalDebt: (json['totalDebt'] ?? 0.0).toDouble(),
      totalCollection: (json['totalCollection'] ?? 0.0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
      categoryBreakdown: json['categoryBreakdown'] != null
          ? Map<String, double>.from(json['categoryBreakdown'])
          : null,
    );
  }

  ReportSummary copyWith({
    double? totalIncome,
    double? totalExpense,
    double? netIncome,
    double? totalDebt,
    double? totalCollection,
    int? transactionCount,
    Map<String, double>? categoryBreakdown,
  }) {
    return ReportSummary(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netIncome: netIncome ?? this.netIncome,
      totalDebt: totalDebt ?? this.totalDebt,
      totalCollection: totalCollection ?? this.totalCollection,
      transactionCount: transactionCount ?? this.transactionCount,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
    );
  }
}
