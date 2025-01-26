import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class AssignmentAnalysis {
  final Map<String, dynamic> evaluation;
  final int totalScore;
  final List<String> areasOfImprovement;
  final String overallFeedback;

  AssignmentAnalysis({
    required this.evaluation,
    required this.totalScore,
    required this.areasOfImprovement,
    required this.overallFeedback,
  });

  factory AssignmentAnalysis.fromJson(Map<String, dynamic> json) {
    return AssignmentAnalysis(
      evaluation: json['evaluation'] as Map<String, dynamic>,
      totalScore: json['total_score'] as int,
      areasOfImprovement: (json['areas_of_improvement'] as List).cast<String>(),
      overallFeedback: json['overall_feedback'] as String,
    );
  }
}

class AssignmentAnalysisService {
  static Future<AssignmentAnalysis> analyzeAssignment({
    required String markingScheme,
    required String questionSheet,
    required String answerSheet,
  }) async {
    try {
      // Get the absolute path of the script
      final scriptPath = path.join(
        Directory.current.path,
        'assignment_analysis.py',
      );

      // Execute the Python script
      final result = await Process.run(
        'python3',
        [
          scriptPath,
          markingScheme,
          questionSheet,
          answerSheet,
        ],
      );

      if (result.exitCode != 0) {
        throw Exception('Error running analysis: ${result.stderr}');
      }

      // Parse the response
      final response = jsonDecode(result.stdout) as Map<String, dynamic>;

      if (!response['success']) {
        throw Exception(response['error']);
      }

      return AssignmentAnalysis.fromJson(response['analysis']);
    } catch (e) {
      throw Exception('Failed to analyze assignment: $e');
    }
  }
} 