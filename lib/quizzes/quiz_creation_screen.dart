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
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, dynamic>> questions = [];
  String _aiSuggestion = '';
  bool _isLoading = false;

  void _addQuestion() {
    setState(() {
      questions.add({
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswer': 0,
      });
    });
    _getAISuggestion();
  }

  void _getAISuggestion() async {
    if (questions.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    String prompt = 'Suggest improvements or additional questions for the following quiz:\n';
    for (var question in questions) {
      prompt += 'Question: ${question['question']}\n';
      prompt += 'Options: ${question['options'].join(', ')}\n';
      prompt += 'Correct Answer: ${question['correctAnswer']}\n\n';
    }

    try {
      String suggestion = await QuizService.getAISuggestion(prompt);
      setState(() {
        _aiSuggestion = suggestion;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to get AI suggestion: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade900.withOpacity(0.95) : Colors.green.shade900.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  void _saveQuiz() async {
    if (_titleController.text.trim().isEmpty || questions.isEmpty) {
      _showSnackBar('Please add a title and at least one question.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final quizData = {
      'title': _titleController.text,
      'questions': questions,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await QuizService.saveQuiz(quizData);
      if (mounted) {
        _showSnackBar('Quiz saved successfully!');
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1024;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDesktop, isTablet),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : (isTablet ? 800 : double.infinity),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : (isTablet ? 32 : 24),
                  vertical: isDesktop ? 40 : (isTablet ? 32 : 24),
                ),
                child: Column(
                  children: [
                    _buildTitleField(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 40 : (isTablet ? 32 : 28)),
                    _buildQuestionsList(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 40 : (isTablet ? 32 : 28)),
                    _buildActionButtons(isDesktop, isTablet),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _isLoading ? 0.0 : 1.0,
        duration: Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          onPressed: _addQuestion,
          icon: Icon(Icons.add_circle_outline),
          label: Text('Add Question'),
          backgroundColor: isDarkMode ? AppTheme.accentColor : Colors.green.shade600,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop, bool isTablet) {
    return AppBar(
      title: Text(
        'Create Quiz',
        style: GoogleFonts.poppins(
          fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.black.withOpacity(0.2),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.save_outlined, color: Colors.white),
          onPressed: _saveQuiz,
          tooltip: 'Save Quiz',
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTitleField(bool isDesktop, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _titleController,
        style: GoogleFonts.inter(
          fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        decoration: InputDecoration(
          labelText: 'Quiz Title',
          labelStyle: GoogleFonts.inter(
            color: Colors.white70,
            letterSpacing: 0.3,
            fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(28),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_outlined,
              color: Colors.white70,
              size: isDesktop ? 24 : (isTablet ? 22 : 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList(bool isDesktop, bool isTablet) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _isLoading
          ? Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Processing...',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                for (int i = 0; i < questions.length; i++) 
                  _buildQuestionCard(i, isDesktop, isTablet),
                if (_aiSuggestion.isNotEmpty)
                  _buildAISuggestionCard(isDesktop, isTablet),
              ],
            ),
    );
  }

  Widget _buildActionButtons(bool isDesktop, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: Icon(Icons.add_circle_outline),
              label: Text(
                'Add Question',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 24 : (isTablet ? 20 : 18),
                ),
                backgroundColor: Colors.white.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveQuiz,
              icon: Icon(Icons.save_outlined),
              label: Text(
                'Save Quiz',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 24 : (isTablet ? 20 : 18),
                ),
                backgroundColor: Colors.green.shade600,
                elevation: 4,
                shadowColor: Colors.green.shade900.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, bool isDesktop, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionHeader(index, isDesktop, isTablet),
            SizedBox(height: 24),
            _buildQuestionTextField(index, isDesktop),
            SizedBox(height: 24),
            ..._buildOptionFields(index, isDesktop),
            SizedBox(height: 8),
            _buildCorrectAnswerDropdown(index, isDesktop),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                onPressed: () {
                  setState(() {
                    questions.removeAt(index);
                  });
                  _getAISuggestion();
                },
                tooltip: 'Delete Question',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(int index, bool isDesktop, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${index + 1}',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 16),
        Text(
          'Question ${index + 1}',
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTextField(int index, bool isDesktop) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter your question',
        hintStyle: GoogleFonts.inter(
          color: Colors.white38,
          fontSize: isDesktop ? 16 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: EdgeInsets.all(20),
      ),
      style: GoogleFonts.inter(
        fontSize: isDesktop ? 16 : 14,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
      onChanged: (value) {
        setState(() {
          questions[index]['question'] = value;
        });
        _getAISuggestion();
      },
      maxLines: null,
    );
  }

  List<Widget> _buildOptionFields(int index, bool isDesktop) {
    return List.generate(4, (i) => [
      TextField(
        decoration: InputDecoration(
          hintText: 'Option ${String.fromCharCode(65 + i)}',
          hintStyle: GoogleFonts.inter(
            color: Colors.white38,
            fontSize: isDesktop ? 16 : 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              String.fromCharCode(65 + i),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          contentPadding: EdgeInsets.all(20),
        ),
        style: GoogleFonts.inter(
          fontSize: isDesktop ? 16 : 14,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        onChanged: (value) {
          setState(() {
            questions[index]['options'][i] = value;
          });
          _getAISuggestion();
        },
      ),
      SizedBox(height: 16),
    ]).expand((x) => x).toList();
  }

  Widget _buildCorrectAnswerDropdown(int index, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<int>(
        value: questions[index]['correctAnswer'],
        isExpanded: true,
        dropdownColor: Color(0xFF1E293B),
        style: GoogleFonts.inter(
          fontSize: isDesktop ? 16 : 14,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        icon: Icon(
          Icons.arrow_drop_down_circle_outlined,
          color: Colors.white70,
        ),
        underline: SizedBox(),
        items: List.generate(
          4,
          (i) => DropdownMenuItem(
            value: i,
            child: Text(
              'Correct Answer: Option ${String.fromCharCode(65 + i)}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        onChanged: (value) {
          setState(() {
            questions[index]['correctAnswer'] = value!;
          });
          _getAISuggestion();
        },
      ),
    );
  }

  Widget _buildAISuggestionCard(bool isDesktop, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: isDesktop ? 24 : (isTablet ? 22 : 20),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'AI Suggestion',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              _aiSuggestion,
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}