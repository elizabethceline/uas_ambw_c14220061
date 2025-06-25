class Mood {
  final String? id; 
  final String userId;
  final String mood;
  final String? note;
  final DateTime createdAt;

  Mood({
    this.id,
    required this.userId,
    required this.mood,
    this.note,
    required this.createdAt,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      mood: json['mood'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mood': mood,
      'note': note,
      'created_at': createdAt.toIso8601String(), 
    };
  }
}
