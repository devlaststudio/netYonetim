enum AnnouncementPriority { normal, important, urgent }

class AnnouncementModel {
  final String id;
  final String siteId;
  final String title;
  final String content;
  final AnnouncementPriority priority;
  final DateTime publishDate;
  final DateTime? expireDate;
  final String createdBy;
  final bool isRead;
  final bool sendPush;
  final bool sendSms;
  final bool sendEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AnnouncementModel({
    required this.id,
    required this.siteId,
    required this.title,
    required this.content,
    required this.priority,
    required this.publishDate,
    this.expireDate,
    required this.createdBy,
    this.isRead = false,
    this.sendPush = false,
    this.sendSms = false,
    this.sendEmail = false,
    this.createdAt,
    this.updatedAt,
  });

  String get priorityDisplayName {
    switch (priority) {
      case AnnouncementPriority.normal:
        return 'Normal';
      case AnnouncementPriority.important:
        return 'Önemli';
      case AnnouncementPriority.urgent:
        return 'Acil';
    }
  }

  bool get isExpired {
    if (expireDate == null) return false;
    return DateTime.now().isAfter(expireDate!);
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'title': title,
      'content': content,
      'priority': priority.name,
      'publishDate': publishDate.toIso8601String(),
      'expireDate': expireDate?.toIso8601String(),
      'createdBy': createdBy,
      'isRead': isRead,
      'sendPush': sendPush,
      'sendSms': sendSms,
      'sendEmail': sendEmail,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON (API response)
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'],
      siteId: json['siteId'],
      title: json['title'],
      content: json['content'],
      priority: AnnouncementPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AnnouncementPriority.normal,
      ),
      publishDate: DateTime.parse(json['publishDate']),
      expireDate: json['expireDate'] != null
          ? DateTime.parse(json['expireDate'])
          : null,
      createdBy: json['createdBy'],
      isRead: json['isRead'] ?? false,
      sendPush: json['sendPush'] ?? false,
      sendSms: json['sendSms'] ?? false,
      sendEmail: json['sendEmail'] ?? false,
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
      'title': title,
      'content': content,
      'priority': priority.name,
      'publish_date': publishDate.toIso8601String(),
      'expire_date': expireDate?.toIso8601String(),
      'created_by': createdBy,
      'send_push': sendPush ? 1 : 0,
      'send_sms': sendSms ? 1 : 0,
      'send_email': sendEmail ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from SQLite Map
  factory AnnouncementModel.fromMap(
    Map<String, dynamic> map, {
    bool isRead = false,
  }) {
    return AnnouncementModel(
      id: map['id'],
      siteId: map['site_id'],
      title: map['title'],
      content: map['content'],
      priority: AnnouncementPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => AnnouncementPriority.normal,
      ),
      publishDate: DateTime.parse(map['publish_date']),
      expireDate: map['expire_date'] != null
          ? DateTime.parse(map['expire_date'])
          : null,
      createdBy: map['created_by'],
      isRead: isRead,
      sendPush: map['send_push'] == 1,
      sendSms: map['send_sms'] == 1,
      sendEmail: map['send_email'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  AnnouncementModel copyWith({
    String? id,
    String? siteId,
    String? title,
    String? content,
    AnnouncementPriority? priority,
    DateTime? publishDate,
    DateTime? expireDate,
    String? createdBy,
    bool? isRead,
    bool? sendPush,
    bool? sendSms,
    bool? sendEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      publishDate: publishDate ?? this.publishDate,
      expireDate: expireDate ?? this.expireDate,
      createdBy: createdBy ?? this.createdBy,
      isRead: isRead ?? this.isRead,
      sendPush: sendPush ?? this.sendPush,
      sendSms: sendSms ?? this.sendSms,
      sendEmail: sendEmail ?? this.sendEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AnnouncementModel(id: $id, title: $title, priority: $priority)';
  }
}
