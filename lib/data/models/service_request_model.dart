import 'dart:convert';

enum ServiceRequestStatus {
  pending,
  approved,
  inProgress,
  completed,
  cancelled,
}

class ServiceRequestModel {
  final String id;
  final String residentId;
  final String technicianId;
  final String categoryId; // e.g., 'plumbing'
  final String description;
  final ServiceRequestStatus status;
  final DateTime requestDate;
  final DateTime appointmentDate;
  final List<String> photos; // Simulated file paths or URLs
  final double? rating;
  final String? reviewComment;

  const ServiceRequestModel({
    required this.id,
    required this.residentId,
    required this.technicianId,
    required this.categoryId,
    required this.description,
    required this.status,
    required this.requestDate,
    required this.appointmentDate,
    this.photos = const [],
    this.rating,
    this.reviewComment,
  });

  String get statusDisplayName {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'Bekliyor';
      case ServiceRequestStatus.approved:
        return 'Onaylandı';
      case ServiceRequestStatus.inProgress:
        return 'İşlemde';
      case ServiceRequestStatus.completed:
        return 'Tamamlandı';
      case ServiceRequestStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'residentId': residentId,
      'technicianId': technicianId,
      'categoryId': categoryId,
      'description': description,
      'status': status.index,
      'requestDate': requestDate.toIso8601String(),
      'appointmentDate': appointmentDate.toIso8601String(),
      'photos': photos,
      'rating': rating,
      'reviewComment': reviewComment,
    };
  }

  factory ServiceRequestModel.fromMap(Map<String, dynamic> map) {
    return ServiceRequestModel(
      id: map['id'],
      residentId: map['residentId'],
      technicianId: map['technicianId'],
      categoryId: map['categoryId'],
      description: map['description'],
      status: ServiceRequestStatus.values[map['status'] as int],
      requestDate: DateTime.parse(map['requestDate']),
      appointmentDate: DateTime.parse(map['appointmentDate']),
      photos: List<String>.from(map['photos'] ?? []),
      rating: map['rating'],
      reviewComment: map['reviewComment'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceRequestModel.fromJson(String source) =>
      ServiceRequestModel.fromMap(json.decode(source));
}
