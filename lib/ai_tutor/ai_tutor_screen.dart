import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});

  @override
  _AITutorScreenState createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chatHistory = [];
  bool _isLoading = false;
  Map<String, dynamic> _studentData = {};

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    _addSystemMessage('''
Hello! I'm your AI tutor. I can help you with:
- Checking your class schedule
- Tracking assignments and due dates
- Answering academic questions
- Providing study tips and guidance

Feel free to ask me anything!
''');
  }

  Future<void> _loadStudentData() async {
    final studentId = Supabase.instance.client.auth.currentUser?.id;
    if (studentId != null) {
      final data = await AIService.fetchStudentData(studentId);
      setState(() {
        _studentData = data;
      });
    }
  }

  void _addSystemMessage(String message) {
    setState(() {
      _chatHistory.add({
        'role': 'system',
        'message': message,
      });
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatHistory.add({
        'role': 'user',
        'message': message,
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await AIService.getAIResponse(message, studentData: _studentData);
      
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'role': 'assistant',
            'message': response,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'role': 'assistant',
            'message': 'I apologize, but I encountered an error. Please try again.',
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Tutor',
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
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _chatHistory.length) {
                  return _buildTypingIndicator();
                }

                final message = _chatHistory[index];
                final isUser = message['role'] == 'user';
                final isSystem = message['role'] == 'system';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser) _buildAvatar(isSystem),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppTheme.accentColor
                                : (isDarkMode ? AppTheme.surfaceColor : AppTheme.lightSurfaceColor),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            message['message'],
                            style: AppTheme.bodyLarge.copyWith(
                              color: isUser ? Colors.white : (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor),
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 8),
                      if (isUser) _buildAvatar(false),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.surfaceColor : AppTheme.lightSurfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: AppTheme.bodyLarge.copyWith(
                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 24,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: Icon(
                    Icons.send_rounded,
                    color: _isLoading
                        ? (isDarkMode ? Colors.white38 : AppTheme.lightPrimaryColor.withOpacity(0.38))
                        : AppTheme.accentColor,
                  ),
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isSystem) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSystem ? AppTheme.accentColor : AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSystem ? Icons.school_rounded : Icons.person_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? AppTheme.surfaceColor
                  : AppTheme.lightSurfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const LoadingIndicator(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}