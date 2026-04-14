class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    this.notes = '',
    required this.date,
    this.isDone = false,
    this.isHabit = false,
  });

  final String id;
  final String title;
  final String notes;
  final DateTime date;
  bool isDone;
  final bool isHabit;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'date': date.toIso8601String(),
      'isDone': isDone,
      'isHabit': isHabit,
    };
  }

  factory TaskItem.fromMap(Map<dynamic, dynamic> map) {
    return TaskItem(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: (map['notes'] ?? '') as String,
      date: DateTime.parse(map['date'] as String),
      isDone: (map['isDone'] ?? false) as bool,
      isHabit: (map['isHabit'] ?? false) as bool,
    );
  }
}
