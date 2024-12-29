class Task {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isPriority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reminderTime;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isPriority = false,
    required this.createdAt,
    required this.updatedAt,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'isPriority': isPriority ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      isPriority: map['isPriority'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      reminderTime:
          map['reminderTime'] != null && map['reminderTime'].isNotEmpty
              ? DateTime.tryParse(
                  map['reminderTime']) // Use tryParse to avoid exceptions
              : null,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isPriority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isPriority: isPriority ?? this.isPriority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
