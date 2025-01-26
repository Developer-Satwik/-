class Assignment {
  final String id;
  final String title;
  final DateTime deadline;

  Assignment({required this.id, required this.title, required this.deadline});

  factory Assignment.fromMap(Map<String, dynamic> data) {
    return Assignment(
      id: data['id'],
      title: data['title'],
      deadline: DateTime.parse(data['deadline']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline.toIso8601String(),
    };
  }
}