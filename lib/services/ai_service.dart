import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIService {
  static const _apiKey = 'AIzaSyC7EluuQmw1KB-hoVM4s6u3u7-vT7ezc7U';  // Replace with your actual API key
  static final _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
  static final _supabase = Supabase.instance.client;

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

  static Future<String> getAIResponse(String query, {Map<String, dynamic>? studentData}) async {
    try {
      // Prepare context about the student's data
      String contextPrompt = '';
      if (studentData != null) {
        contextPrompt = '''
Context about the student:
- Upcoming Classes: ${studentData['upcoming_classes'] ?? 'No data'}
- Pending Assignments: ${studentData['pending_assignments'] ?? 'No data'}
- Recent Activities: ${studentData['recent_activities'] ?? 'No data'}
- Academic Progress: ${studentData['academic_progress'] ?? 'No data'}

Please provide a helpful response based on this student's context. For schedule-related queries, use the actual class times and assignments.
''';
      }

      final prompt = '''
$contextPrompt
Student Query: $query

Please provide a clear and concise response. If the query is about:
- Schedule: Mention specific dates and times
- Assignments: Include due dates and status
- Academic Progress: Provide specific metrics and suggestions
- General Topics: Give detailed explanations with examples

Keep the tone friendly and encouraging.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'I apologize, but I couldn\'t generate a response at the moment.';
    } catch (e) {
      return 'I apologize, but I encountered an error: $e';
    }
  }

  static Future<Map<String, dynamic>> fetchStudentData(String studentId) async {
    try {
      // Fetch upcoming classes
      final classes = await _supabase
          .from('class_schedules')
          .select()
          .eq('student_id', studentId)
          .gte('class_date', DateTime.now().toIso8601String())
          .order('class_date')
          .limit(5);

      // Fetch pending assignments
      final assignments = await _supabase
          .from('assignments')
          .select()
          .eq('student_id', studentId)
          .eq('status', 'pending')
          .order('due_date')
          .limit(5);

      // Fetch recent activities
      final activities = await _supabase
          .from('student_activities')
          .select()
          .eq('student_id', studentId)
          .order('timestamp', ascending: false)
          .limit(5);

      // Fetch academic progress
      final progress = await _supabase
          .from('academic_progress')
          .select()
          .eq('student_id', studentId)
          .single();

      return {
        'upcoming_classes': classes,
        'pending_assignments': assignments,
        'recent_activities': activities,
        'academic_progress': progress,
      };
    } catch (e) {
      print('Error fetching student data: $e');
      return {};
    }
  }
}