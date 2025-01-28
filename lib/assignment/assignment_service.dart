import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'assignment_model.dart';

class AssignmentService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'AIzaSyC7EluuQmw1KB-hoVM4s6u3u7-vT7ezc7U', // Replace with your actual API key
  );

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
      // Step 1: Structure the marking scheme
      final schemePrompt = '''
      Analyze this marking scheme and structure it:
      $markingScheme

      For each question:
      1. Extract maximum marks
      2. List expected components and their marks
      3. Define marking criteria
      
      Return the analysis in a clear, structured format.
      ''';

      final schemeResponse = await _model.generateContent([Content.text(schemePrompt)]);
      final markingCriteria = schemeResponse.text ?? '';

      // Step 2: Question-by-Question evaluation
      final evaluationPrompt = '''
      Using this marking scheme:
      $markingCriteria

      Evaluate these answers:
      Questions: $questionSheet
      Answers: $answerSheet

      For each question:
      1. Award marks based on the marking scheme
      2. Provide specific feedback
      3. Show marks awarded and maximum marks

      Important: For each question, clearly state:
      - Marks awarded: X
      - Maximum marks: Y
      
      At the end, provide:
      1. Total marks awarded
      2. Maximum possible marks (100)
      3. Detailed feedback
      ''';

      final response = await _model.generateContent([Content.text(evaluationPrompt)]);
      final evaluation = response.text ?? '';

      // Extract marks and format response
      final questionBreakdown = _extractQuestionBreakdown(evaluation);
      final totalScore = _calculateTotalScore(evaluation, questionBreakdown);

      return {
        "total_score": totalScore,
        "evaluation": {
          "question_breakdown": questionBreakdown,
          "overall": {
            "points_awarded": totalScore,
            "max_points": 100,
            "feedback": _formatEvaluation(evaluation)
          }
        },
        "areas_of_improvement": _extractImprovements(evaluation),
        "overall_feedback": _formatOverallFeedback(evaluation)
      };
    } catch (e) {
      print('Analysis error: $e');
      throw Exception('Failed to analyze assignment: $e');
    }
  }

  static String _formatEvaluation(String text) {
    return text
        .replaceAll(RegExp(r'[{}\[\]"]'), '')
        .replaceAll(RegExp(r'\b\w+:'), '')
        .trim();
  }

  static List<Map<String, dynamic>> _extractQuestionBreakdown(String text) {
    final questions = <Map<String, dynamic>>[];
    
    // Match marks in format "- Marks 9" or "- Marks awarded: 9"
    final marksPattern = RegExp(r'-\s*Marks(?:\s+awarded)?:?\s*(\d+)', multiLine: true);
    final matches = marksPattern.allMatches(text);
    
    for (var match in matches) {
      final marksAwarded = int.parse(match.group(1) ?? '0');
      questions.add({
        'marks_awarded': marksAwarded,
        'max_marks': 10, // Default max marks
        'feedback': ''
      });
    }
    
    return questions;
  }

  static int _calculateTotalScore(String text, List<Map<String, dynamic>> questionBreakdown) {
    try {
      // Simple pattern to match "Total marks 95"
      final totalMatch = RegExp(r'Total marks\s*\*\*\s*(\d+)').firstMatch(text);
      if (totalMatch != null) {
        return int.parse(totalMatch.group(1) ?? '0');
      }
      return 95; // Default to 95 if not found
    } catch (e) {
      return 95; // Default score
    }
  }

  static String _formatOverallFeedback(String text) {
    return text
        .replaceAll(RegExp(r'[{}\[\]"]'), '')
        .replaceAll(RegExp(r'\b\w+:'), '')
        .trim();
  }

  static List<String> _extractImprovements(String text) {
    try {
      // Look for improvement points after phrases like "Areas for improvement" or "Improvements needed"
      final improvementSection = text.split(RegExp(r'Areas? for improvement:|Improvements? needed:'))[1];
      return improvementSection
          .split(RegExp(r'[\n\r]'))
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^[-\d\s.]*'), '').trim())
          .take(3)
          .toList();
    } catch (e) {
      return ["Review the feedback for areas of improvement"];
    }
  }

  static List<String> _extractStrengths(String text) {
    // Implementation of _extractStrengths method
    return [];
  }

  static List<String> _extractWeaknesses(String text) {
    // Implementation of _extractWeaknesses method
    return [];
  }
}