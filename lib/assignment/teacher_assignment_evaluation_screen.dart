import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'assignment_model.dart';
import 'assignment_evaluation_service.dart';
import 'dart:convert';
import 'assignment_service.dart';
import 'assignment_marks_confirmation_screen.dart';
import '../theme/app_theme.dart';

class TeacherAssignmentEvaluationScreen extends StatefulWidget {
  const TeacherAssignmentEvaluationScreen({super.key});

  @override
  _TeacherAssignmentEvaluationScreenState createState() => _TeacherAssignmentEvaluationScreenState();
}

class _TeacherAssignmentEvaluationScreenState extends State<TeacherAssignmentEvaluationScreen> {
  final _markingSchemeController = TextEditingController();
  final _questionSheetController = TextEditingController();
  final _answerSheetController = TextEditingController();
  bool _isAnalyzing = false;

  Future<void> _analyzeAndEvaluate() async {
    if (_markingSchemeController.text.isEmpty ||
        _questionSheetController.text.isEmpty ||
        _answerSheetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final analysis = await AssignmentService.analyzeAssignment(
        markingScheme: _markingSchemeController.text,
        questionSheet: _questionSheetController.text,
        answerSheet: _answerSheetController.text,
      );

      // Create a temporary assignment for evaluation
      final assignment = Assignment(
        id: DateTime.now().toString(), // Temporary ID
        title: 'Assignment Analysis',
        description: _questionSheetController.text,
        deadline: DateTime.now(),
        studentId: 'temp_student',
        filePath: null,
      );

      // Navigate to confirmation screen with AI analysis
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentMarksConfirmationScreen(
              assignment: assignment,
              aiOverview: '''
Analysis Results:
Total Score: ${analysis['total_score']}

Evaluation:
${analysis['evaluation'].entries.map((e) => 
  "${e.key}:\n- Points: ${e.value['points_awarded']}/${e.value['max_points']}\n- Feedback: ${e.value['feedback']}"
).join('\n\n')}

Areas for Improvement:
${analysis['areas_of_improvement'].map((area) => "- $area").join('\n')}

Overall Feedback:
${analysis['overall_feedback']}
''',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _markingSchemeController.dispose();
    _questionSheetController.dispose();
    _answerSheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Evaluate Assignment',
          style: AppTheme.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.accentColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputSection(
                'Marking Scheme',
                'Enter the marking scheme...',
                _markingSchemeController,
                8,
              ),
              const SizedBox(height: 24),
              _buildInputSection(
                'Question Sheet',
                'Enter the questions...',
                _questionSheetController,
                8,
              ),
              const SizedBox(height: 24),
              _buildInputSection(
                'Answer Sheet',
                'Enter or paste the student\'s answers...',
                _answerSheetController,
                12,
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _analyzeAndEvaluate,
                  style: AppTheme.primaryButtonStyle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: _isAnalyzing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Analyze & Evaluate',
                            style: AppTheme.buttonText,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(
    String label,
    String hint,
    TextEditingController controller,
    int maxLines,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTheme.bodyLarge.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentColor.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentColor.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.surfaceColor.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }
}