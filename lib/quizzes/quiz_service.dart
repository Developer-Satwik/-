import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class QuizService {
  static const String _apiKey = 'AIzaSyC7EluuQmw1KB-hoVM4s6u3u7-vT7ezc7U';
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: _apiKey,
  );
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Generate a quiz based on a topic, number of questions, and difficulty
  static Future<List<Map<String, dynamic>>> generateQuiz(
    String topic,
    int numberOfQuestions,
    String difficulty,
  ) async {
    try {
      final prompt = 'Generate a quiz with $numberOfQuestions multiple-choice questions on the topic: $topic. '
          'The difficulty level should be $difficulty. '
          'Format the response as a JSON list where each question has a "question", "options", and "correctAnswer" field.';
      final response = await _model.generateContent([Content.text(prompt)]);

      final quiz = _parseQuizResponse(response.text ?? '');
      return quiz;
    } catch (e) {
      print('Error generating quiz: $e');
      return [];
    }
  }

  // Generate a personalized quiz based on the student's learning curve
  static Future<List<Map<String, dynamic>>> generatePersonalizedQuiz() async {
    try {
      // Fetch the student's quiz results to analyze strengths and weaknesses
      const studentId = 'STUDENT_ID'; // Replace with actual student ID
      final results = await fetchQuizResults(studentId);

      // Analyze results to determine weak areas
      String weakAreas = _analyzeWeakAreas(results);

      // Generate a quiz focused on weak areas
      final prompt = 'Generate a personalized quiz with 5 multiple-choice questions focusing on: $weakAreas. '
          'Format the response as a JSON list where each question has a "question", "options", and "correctAnswer" field.';
      final response = await _model.generateContent([Content.text(prompt)]);

      final quiz = _parseQuizResponse(response.text ?? '');
      return quiz;
    } catch (e) {
      print('Error generating personalized quiz: $e');
      return [];
    }
  }

  // Analyze quiz results to determine weak areas
  static String _analyzeWeakAreas(List<Map<String, dynamic>> results) {
    // Example: Identify topics with the lowest scores
    Map<String, int> topicScores = {};
    for (var result in results) {
      String topic = result['topic'] ?? 'General';
      int score = result['score'] ?? 0;
      topicScores[topic] = (topicScores[topic] ?? 0) + score;
    }

    // Find the topic with the lowest score
    String weakArea = topicScores.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    return weakArea;
  }

  // Get AI suggestions for quiz creation
  static Future<String> getAISuggestion(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No suggestions available.';
    } catch (e) {
      print('Error getting AI suggestion: $e');
      return 'Failed to get suggestions.';
    }
  }

  // Parse the quiz response into a list of questions
  static List<Map<String, dynamic>> _parseQuizResponse(String response) {
    try {
      final parsedResponse = jsonDecode(response) as List;
      return parsedResponse.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error parsing quiz response: $e');
      return [];
    }
  }

  // Save a new quiz to the database
  static Future<void> saveQuiz(Map<String, dynamic> quizData) async {
    try {
      await _supabase.from('quizzes').insert(quizData);
    } catch (e) {
      print('Error saving quiz: $e');
    }
  }

  // Fetch quiz results for a specific student
  static Future<List<Map<String, dynamic>>> fetchQuizResults(String studentId) async {
    try {
      final response = await _supabase
          .from('quiz_results')
          .select('*')
          .eq('student_id', studentId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quiz results: $e');
      return [];
    }
  }

  // Fetch all quizzes from the database
  static Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    try {
      final response = await _supabase.from('quizzes').select('*');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quizzes: $e');
      return [];
    }
  }

  // Fetch a specific quiz by its ID
  static Future<Map<String, dynamic>?> fetchQuizById(String quizId) async {
    try {
      final response = await _supabase
          .from('quizzes')
          .select('*')
          .eq('id', quizId)
          .single();
      return response;
    } catch (e) {
      print('Error fetching quiz by ID: $e');
      return null;
    }
  }

  // Save quiz results for a student
  static Future<void> saveQuizResults({
    required String quizId,
    required String studentId,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      await _supabase.from('quiz_results').insert({
        'quiz_id': quizId,
        'student_id': studentId,
        'score': score,
        'total_questions': totalQuestions,
        'submitted_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving quiz results: $e');
    }
  }

  // Fetch all quiz results for a specific quiz (for teachers)
  static Future<List<Map<String, dynamic>>> fetchQuizResultsForQuiz(String quizId) async {
    try {
      final response = await _supabase
          .from('quiz_results')
          .select('*')
          .eq('quiz_id', quizId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quiz results for quiz: $e');
      return [];
    }
  }

  // Delete a quiz by its ID
  static Future<void> deleteQuiz(String quizId) async {
    try {
      await _supabase.from('quizzes').delete().eq('id', quizId);
    } catch (e) {
      print('Error deleting quiz: $e');
    }
  }

  // Update a quiz by its ID
  static Future<void> updateQuiz(String quizId, Map<String, dynamic> updatedData) async {
    try {
      await _supabase.from('quizzes').update(updatedData).eq('id', quizId);
    } catch (e) {
      print('Error updating quiz: $e');
    }
  }

  static Future<Map<String, dynamic>> generateQuestion(String topic, {String? description}) async {
    try {
      final prompt = '''
Generate a unique and diverse multiple-choice question about $topic that hasn't been covered before.${description != null ? '\nAdditional context: $description' : ''}
Ensure the question tests a different aspect or concept of the topic than previous questions.
Format the response as JSON with the following structure:
{
  "question": "The question text",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correctAnswer": 0 // Index of the correct answer (0-3)
}
Make sure the question is challenging but clear, and all options are plausible but only one is correct.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final jsonStr = response.text ?? '';
      
      if (jsonStr.isEmpty) {
        throw Exception('Empty response from AI');
      }
      
      // Parse the JSON response and validate its structure
      final Map<String, dynamic> questionData = jsonDecode(jsonStr);
      if (!_validateQuestionFormat(questionData)) {
        throw Exception('Invalid question format received from AI');
      }
      
      return questionData;
    } catch (e) {
      throw Exception('Failed to generate question: $e');
    }
  }

  static bool _validateQuestionFormat(Map<String, dynamic> data) {
    return data.containsKey('question') &&
           data.containsKey('options') &&
           data.containsKey('correctAnswer') &&
           data['options'] is List &&
           (data['options'] as List).length == 4 &&
           data['correctAnswer'] is int &&
           data['correctAnswer'] >= 0 &&
           data['correctAnswer'] < 4;
  }
}