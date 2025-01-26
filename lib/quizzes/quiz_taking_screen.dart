import 'package:flutter/material.dart';
import './quiz_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'package:provider/provider.dart';

class QuizTakingScreen extends StatefulWidget {
  final String quizTitle;
  final bool isPersonalized;

  const QuizTakingScreen({Key? key, required this.quizTitle, this.isPersonalized = false}) : super(key: key);

  @override
  _QuizTakingScreenState createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedAnswers = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  void _loadQuiz() async {
    try {
      List<Map<String, dynamic>> quiz;
      if (widget.isPersonalized) {
        quiz = await QuizService.generatePersonalizedQuiz();
      } else {
        quiz = await QuizService.generateQuiz('General', 5, 'medium');
      }

      setState(() {
        questions = quiz;
        selectedAnswers = List.filled(quiz.length, null);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load quiz. Please try again later.'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppTheme.backgroundColor : Colors.white,
        appBar: _buildLuxuryAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                  strokeWidth: 4,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Loading your exclusive quiz...',
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError || questions.isEmpty) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppTheme.backgroundColor : Colors.white,
        appBar: _buildLuxuryAppBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode ? AppTheme.backgroundGradient : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[100]!, Colors.white],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No quiz questions available.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[800],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : Colors.white,
      appBar: _buildLuxuryAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(),
              SizedBox(height: 32),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isDarkMode ? AppTheme.primaryGradient : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.grey[50]!],
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questions[currentQuestionIndex]['question'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 24),
                      ..._buildOptions(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildLuxuryAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.amber[700],
      title: Text(
        widget.quizTitle,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'of ${questions.length}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOptions() {
    return List.generate(
      questions[currentQuestionIndex]['options'].length,
      (i) => Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Material(
          color: selectedAnswers[currentQuestionIndex] == i
              ? Colors.amber[700]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              setState(() {
                selectedAnswers[currentQuestionIndex] = i;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedAnswers[currentQuestionIndex] == i
                          ? Colors.white
                          : Colors.white,
                      border: Border.all(
                        color: selectedAnswers[currentQuestionIndex] == i
                            ? Colors.white
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: selectedAnswers[currentQuestionIndex] == i
                        ? Icon(Icons.check, size: 20, color: Colors.amber[700])
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      questions[currentQuestionIndex]['options'][i],
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedAnswers[currentQuestionIndex] == i
                            ? Colors.white
                            : Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentQuestionIndex > 0)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                currentQuestionIndex--;
              });
            },
            icon: Icon(Icons.arrow_back),
            label: Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.grey[800],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () {
            if (currentQuestionIndex < questions.length - 1) {
              setState(() {
                currentQuestionIndex++;
              });
            } else {
              _showResultsDialog();
            }
          },
          icon: Icon(currentQuestionIndex < questions.length - 1
              ? Icons.arrow_forward
              : Icons.check_circle),
          label:
              Text(currentQuestionIndex < questions.length - 1 ? 'Next' : 'Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[700],
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  void _showResultsDialog() {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              correctAnswers > questions.length / 2
                  ? Icons.emoji_events
                  : Icons.stars,
              size: 48,
              color: Colors.amber[700],
            ),
            SizedBox(height: 16),
            Text(
              'Quiz Results',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You got $correctAnswers out of ${questions.length} questions correct!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${(correctAnswers / questions.length * 100).round()}%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.amber[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'FINISH',
              style: TextStyle(
                color: Colors.amber[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}