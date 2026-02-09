enum UserRole { admin, manager, resident, tenant }

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final UserRole role;
  final String? siteId;
  final String? unitId;
  final String? unitNo;
  final String? blockName;
  final String? avatarUrl;
  final String? tcKimlik;
  final String? passwordHash;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    this.siteId,
    this.unitId,
    this.unitNo,
    this.blockName,
    this.avatarUrl,
    this.tcKimlik,
    this.passwordHash,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Site Yöneticisi';
      case UserRole.manager:
        return 'Yönetici';
      case UserRole.resident:
        return 'Kat Maliki';
      case UserRole.tenant:
        return 'Kiracı';
    }
  }

  String get unitDisplay {
    if (blockName != null && unitNo != null) {
      return '$blockName Blok - Daire $unitNo';
    }
    return unitNo ?? '';
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role.name,
      'siteId': siteId,
      'unitId': unitId,
      'unitNo': unitNo,
      'blockName': blockName,
      'avatarUrl': avatarUrl,
      'tcKimlik': tcKimlik,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.resident,
      ),
      siteId: json['siteId'],
      unitId: json['unitId'],
      unitNo: json['unitNo'],
      blockName: json['blockName'],
      avatarUrl: json['avatarUrl'],
      tcKimlik: json['tcKimlik'],
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
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'user_type': role.name,
      'tc_kimlik': tcKimlik,
      'password_hash': passwordHash,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from SQLite Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      phone: map['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['user_type'],
        orElse: () => UserRole.resident,
      ),
      tcKimlik: map['tc_kimlik'],
      passwordHash: map['password_hash'],
      avatarUrl: map['avatar_url'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  /// Copy with modifications
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    String? siteId,
    String? unitId,
    String? unitNo,
    String? blockName,
    String? avatarUrl,
    String? tcKimlik,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      siteId: siteId ?? this.siteId,
      unitId: unitId ?? this.unitId,
      unitNo: unitNo ?? this.unitNo,
      blockName: blockName ?? this.blockName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tcKimlik: tcKimlik ?? this.tcKimlik,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: $role)';
  }
}
