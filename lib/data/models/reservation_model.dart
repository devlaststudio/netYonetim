enum ReservationStatus { active, completed, cancelled }

class ReservationModel {
  final String id;
  final String facilityId;
  final String facilityName; // Denormalized for easier display
  final String residentId;
  final DateTime startTime;
  final int durationMinutes;
  final ReservationStatus status;
  final String? note;

  const ReservationModel({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.residentId,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
    this.note,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));
}
