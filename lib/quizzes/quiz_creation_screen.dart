import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './quiz_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'package:provider/provider.dart';

class QuizCreationScreen extends StatefulWidget {
  const QuizCreationScreen({super.key});

  @override
  _QuizCreationScreenState createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends State<QuizCreationScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> questions = [];
  bool _isLoading = false;
  bool _isGenerating = false;

  Future<void> _generateQuestion() async {
    if (_topicController.text.isEmpty) {
      _showSnackBar('Please enter a topic for the quiz', isError: true);
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final generatedQuestion = await QuizService.generateQuestion(
        _topicController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );
      
      // Check for duplicates
      if (!_isDuplicateQuestion(generatedQuestion)) {
        setState(() {
          questions.add(generatedQuestion);
        });
        _showSnackBar('Question generated successfully!');
      } else {
        _showSnackBar('Similar question already exists. Generating another...', isError: true);
        await _generateQuestion(); // Try again
      }
    } catch (e) {
      _showSnackBar('Failed to generate question: $e', isError: true);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  bool _isDuplicateQuestion(Map<String, dynamic> newQuestion) {
    final newQuestionText = newQuestion['question'].toString().toLowerCase();
    return questions.any((q) {
      final existingQuestionText = q['question'].toString().toLowerCase();
      // Check for high similarity (80% or more matching words)
      final newWords = newQuestionText.split(' ').toSet();
      final existingWords = existingQuestionText.split(' ').toSet();
      final commonWords = newWords.intersection(existingWords).length;
      final totalWords = newWords.length;
      return commonWords / totalWords > 0.8;
    });
  }

  Future<void> _editQuestion(int index) async {
    final question = questions[index];
    final TextEditingController questionController = TextEditingController(text: question['question']);
    final List<TextEditingController> optionControllers = question['options']
        .map<TextEditingController>((option) => TextEditingController(text: option))
        .toList();
    int correctAnswer = question['correctAnswer'];

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Question', style: AppTheme.headingMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 16),
                ...List.generate(4, (i) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: correctAnswer,
                            onChanged: (value) => correctAnswer = value!,
                          ),
                          Expanded(
                            child: TextField(
                              controller: optionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Option ${String.fromCharCode(65 + i)}',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'question': questionController.text,
                'options': optionControllers.map((c) => c.text).toList(),
                'correctAnswer': correctAnswer,
              }),
              child: Text('Save', style: AppTheme.buttonText),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        questions[index] = result;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.bodyLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red.shade900 : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  void _saveQuiz() async {
    if (questions.isEmpty) {
      _showSnackBar('Please generate at least one question', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await QuizService.saveQuiz({
        'title': 'New Quiz',
        'questions': questions,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        _showSnackBar('Quiz saved successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save quiz: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Quiz',
          style: AppTheme.headingLarge.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading) IconButton(
            icon: Icon(
              Icons.save_outlined,
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            ),
            onPressed: _saveQuiz,
          ),
        ],
      ),
      body: Container(
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : constraints.maxWidth * 0.1,
                  vertical: isSmallScreen ? 16 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic Field for AI Generation
                    TextField(
                      controller: _topicController,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Quiz Topic (for AI generation)',
                        labelStyle: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.topic,
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),

                    // Description Field (Optional)
                    TextField(
                      controller: _descriptionController,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Add specific details about the questions you want to generate',
                        labelStyle: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.03),

                    // Generated Questions List
                    if (questions.isNotEmpty) ...[
                      Text(
                        'Questions',
                        style: AppTheme.headingMedium.copyWith(
                          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      
                      ...questions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: isDarkMode ? AppTheme.surfaceColor : AppTheme.lightSurfaceColor,
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Q${index + 1}',
                                        style: AppTheme.bodyLarge.copyWith(
                                          color: AppTheme.accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        question['question'],
                                        style: AppTheme.bodyLarge.copyWith(
                                          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: AppTheme.accentColor,
                                      ),
                                      onPressed: () => _editQuestion(index),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.shade400,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          questions.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: constraints.maxHeight * 0.015),
                                ...List.generate(4, (optionIndex) {
                                  final isCorrect = question['correctAnswer'] == optionIndex;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? AppTheme.successColor.withOpacity(0.2)
                                          : (isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isCorrect
                                            ? AppTheme.successColor
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          String.fromCharCode(65 + optionIndex),
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            question['options'][optionIndex],
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                            ),
                                          ),
                                        ),
                                        if (isCorrect) Icon(
                                          Icons.check_circle,
                                          color: AppTheme.successColor,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                    
                    // Add extra space at bottom to prevent FAB overlap
                    SizedBox(height: isSmallScreen ? 80 : 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : _generateQuestion,
        backgroundColor: AppTheme.accentColor,
        icon: _isGenerating
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add),
        label: Text(
          _isGenerating ? 'Generating...' : 'Generate Question',
          style: AppTheme.buttonText,
        ),
      ),
    );
  }
}