enum AccountType {
  income, // Gelir
  expense, // Gider
  asset, // Varlık
  liability, // Yükümlülük
  equity, // Öz Sermaye
}

class AccountModel {
  final String id;
  final String code; // Hesap kodu (örn: 1.1.1, 2.1.1)
  final String name; // Hesap adı
  final AccountType type; // Hesap tipi
  final String? parentId; // Ana hesap ID'si (hiyerarşi için)
  final String? parentCode; // Ana hesap kodu
  final double balance; // Bakiye
  final String? description; // Açıklama
  final bool isActive; // Aktif mi?
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AccountModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.parentId,
    this.parentCode,
    this.balance = 0.0,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  String get typeDisplayName {
    switch (type) {
      case AccountType.income:
        return 'Gelir';
      case AccountType.expense:
        return 'Gider';
      case AccountType.asset:
        return 'Varlık';
      case AccountType.liability:
        return 'Yükümlülük';
      case AccountType.equity:
        return 'Öz Sermaye';
    }
  }

  bool get isParent => parentId == null;

  bool get hasBalance => balance != 0.0;

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type.name,
      'parentId': parentId,
      'parentCode': parentCode,
      'balance': balance,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (API response)
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.expense,
      ),
      parentId: json['parentId'],
      parentCode: json['parentCode'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      description: json['description'],
      isActive: json['isActive'] ?? true,
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
      'code': code,
      'name': name,
      'type': type.name,
      'parent_id': parentId,
      'parent_code': parentCode,
      'balance': balance,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from SQLite Map
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      type: AccountType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AccountType.expense,
      ),
      parentId: map['parent_id'],
      parentCode: map['parent_code'],
      balance: (map['balance'] ?? 0.0).toDouble(),
      description: map['description'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  /// Copy with modifications
  AccountModel copyWith({
    String? id,
    String? code,
    String? name,
    AccountType? type,
    String? parentId,
    String? parentCode,
    double? balance,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      parentCode: parentCode ?? this.parentCode,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AccountModel(code: $code, name: $name, type: $type, balance: $balance)';
  }
}
