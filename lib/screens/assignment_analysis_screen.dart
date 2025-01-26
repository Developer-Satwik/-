import 'package:flutter/material.dart';
import '../services/assignment_analysis_service.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignmentAnalysisScreen extends StatefulWidget {
  const AssignmentAnalysisScreen({super.key});

  @override
  State<AssignmentAnalysisScreen> createState() => _AssignmentAnalysisScreenState();
}

class _AssignmentAnalysisScreenState extends State<AssignmentAnalysisScreen> {
  final _markingSchemeController = TextEditingController();
  final _questionSheetController = TextEditingController();
  final _answerSheetController = TextEditingController();
  
  AssignmentAnalysis? _analysis;
  bool _isLoading = false;
  String? _error;

  Future<void> _analyzeAssignment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analysis = await AssignmentAnalysisService.analyzeAssignment(
        markingScheme: _markingSchemeController.text,
        questionSheet: _questionSheetController.text,
        answerSheet: _answerSheetController.text,
      );

      setState(() {
        _analysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: Text(
          'Assignment Analysis',
          style: AppTheme.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              'Marking Scheme',
              'Enter the marking scheme...',
              _markingSchemeController,
              8,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              'Question Sheet',
              'Enter the questions...',
              _questionSheetController,
              8,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              'Answer Sheet',
              'Enter the student\'s answers...',
              _answerSheetController,
              12,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: AppTheme.primaryButtonStyle,
                onPressed: _isLoading ? null : _analyzeAssignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Analyze',
                          style: AppTheme.buttonText.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.inter(color: Colors.red),
                ),
              ),
            ],
            if (_analysis != null) ...[
              const SizedBox(height: 32),
              _buildAnalysisResults(_analysis!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
    int maxLines,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: AppTheme.inputDecoration,
          style: AppTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildAnalysisResults(AssignmentAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analysis Results',
                style: AppTheme.headingMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Score: ${analysis.totalScore}',
                  style: AppTheme.buttonText.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Evaluation',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...analysis.evaluation.entries.map((entry) {
            final question = entry.key;
            final details = entry.value as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Points: ${details['points_awarded']}/${details['max_points']}',
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details['feedback'] as String,
                    style: AppTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          Text(
            'Areas for Improvement',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...analysis.areasOfImprovement.map((area) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_right,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      area,
                      style: AppTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          Text(
            'Overall Feedback',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            analysis.overallFeedback,
            style: AppTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
} 