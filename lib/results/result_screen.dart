import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import 'marksheet_model.dart';
import '../services/marks_evaluation_service.dart';

class ResultsScreen extends StatefulWidget {
  final List<Marksheet> marksheet;

  ResultsScreen({required this.marksheet});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _aiFeedback = '';
  bool _isAnalyzing = false;
  bool _isEditing = false;
  late List<TextEditingController> _marksControllers;
  late List<TextEditingController> _feedbackControllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _marksControllers = widget.marksheet.map((m) => 
      TextEditingController(text: m.marksObtained.toString())
    ).toList();
    
    _feedbackControllers = widget.marksheet.map((m) =>
      TextEditingController(text: m.feedback)
    ).toList();
  }

  @override
  void dispose() {
    for (var controller in _marksControllers) {
      controller.dispose();
    }
    for (var controller in _feedbackControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _analyzeMarksheet() async {
    setState(() {
      _isAnalyzing = true;
      _aiFeedback = '';
    });

    try {
      final feedback = await MarksEvaluationService.analyzeMarksheet(widget.marksheet);
      setState(() {
        _aiFeedback = feedback;
      });
    } catch (e) {
      setState(() {
        _aiFeedback = 'Failed to analyze marksheet. Please try again.';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _saveChanges() {
    for (int i = 0; i < widget.marksheet.length; i++) {
      widget.marksheet[i].marksObtained = double.parse(_marksControllers[i].text);
      widget.marksheet[i].feedback = _feedbackControllers[i].text;
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEditing() {
    _initializeControllers();
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Results',
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Performance Overview',
                          style: AppTheme.headingLarge.copyWith(
                            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.analytics_rounded,
                            color: Colors.white,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...widget.marksheet.map((mark) => _buildMarksheetItem(mark, isDarkMode, isSmallScreen)).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : _analyzeMarksheet,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 24 : 32,
                        vertical: isSmallScreen ? 16 : 20,
                      ),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isAnalyzing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.psychology_rounded,
                                size: isSmallScreen ? 24 : 28,
                              ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Text(
                          'Analyze Performance',
                          style: AppTheme.buttonText.copyWith(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_aiFeedback.isNotEmpty) ...[
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.psychology_rounded,
                                color: Colors.white,
                                size: isSmallScreen ? 24 : 28,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 16 : 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Insights',
                                    style: AppTheme.headingMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Personalized performance analysis',
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: Colors.white70,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                        child: Text(
                          _aiFeedback,
                          style: AppTheme.bodyLarge.copyWith(
                            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                            height: 1.6,
                            fontSize: isSmallScreen ? 15 : 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarksheetItem(Marksheet mark, bool isDarkMode, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    mark.subject,
                    style: AppTheme.bodyLarge.copyWith(
                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${mark.marksObtained}/${mark.totalMarks}',
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
            if (mark.feedback.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                mark.feedback,
                style: AppTheme.bodyLarge.copyWith(
                  color: isDarkMode ? Colors.white60 : AppTheme.lightPrimaryColor.withOpacity(0.6),
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}