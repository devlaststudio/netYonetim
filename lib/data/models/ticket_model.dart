enum TicketCategory { ariza, temizlik, guvenlik, oneri, sikayet, diger }

enum TicketStatus { open, inProgress, resolved, closed }

enum TicketPriority { low, medium, high, urgent }

class TicketModel {
  final String id;
  final String siteId;
  final String userId;
  final String userName;
  final String? unitNo;
  final TicketCategory category;
  final TicketPriority priority;
  final String title;
  final String description;
  final TicketStatus status;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? updatedAt;
  final List<TicketComment> comments;

  TicketModel({
    required this.id,
    required this.siteId,
    required this.userId,
    required this.userName,
    this.unitNo,
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    required this.status,
    this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
    this.updatedAt,
    this.comments = const [],
  });

  String get categoryDisplayName {
    switch (category) {
      case TicketCategory.ariza:
        return '🔧 Arıza';
      case TicketCategory.temizlik:
        return '🧹 Temizlik';
      case TicketCategory.guvenlik:
        return '🔒 Güvenlik';
      case TicketCategory.oneri:
        return '💡 Öneri';
      case TicketCategory.sikayet:
        return '⚠️ Şikayet';
      case TicketCategory.diger:
        return '📝 Diğer';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TicketStatus.open:
        return 'Açık';
      case TicketStatus.inProgress:
        return 'İşlemde';
      case TicketStatus.resolved:
        return 'Çözüldü';
      case TicketStatus.closed:
        return 'Kapatıldı';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case TicketPriority.low:
        return 'Düşük';
      case TicketPriority.medium:
        return 'Normal';
      case TicketPriority.high:
        return 'Yüksek';
      case TicketPriority.urgent:
        return 'Acil';
    }
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'userId': userId,
      'userName': userName,
      'unitNo': unitNo,
      'category': category.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'status': status.name,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  /// Create from JSON (API response)
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      siteId: json['siteId'],
      userId: json['userId'],
      userName: json['userName'],
      unitNo: json['unitNo'],
      category: TicketCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TicketCategory.diger,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      title: json['title'],
      description: json['description'],
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      assignedTo: json['assignedTo'],
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List)
                .map((c) => TicketComment.fromJson(c))
                .toList()
          : [],
    );
  }

  /// Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'site_id': siteId,
      'user_id': userId,
      'category': category.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'status': status.name,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from SQLite Map (comments loaded separately)
  factory TicketModel.fromMap(
    Map<String, dynamic> map, {
    String? userName,
    String? unitNo,
    List<TicketComment>? comments,
  }) {
    return TicketModel(
      id: map['id'],
      siteId: map['site_id'],
      userId: map['user_id'],
      userName: userName ?? '',
      unitNo: unitNo,
      category: TicketCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TicketCategory.diger,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TicketPriority.medium,
      ),
      title: map['title'],
      description: map['description'],
      status: TicketStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TicketStatus.open,
      ),
      assignedTo: map['assigned_to'],
      createdAt: DateTime.parse(map['created_at']),
      resolvedAt: map['resolved_at'] != null
          ? DateTime.parse(map['resolved_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      comments: comments ?? [],
    );
  }

  TicketModel copyWith({
    String? id,
    String? siteId,
    String? userId,
    String? userName,
    String? unitNo,
    TicketCategory? category,
    TicketPriority? priority,
    String? title,
    String? description,
    TicketStatus? status,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? resolvedAt,
    DateTime? updatedAt,
    List<TicketComment>? comments,
  }) {
    return TicketModel(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      unitNo: unitNo ?? this.unitNo,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comments: comments ?? this.comments,
    );
  }

  @override
  String toString() {
    return 'TicketModel(id: $id, title: $title, status: $status)';
  }
}

class TicketComment {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final bool isStaff;

  TicketComment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.isStaff = false,
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isStaff': isStaff,
    };
  }

  /// Create from JSON (API response)
  factory TicketComment.fromJson(Map<String, dynamic> json) {
    return TicketComment(
      id: json['id'],
      ticketId: json['ticketId'],
      userId: json['userId'],
      userName: json['userName'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isStaff: json['isStaff'] ?? false,
    );
  }

  /// Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from SQLite Map
  factory TicketComment.fromMap(
    Map<String, dynamic> map, {
    String? userName,
    bool? isStaff,
  }) {
    return TicketComment(
      id: map['id'],
      ticketId: map['ticket_id'],
      userId: map['user_id'],
      userName: userName ?? '',
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      isStaff: isStaff ?? false,
    );
  }

  @override
  String toString() {
    return 'TicketComment(id: $id, ticketId: $ticketId)';
  }
}
