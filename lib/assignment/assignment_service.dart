import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'assignment_model.dart';

class AssignmentService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<List<Assignment>> getAssignments(String studentId) async {
    try {
      final response = await _supabase
          .from('assignments')
          .select()
          .eq('studentId', studentId);

      if (response.isEmpty) {
        return []; // Return an empty list if no assignments are found
      }

      return response.map((assignment) => Assignment.fromMap(assignment)).toList();
    } catch (e) {
      print('Error fetching assignments: $e');
      throw Exception('Failed to fetch assignments. Please try again.');
    }
  }

  static Future<void> uploadAssignment(Assignment assignment) async {
    try {
      await _supabase
          .from('assignments')
          .upsert([assignment.toMap()]);
    } catch (e) {
      print('Error uploading assignment: $e');
      throw Exception('Failed to upload assignment. Please try again.');
    }
  }

  static Future<Map<String, dynamic>> analyzeAssignment({
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

      return response['analysis'];
    } catch (e) {
      throw Exception('Failed to analyze assignment: $e');
    }
  }
}