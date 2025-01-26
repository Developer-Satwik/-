import 'package:flutter/material.dart';
import './ai_tutor_service.dart';
import '../dashboard/student_dashboard.dart';

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});

  @override
  _AITutorScreenState createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;
  bool _isDarkMode = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _askQuestion() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a question.'),
          backgroundColor: _isDarkMode ? Color(0xFF1E1E1E) : Color(0xFF2C3E50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      String question = _controller.text;
      String response = await AIService.askQuestion(question);

      setState(() {
        _response = response;
      });
    } catch (e) {
      setState(() {
        _response = 'Failed to get a response from the AI tutor.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.psychology,
                color: _isDarkMode ? Color(0xFFE5B80B) : Color(0xFF1E3799),
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                'AI Tutor',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Color(0xFFE5B80B) : Color(0xFF1E3799),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          backgroundColor: _isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 4,
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: _isDarkMode ? Color(0xFFE5B80B) : Color(0xFF1E3799),
                size: 28,
              ),
              onPressed: _toggleDarkMode,
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: _isDarkMode ? Color(0xFFE5B80B) : Color(0xFF1E3799),
                size: 28,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDashboard(name: 'John Doe'),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDarkMode
                  ? [Color(0xFF1E1E1E), Color(0xFF2C3E50)]
                  : [Color(0xFFF8F9FD), Color(0xFFE8F0FE)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _isDarkMode 
                              ? Colors.black.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 30,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'What would you like to learn today?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: _isDarkMode 
                            ? Color(0xFF2C3E50).withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        hintStyle: TextStyle(
                          color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.lightbulb_outline,
                          color: _isDarkMode ? Color(0xFFE5B80B) : Color(0xFF1E3799),
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: _isDarkMode
                            ? [Color(0xFFE5B80B), Color(0xFFDAA520)]
                            : [Color(0xFF1E3799), Color(0xFF4A69BD)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isDarkMode
                              ? Color(0xFFE5B80B).withOpacity(0.3)
                              : Color(0xFF1E3799).withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _askQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Ask Now',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Color(0xFF2C3E50).withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _isDarkMode
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.2),
                            blurRadius: 30,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          _response.isEmpty
                              ? "I'm here to help you learn. Ask me anything!"
                              : _response,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: _isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}