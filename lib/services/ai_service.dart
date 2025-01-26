import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const _apiKey = 'YOUR_API_KEY';  // Replace with your actual API key
  static final _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);

  // Method to ask a question with optional context
  static Future<String> askQuestion(String question, {Map<String, dynamic>? context}) async {
    // Simulate an API call to an AI service (e.g., OpenAI, GPT, etc.)
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    // If context is provided, generate a context-aware response
    if (context != null) {
      if (context.containsKey('classSchedule')) {
        final classSchedule = context['classSchedule'];
        if (question.toLowerCase().contains('next class')) {
          return 'Your next class is ${classSchedule[0]['title']} at ${classSchedule[0]['time']}.';
        }
        if (question.toLowerCase().contains('science class')) {
          final scienceClass = classSchedule.firstWhere(
            (cls) => cls['title'].toString().toLowerCase().contains('science'),
            orElse: () => null,
          );
          if (scienceClass != null) {
            return 'Your Science class is at ${scienceClass['time']} in ${scienceClass['room']}.';
          } else {
            return 'You do not have a Science class scheduled today.';
          }
        }
      }

      if (context.containsKey('assignments')) {
        final assignments = context['assignments'];
        if (question.toLowerCase().contains('assignment')) {
          final upcomingAssignments = assignments
              .where((assignment) => !assignment['isCompleted'])
              .toList();
          if (upcomingAssignments.isNotEmpty) {
            return 'You have ${upcomingAssignments.length} upcoming assignments. The next one is "${upcomingAssignments[0]['title']}" due in ${upcomingAssignments[0]['deadline'].difference(DateTime.now()).inHours} hours.';
          } else {
            return 'You have no upcoming assignments. Great job!';
          }
        }
      }
    }

    // Default response if no context matches
    return 'I am here to help! Let me know if you have any questions about your schedule or assignments.';
  }

  // Method to summarize text
  static Future<String> summarizeText(String text) async {
    // Simulate an API call to an AI service
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return 'This is a summary of the text: "${text.substring(0, 50)}..."';
  }

  // Method to generate a quiz based on a topic
  static Future<List<Map<String, dynamic>>> generateQuiz(String topic) async {
    // Simulate an API call to an AI service
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    // Example quiz data
    return [
      {
        'question': 'What is the capital of France?',
        'options': ['Paris', 'London', 'Berlin'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is 2 + 2?',
        'options': ['3', '4', '5'],
        'correctAnswer': 1,
      },
    ];
  }

  // Method to generate a motivational quote
  static Future<String> generateMotivationalQuote() async {
    // Simulate an API call to an AI service
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return 'Believe you can and you\'re halfway there. - Theodore Roosevelt';
  }

  static Future<String> askQuestionGoogle(String question) async {
    try {
      final prompt = 'You are an AI tutor. Answer this question: $question';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error: Unable to generate response';
    }
  }
}