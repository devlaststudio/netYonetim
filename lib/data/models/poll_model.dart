import 'dart:convert';

class PollOption {
  final String id;
  final String text;
  final int voteCount;

  const PollOption({
    required this.id,
    required this.text,
    required this.voteCount,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'voteCount': voteCount};
  }

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      id: map['id'],
      text: map['text'],
      voteCount: map['voteCount'] ?? 0,
    );
  }
}

class PollModel {
  final String id;
  final String title;
  final String description;
  final List<PollOption> options;
  final DateTime endDate;
  final bool isActive;
  final bool hasVoted;
  final String? selectedOptionId;

  const PollModel({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.endDate,
    this.isActive = true,
    this.hasVoted = false,
    this.selectedOptionId,
  });

  int get totalVotes => options.fold(0, (sum, item) => sum + item.voteCount);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'options': options.map((x) => x.toMap()).toList(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'hasVoted': hasVoted,
      'selectedOptionId': selectedOptionId,
    };
  }

  factory PollModel.fromMap(Map<String, dynamic> map) {
    return PollModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      options: List<PollOption>.from(
        map['options']?.map((x) => PollOption.fromMap(x)) ?? [],
      ),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] ?? true,
      hasVoted: map['hasVoted'] ?? false,
      selectedOptionId: map['selectedOptionId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PollModel.fromJson(String source) =>
      PollModel.fromMap(json.decode(source));
}
