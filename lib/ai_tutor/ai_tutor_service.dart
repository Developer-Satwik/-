import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert'; // For JSON parsing

class AIService {
  // Initialize the Gemini model
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'AIzaSyC7EluuQmw1KB-hoVM4s6u3u7-vT7ezc7U', // Replace with your actual API key
  );

  /// Asks a question to the AI tutor.
  ///
  /// [question]: The question to ask.
  /// [context]: Optional context to provide additional information.
  /// Returns a response from the AI tutor or an error message.
  static Future<String> askQuestion(String question, {Map<String, dynamic>? context}) async {
    try {
      // Build the prompt with optional context
      String prompt = question;
      if (context != null) {
        prompt = 'Context: ${jsonEncode(context)}\nQuestion: $question';
      }

      // Add educational context to make responses more tutor-like
      final fullPrompt = '''
You are an AI tutor helping a student learn. Please provide a helpful, encouraging, and educational response.

Student's Question: $prompt

Please provide a clear, concise explanation that helps the student understand the topic better.''';

      // Generate content using the AI model
      final response = await _model.generateContent([Content.text(fullPrompt)]);
      final responseText = response.text;
      
      if (responseText == null || responseText.isEmpty) {
        return 'I apologize, but I was unable to generate a response. Please try asking your question in a different way.';
      }
      
      return responseText;
    } catch (e) {
      print('Error asking question: $e');
      return 'I encountered an error while processing your question. Please check your internet connection and try again.';
    }
  }

  /// Summarizes the provided text using the AI tutor.
  ///
  /// [text]: The text to summarize.
  /// Returns a summarized version of the text or an error message.
  static Future<String> summarizeText(String text) async {
    try {
      final prompt = 'Summarize the following text: $text';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No summary available.';
    } catch (e) {
      print('Error summarizing text: $e');
      return 'Failed to generate a summary. Please try again.';
    }
  }

  /// Generates a quiz based on a topic.
  ///
  /// [topic]: The topic for the quiz.
  /// Returns a list of quiz questions or an empty list if an error occurs.
  static Future<List<Map<String, dynamic>>> generateQuiz(String topic) async {
    try {
      final prompt = '''
Generate a quiz with 3 multiple-choice questions on the topic: $topic.
Format the response as a JSON list where each question has a "question", "options", and "correctAnswer" field.
Example:
[
  {
    "question": "What is the capital of France?",
    "options": ["Berlin", "Paris", "Madrid", "Rome"],
    "correctAnswer": 1
  }
]
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseQuizResponse(response.text ?? '');
    } catch (e) {
      print('Error generating quiz: $e');
      return [];
    }
  }

  /// Parses the quiz response from the AI into a list of questions.
  ///
  /// [response]: The raw response from the AI.
  /// Returns a list of quiz questions or an empty list if parsing fails.
  static List<Map<String, dynamic>> _parseQuizResponse(String response) {
    try {
      final parsedResponse = jsonDecode(response) as List;
      return parsedResponse.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error parsing quiz response: $e');
      return [];
    }
  }

  /// Generates a motivational quote for students
  ///
  /// Returns a motivational quote or a default message if an error occurs.
  static Future<String> generateMotivationalQuote() async {
    try {
      const prompt = '''
Please generate an inspiring and motivational quote specifically for students.
The quote should be:
- Brief and impactful
- Education-focused
- Encouraging and positive
- Original (not a famous quote)
''';
      
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Keep pushing forward. Every step counts on your educational journey.';
    } catch (e) {
      print('Error generating quote: $e');
      return 'Keep pushing forward. Every step counts on your educational journey.';
    }
  }
}