class Marksheet {
  String subject;
  double marksObtained;
  double totalMarks;
  String feedback;

  // Constructor with required fields and optional feedback
  Marksheet({
    required this.subject,
    required this.marksObtained,
    required this.totalMarks,
    required this.feedback,
  });

  // Convert Marksheet object to a map (useful for Firebase, Supabase, etc.)
  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'marksObtained': marksObtained,
      'totalMarks': totalMarks,
      'feedback': feedback,
    };
  }

  // Create a Marksheet object from a map (useful for deserialization)
  factory Marksheet.fromMap(Map<String, dynamic> map) {
    return Marksheet(
      subject: map['subject'] ?? '', // Default to empty string if null
      marksObtained: map['marksObtained'] ?? 0, // Default to 0 if null
      totalMarks: map['totalMarks'] ?? 100, // Default to 100 if null
      feedback: map['feedback'] ?? '', // Default to empty string if null
    );
  }

  // Override toString() for easy debugging
  @override
  String toString() {
    return 'Marksheet(subject: $subject, marksObtained: $marksObtained, totalMarks: $totalMarks, feedback: $feedback)';
  }

  // Override equality check for comparing Marksheet objects
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Marksheet &&
        other.subject == subject &&
        other.marksObtained == marksObtained &&
        other.totalMarks == totalMarks &&
        other.feedback == feedback;
  }

  // Override hashCode for consistency with equality
  @override
  int get hashCode {
    return subject.hashCode ^
        marksObtained.hashCode ^
        totalMarks.hashCode ^
        feedback.hashCode;
  }
}