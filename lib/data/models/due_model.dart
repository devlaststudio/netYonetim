enum DueType { aidat, su, elektrik, dogalgaz, demirbas, diger }

enum DueStatus { pending, overdue, paid, partiallyPaid }

class DueModel {
  final String id;
  final String? siteId;
  final String unitId;
  final DueType type;
  final double amount;
  final double paidAmount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String description;
  final int periodMonth;
  final int periodYear;
  final DueStatus status;
  final double? delayFee;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DueModel({
    required this.id,
    this.siteId,
    required this.unitId,
    required this.type,
    required this.amount,
    this.paidAmount = 0,
    required this.dueDate,
    this.paidDate,
    required this.description,
    required this.periodMonth,
    required this.periodYear,
    required this.status,
    this.delayFee,
    this.createdAt,
    this.updatedAt,
  });

  double get remainingAmount => amount - paidAmount + (delayFee ?? 0);

  bool get isOverdue => status == DueStatus.overdue;
  bool get isPaid => status == DueStatus.paid;

  String get typeDisplayName {
    switch (type) {
      case DueType.aidat:
        return 'Aidat';
      case DueType.su:
        return 'Su Tüketimi';
      case DueType.elektrik:
        return 'Elektrik';
      case DueType.dogalgaz:
        return 'Doğalgaz';
      case DueType.demirbas:
        return 'Demirbaş';
      case DueType.diger:
        return 'Diğer';
    }
  }

  String get periodDisplay {
    final months = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${months[periodMonth]} $periodYear';
  }

  String get statusDisplayName {
    switch (status) {
      case DueStatus.pending:
        return 'Bekliyor';
      case DueStatus.overdue:
        return 'Gecikmiş';
      case DueStatus.paid:
        return 'Ödendi';
      case DueStatus.partiallyPaid:
        return 'Kısmi Ödendi';
    }
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'unitId': unitId,
      'type': type.name,
      'amount': amount,
      'paidAmount': paidAmount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'description': description,
      'periodMonth': periodMonth,
      'periodYear': periodYear,
      'status': status.name,
      'delayFee': delayFee,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (API response)
  factory DueModel.fromJson(Map<String, dynamic> json) {
    return DueModel(
      id: json['id'],
      siteId: json['siteId'],
      unitId: json['unitId'],
      type: DueType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DueType.diger,
      ),
      amount: (json['amount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      description: json['description'],
      periodMonth: json['periodMonth'],
      periodYear: json['periodYear'],
      status: DueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DueStatus.pending,
      ),
      delayFee: (json['delayFee'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'site_id': siteId,
      'unit_id': unitId,
      'due_type': type.name,
      'amount': amount,
      'paid_amount': paidAmount,
      'due_date': dueDate.toIso8601String(),
      'paid_date': paidDate?.toIso8601String(),
      'description': description,
      'period_month': periodMonth,
      'period_year': periodYear,
      'status': status.name,
      'delay_fee': delayFee,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from SQLite Map
  factory DueModel.fromMap(Map<String, dynamic> map) {
    return DueModel(
      id: map['id'],
      siteId: map['site_id'],
      unitId: map['unit_id'],
      type: DueType.values.firstWhere(
        (e) => e.name == map['due_type'],
        orElse: () => DueType.diger,
      ),
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0,
      dueDate: DateTime.parse(map['due_date']),
      paidDate: map['paid_date'] != null
          ? DateTime.parse(map['paid_date'])
          : null,
      description: map['description'],
      periodMonth: map['period_month'],
      periodYear: map['period_year'],
      status: DueStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DueStatus.pending,
      ),
      delayFee: (map['delay_fee'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  DueModel copyWith({
    String? id,
    String? siteId,
    String? unitId,
    DueType? type,
    double? amount,
    double? paidAmount,
    DateTime? dueDate,
    DateTime? paidDate,
    String? description,
    int? periodMonth,
    int? periodYear,
    DueStatus? status,
    double? delayFee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DueModel(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      unitId: unitId ?? this.unitId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      description: description ?? this.description,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      status: status ?? this.status,
      delayFee: delayFee ?? this.delayFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DueModel(id: $id, type: $type, amount: $amount, status: $status)';
  }
}
