import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'assignment_model.dart';

class AssignmentEvaluationService {
  static final String _pythonScriptPath = path.join('lib', 'python', 'analyze.py');
  
  /// Analyzes an assignment using the Python script
  /// Returns a Map containing the analysis results
  Future<Map<String, dynamic>> analyzeAssignment({
    required String markingScheme,
    required String questionSheet,
    required String answerSheet,
  }) async {
    try {
      // Input validation
      if (markingScheme.isEmpty || questionSheet.isEmpty || answerSheet.isEmpty) {
        throw Exception('All inputs (marking scheme, question sheet, answer sheet) are required');
      }

      // Ensure Python environment is set up
      await _checkPythonEnvironment();

      final result = await Process.run(
        'python',
        [
          _pythonScriptPath,
          markingScheme,
          questionSheet,
          answerSheet,
        ],
      );

      if (result.exitCode == 0) {
        try {
          final response = jsonDecode(result.stdout) as Map<String, dynamic>;
          
          // Check if there was an error in the Python script
          if (response['status'] == 'failed') {
            throw Exception(response['error'] ?? 'Unknown error in analysis');
          }
          
          return response;
        } catch (e) {
          throw Exception('Failed to parse analysis results: $e');
        }
      } else {
        throw Exception('Analysis failed: ${result.stderr}');
      }
    } catch (e) {
      return {
        'status': 'failed',
        'error': e.toString(),
      };
    }
  }

  /// Checks if Python environment is properly set up
  Future<void> _checkPythonEnvironment() async {
    try {
      final pythonVersion = await Process.run('python', ['--version']);
      if (pythonVersion.exitCode != 0) {
        throw Exception('Python is not installed or not accessible');
      }

      // Check if requirements are installed
      final requirementsPath = path.join('lib', 'python', 'requirements.txt');
      final requirements = File(requirementsPath);
      
      if (await requirements.exists()) {
        final installResult = await Process.run(
          'pip',
          ['install', '-r', requirementsPath],
        );
        
        if (installResult.exitCode != 0) {
          throw Exception('Failed to install Python dependencies: ${installResult.stderr}');
        }
      } else {
        throw Exception('Requirements file not found at $requirementsPath');
      }
    } catch (e) {
      throw Exception('Failed to set up Python environment: $e');
    }
  }

  /// Evaluates an assignment using the marking scheme
  static Future<Map<String, dynamic>> evaluateAssignment(Assignment assignment, String markingScheme) async {
    try {
      if (markingScheme.isEmpty) {
        throw Exception('Marking scheme cannot be empty');
      }
      
      if (assignment.description == null || assignment.filePath == null) {
        throw Exception('Assignment description and file path are required');
      }

      final service = AssignmentEvaluationService();
      return await service.analyzeAssignment(
        markingScheme: markingScheme,
        questionSheet: assignment.description!,
        answerSheet: await File(assignment.filePath!).readAsString(),
      );
    } catch (e) {
      return {
        'status': 'failed',
        'error': 'Failed to evaluate assignment: $e',
      };
    }
  }
}