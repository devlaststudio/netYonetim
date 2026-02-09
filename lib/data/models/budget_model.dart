enum BudgetPeriod {
  monthly, // Aylık
  quarterly, // Üç Aylık
  yearly, // Yıllık
}

enum BudgetStatus {
  draft, // Taslak
  active, // Aktif
  completed, // Tamamlandı
  cancelled, // İptal Edildi
}

class BudgetModel {
  final String id;
  final String name; // Bütçe adı
  final BudgetPeriod period; // Dönem
  final int year; // Yıl
  final int? month; // Ay (monthly için)
  final int? quarter; // Çeyrek (quarterly için)
  final BudgetStatus status; // Durum
  final DateTime startDate; // Başlangıç tarihi
  final DateTime endDate; // Bitiş tarihi
  final List<BudgetItem> items; // Bütçe kalemleri
  final String? notes; // Notlar
  final String? createdBy; // Oluşturan
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BudgetModel({
    required this.id,
    required this.name,
    required this.period,
    required this.year,
    this.month,
    this.quarter,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.items,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  String get periodDisplayName {
    switch (period) {
      case BudgetPeriod.monthly:
        return 'Aylık';
      case BudgetPeriod.quarterly:
        return 'Üç Aylık';
      case BudgetPeriod.yearly:
        return 'Yıllık';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case BudgetStatus.draft:
        return 'Taslak';
      case BudgetStatus.active:
        return 'Aktif';
      case BudgetStatus.completed:
        return 'Tamamlandı';
      case BudgetStatus.cancelled:
        return 'İptal';
    }
  }

  double get totalPlanned =>
      items.fold(0.0, (sum, item) => sum + item.plannedAmount);

  double get totalActual =>
      items.fold(0.0, (sum, item) => sum + item.actualAmount);

  double get totalVariance => totalActual - totalPlanned;

  double get realizationPercentage =>
      totalPlanned > 0 ? (totalActual / totalPlanned * 100) : 0.0;

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'period': period.name,
      'year': year,
      'month': month,
      'quarter': quarter,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (API response)
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      name: json['name'],
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      year: json['year'],
      month: json['month'],
      quarter: json['quarter'],
      status: BudgetStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BudgetStatus.draft,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      items: (json['items'] as List)
          .map((item) => BudgetItem.fromJson(item))
          .toList(),
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Copy with modifications
  BudgetModel copyWith({
    String? id,
    String? name,
    BudgetPeriod? period,
    int? year,
    int? month,
    int? quarter,
    BudgetStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<BudgetItem>? items,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      period: period ?? this.period,
      year: year ?? this.year,
      month: month ?? this.month,
      quarter: quarter ?? this.quarter,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BudgetItem {
  final String id;
  final String accountId; // Hesap ID'si
  final String accountCode; // Hesap kodu
  final String accountName; // Hesap adı
  final double plannedAmount; // Planlanan tutar
  final double actualAmount; // Gerçekleşen tutar
  final String? notes; // Notlar

  BudgetItem({
    required this.id,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.plannedAmount,
    this.actualAmount = 0.0,
    this.notes,
  });

  double get variance => actualAmount - plannedAmount;

  double get realizationPercentage =>
      plannedAmount > 0 ? (actualAmount / plannedAmount * 100) : 0.0;

  bool get isOverBudget => actualAmount > plannedAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'accountCode': accountCode,
      'accountName': accountName,
      'plannedAmount': plannedAmount,
      'actualAmount': actualAmount,
      'notes': notes,
    };
  }

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'],
      accountId: json['accountId'],
      accountCode: json['accountCode'],
      accountName: json['accountName'],
      plannedAmount: (json['plannedAmount'] ?? 0.0).toDouble(),
      actualAmount: (json['actualAmount'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }

  BudgetItem copyWith({
    String? id,
    String? accountId,
    String? accountCode,
    String? accountName,
    double? plannedAmount,
    double? actualAmount,
    String? notes,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      actualAmount: actualAmount ?? this.actualAmount,
      notes: notes ?? this.notes,
    );
  }
}
