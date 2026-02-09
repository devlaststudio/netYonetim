enum VisitorStatus { expected, inside, left, cancelled }

class VisitorModel {
  final String id;
  final String residentId;
  final String guestName;
  final String? plateNumber;
  final DateTime expectedDate;
  final VisitorStatus status;
  final String? note;
  final DateTime? entryTime;
  final DateTime? exitTime;

  VisitorModel({
    required this.id,
    required this.residentId,
    required this.guestName,
    this.plateNumber,
    required this.expectedDate,
    required this.status,
    this.note,
    this.entryTime,
    this.exitTime,
  });

  String get statusDisplayName {
    switch (status) {
      case VisitorStatus.expected:
        return 'Bekleniyor';
      case VisitorStatus.inside:
        return 'İçeride';
      case VisitorStatus.left:
        return 'Ayrıldı';
      case VisitorStatus.cancelled:
        return 'İptal';
    }
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'residentId': residentId,
      'guestName': guestName,
      'plateNumber': plateNumber,
      'expectedDate': expectedDate.toIso8601String(),
      'status': status.name,
      'note': note,
      'entryTime': entryTime?.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
    };
  }

  /// Create from JSON (API response)
  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id'],
      residentId: json['residentId'],
      guestName: json['guestName'],
      plateNumber: json['plateNumber'],
      expectedDate: DateTime.parse(json['expectedDate']),
      status: VisitorStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VisitorStatus.expected,
      ),
      note: json['note'],
      entryTime: json['entryTime'] != null
          ? DateTime.parse(json['entryTime'])
          : null,
      exitTime: json['exitTime'] != null
          ? DateTime.parse(json['exitTime'])
          : null,
    );
  }

  VisitorModel copyWith({
    String? id,
    String? residentId,
    String? guestName,
    String? plateNumber,
    DateTime? expectedDate,
    VisitorStatus? status,
    String? note,
    DateTime? entryTime,
    DateTime? exitTime,
  }) {
    return VisitorModel(
      id: id ?? this.id,
      residentId: residentId ?? this.residentId,
      guestName: guestName ?? this.guestName,
      plateNumber: plateNumber ?? this.plateNumber,
      expectedDate: expectedDate ?? this.expectedDate,
      status: status ?? this.status,
      note: note ?? this.note,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
    );
  }
}
