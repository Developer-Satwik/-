class Course {
  final String id;
  final String title;
  final String description;

  Course({required this.id, required this.title, required this.description});

  factory Course.fromMap(Map<String, dynamic> data) {
    return Course(
      id: data['id'],
      title: data['title'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}