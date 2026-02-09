enum PaymentMethod { creditCard, bankTransfer, cash, digitalWallet }

enum PaymentStatus { pending, processing, completed, failed, refunded }

class PaymentModel {
  final String id;
  final String dueId;
  final String userId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime paymentDate;
  final String? transactionId;
  final double? commissionAmount;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.dueId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.paymentDate,
    this.transactionId,
    this.commissionAmount,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Kredi Kartı';
      case PaymentMethod.bankTransfer:
        return 'Havale/EFT';
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.digitalWallet:
        return 'Dijital Cüzdan';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.pending:
        return 'Bekliyor';
      case PaymentStatus.processing:
        return 'İşleniyor';
      case PaymentStatus.completed:
        return 'Tamamlandı';
      case PaymentStatus.failed:
        return 'Başarısız';
      case PaymentStatus.refunded:
        return 'İade Edildi';
    }
  }

  double get totalWithCommission => amount + (commissionAmount ?? 0);

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dueId': dueId,
      'userId': userId,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
      'commissionAmount': commissionAmount,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (API response)
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      dueId: json['dueId'],
      userId: json['userId'],
      amount: (json['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentDate: DateTime.parse(json['paymentDate']),
      transactionId: json['transactionId'],
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
      description: json['description'],
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
      'due_id': dueId,
      'user_id': userId,
      'amount': amount,
      'payment_method': method.name,
      'status': status.name,
      'payment_date': paymentDate.toIso8601String(),
      'transaction_id': transactionId,
      'commission_amount': commissionAmount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from SQLite Map
  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'],
      dueId: map['due_id'],
      userId: map['user_id'],
      amount: (map['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == map['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentDate: DateTime.parse(map['payment_date']),
      transactionId: map['transaction_id'],
      commissionAmount: (map['commission_amount'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  /// Copy with modifications
  PaymentModel copyWith({
    String? id,
    String? dueId,
    String? userId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? paymentDate,
    String? transactionId,
    double? commissionAmount,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      dueId: dueId ?? this.dueId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionId: transactionId ?? this.transactionId,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $amount, status: $status)';
  }
}
