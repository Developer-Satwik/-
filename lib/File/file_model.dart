class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String studentId; // Student who submitted the assignment
  final String? courseId; // Course the assignment belongs to (optional)
  final String? teacherId; // Teacher who created the assignment (optional)

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.studentId,
    this.courseId,
    this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'student_id': studentId,
      'course_id': courseId,
      'teacher_id': teacherId,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
      studentId: map['student_id'],
      courseId: map['course_id'],
      teacherId: map['teacher_id'],
    );
  }
}