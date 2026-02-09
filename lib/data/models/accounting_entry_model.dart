enum EntryType {
  income, // Gelir
  expense, // Gider
  transfer, // Transfer
}

enum PaymentMethodType {
  cash, // Nakit
  bankTransfer, // Havale/EFT
  creditCard, // Kredi Kartı
  check, // Çek
  other, // Diğer
}

class AccountingEntryModel {
  final String id;
  final String accountId; // İlgili hesap ID'si
  final String accountCode; // İlgili hesap kodu
  final String accountName; // İlgili hesap adı
  final EntryType entryType; // Giriş tipi
  final double amount; // Tutar
  final DateTime transactionDate; // İşlem tarihi
  final String description; // Açıklama
  final String? documentNumber; // Belge numarası
  final String? reference; // Referans (fatura no, makbuz no, vb.)
  final PaymentMethodType? paymentMethod; // Ödeme yöntemi
  final String? unitId; // Bağlı daire ID'si (varsa)
  final String? unitNo; // Bağlı daire no (varsa)
  final String? createdBy; // Oluşturan kullanıcı
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AccountingEntryModel({
    required this.id,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.entryType,
    required this.amount,
    required this.transactionDate,
    required this.description,
    this.documentNumber,
    this.reference,
    this.paymentMethod,
    this.unitId,
    this.unitNo,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  String get entryTypeDisplayName {
    switch (entryType) {
      case EntryType.income:
        return 'Gelir';
      case EntryType.expense:
        return 'Gider';
      case EntryType.transfer:
        return 'Transfer';
    }
  }

  String get paymentMethodDisplayName {
    if (paymentMethod == null) return '-';
    switch (paymentMethod!) {
      case PaymentMethodType.cash:
        return 'Nakit';
      case PaymentMethodType.bankTransfer:
        return 'Havale/EFT';
      case PaymentMethodType.creditCard:
        return 'Kredi Kartı';
      case PaymentMethodType.check:
        return 'Çek';
      case PaymentMethodType.other:
        return 'Diğer';
    }
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'accountCode': accountCode,
      'accountName': accountName,
      'entryType': entryType.name,
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      'documentNumber': documentNumber,
      'reference': reference,
      'paymentMethod': paymentMethod?.name,
      'unitId': unitId,
      'unitNo': unitNo,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (API response)
  factory AccountingEntryModel.fromJson(Map<String, dynamic> json) {
    return AccountingEntryModel(
      id: json['id'],
      accountId: json['accountId'],
      accountCode: json['accountCode'],
      accountName: json['accountName'],
      entryType: EntryType.values.firstWhere(
        (e) => e.name == json['entryType'],
        orElse: () => EntryType.expense,
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
      description: json['description'],
      documentNumber: json['documentNumber'],
      reference: json['reference'],
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethodType.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
              orElse: () => PaymentMethodType.other,
            )
          : null,
      unitId: json['unitId'],
      unitNo: json['unitNo'],
      createdBy: json['createdBy'],
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
      'account_id': accountId,
      'account_code': accountCode,
      'account_name': accountName,
      'entry_type': entryType.name,
      'amount': amount,
      'transaction_date': transactionDate.toIso8601String(),
      'description': description,
      'document_number': documentNumber,
      'reference': reference,
      'payment_method': paymentMethod?.name,
      'unit_id': unitId,
      'unit_no': unitNo,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from SQLite Map
  factory AccountingEntryModel.fromMap(Map<String, dynamic> map) {
    return AccountingEntryModel(
      id: map['id'],
      accountId: map['account_id'],
      accountCode: map['account_code'],
      accountName: map['account_name'],
      entryType: EntryType.values.firstWhere(
        (e) => e.name == map['entry_type'],
        orElse: () => EntryType.expense,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      transactionDate: DateTime.parse(map['transaction_date']),
      description: map['description'],
      documentNumber: map['document_number'],
      reference: map['reference'],
      paymentMethod: map['payment_method'] != null
          ? PaymentMethodType.values.firstWhere(
              (e) => e.name == map['payment_method'],
              orElse: () => PaymentMethodType.other,
            )
          : null,
      unitId: map['unit_id'],
      unitNo: map['unit_no'],
      createdBy: map['created_by'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  /// Copy with modifications
  AccountingEntryModel copyWith({
    String? id,
    String? accountId,
    String? accountCode,
    String? accountName,
    EntryType? entryType,
    double? amount,
    DateTime? transactionDate,
    String? description,
    String? documentNumber,
    String? reference,
    PaymentMethodType? paymentMethod,
    String? unitId,
    String? unitNo,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountingEntryModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      entryType: entryType ?? this.entryType,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      documentNumber: documentNumber ?? this.documentNumber,
      reference: reference ?? this.reference,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      unitId: unitId ?? this.unitId,
      unitNo: unitNo ?? this.unitNo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AccountingEntryModel(id: $id, type: $entryType, amount: $amount, date: $transactionDate)';
  }
}
