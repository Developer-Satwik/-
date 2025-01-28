import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import 'assignment_model.dart';
import 'assignment_service.dart';
import 'dart:convert';

class AssignmentMarksConfirmationScreen extends StatefulWidget {
  final Assignment assignment;
  final String aiOverview;

  const AssignmentMarksConfirmationScreen({
    super.key, 
    required this.assignment, 
    required this.aiOverview,
  });

  @override
  _AssignmentMarksConfirmationScreenState createState() => _AssignmentMarksConfirmationScreenState();
}

class _AssignmentMarksConfirmationScreenState extends State<AssignmentMarksConfirmationScreen> {
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isEditing = false;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    try {
      final analysis = json.decode(widget.aiOverview) as Map<String, dynamic>;
      final StringBuffer feedback = StringBuffer();
      
      // Add total score
      feedback.writeln('Total Score: ${analysis['total_score']}/100\n');
      
      // Add question breakdown
      final questionBreakdown = analysis['evaluation']['question_breakdown'] as List;
      feedback.writeln('Question-by-Question Breakdown:\n');
      
      for (int i = 0; i < questionBreakdown.length; i++) {
        final question = questionBreakdown[i] as Map<String, dynamic>;
        feedback.writeln('Question ${i + 1}:');
        feedback.writeln('Marks: ${question['marks_awarded']}/${question['max_marks']}');
        feedback.writeln('Feedback: ${question['feedback']}\n');
      }
      
      // Add areas for improvement
      feedback.writeln('\nAreas for Improvement:');
      final improvements = analysis['areas_of_improvement'] as List;
      for (var area in improvements) {
        feedback.writeln('• $area');
      }
      
      // Add overall feedback
      feedback.writeln('\nOverall Feedback:');
      feedback.writeln(analysis['overall_feedback']);
      
      setState(() {
        _feedbackController.text = feedback.toString();
        _marksController.text = analysis['total_score'].toString();
      });
    } catch (e) {
      print('Error parsing evaluation: $e');
      _feedbackController.text = 'Error displaying evaluation';
      _marksController.text = '0';
    }
  }

  @override
  void dispose() {
    _marksController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _publishMarks() async {
    setState(() {
      _isPublishing = true;
    });

    try {
      final updatedAssignment = Assignment(
        id: widget.assignment.id,
        title: widget.assignment.title,
        description: widget.assignment.description,
        deadline: widget.assignment.deadline,
        studentId: widget.assignment.studentId,
        filePath: widget.assignment.filePath,
        marks: double.parse(_marksController.text),
        feedback: _feedbackController.text,
      );

      await AssignmentService.uploadAssignment(updatedAssignment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marks published successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error publishing marks: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
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
          'Confirm Evaluation',
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isEditing ? () {
              setState(() {
                _isEditing = false;
              });
            } : () {
              setState(() {
                _isEditing = true;
              });
            },
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            ),
            label: Text(
              _isEditing ? 'Done' : 'Edit',
              style: AppTheme.bodyLarge.copyWith(
                color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Marks',
                      style: AppTheme.headingMedium.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _marksController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        fontSize: isSmallScreen ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: _isEditing ? OutlineInputBorder() : InputBorder.none,
                        filled: _isEditing,
                        fillColor: isDarkMode ? Colors.white10 : Colors.grey[100],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(24),
                decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evaluation Details',
                      style: AppTheme.headingMedium.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _feedbackController,
                      enabled: _isEditing,
                      maxLines: null,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        border: _isEditing ? OutlineInputBorder() : InputBorder.none,
                        filled: _isEditing,
                        fillColor: isDarkMode ? Colors.white10 : Colors.grey[100],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: isSmallScreen ? 48 : 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _publishMarks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isPublishing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.publish, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Publish Marks',
                              style: AppTheme.buttonText.copyWith(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}