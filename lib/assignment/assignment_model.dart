class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String studentId;
  final String? filePath;
  final double? marks;
  final String? feedback;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.studentId,
    this.filePath,
    this.marks,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'studentId': studentId,
      'filePath': filePath,
      'marks': marks,
      'feedback': feedback,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
      studentId: map['studentId'],
      filePath: map['filePath'],
      marks: map['marks'],
      feedback: map['feedback'],
    );
  }
}