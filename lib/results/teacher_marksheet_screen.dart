import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import 'marksheet_model.dart';
import '../services/marks_evaluation_service.dart';

class TeacherMarksheetScreen extends StatefulWidget {
  const TeacherMarksheetScreen({super.key});

  @override
  _TeacherMarksheetScreenState createState() => _TeacherMarksheetScreenState();
}

class _TeacherMarksheetScreenState extends State<TeacherMarksheetScreen> {
  bool _isEvaluating = false;
  bool _isEditing = false;
  bool _isEditingMarks = false;
  String _aiOverview = '';
  double _studentScore = 0;
  double _totalMarks = 0;
  PlatformFile? _uploadedAnswerSheet;
  PlatformFile? _uploadedQuestionPaper;
  final TextEditingController _markingSchemeController = TextEditingController();
  final TextEditingController _evaluationController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _studentScoreController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();

  Future<void> _evaluateMarksheet() async {
    setState(() {
      _isEvaluating = true;
      _aiOverview = '';
      _studentScore = 0;
      _totalMarks = 0;
    });

    try {
      if (_markingSchemeController.text.isEmpty) {
        setState(() {
          _aiOverview = 'Please provide a marking scheme.';
        });
        return;
      }

      if (_uploadedQuestionPaper == null || _uploadedAnswerSheet == null) {
        setState(() {
          _aiOverview = 'Please upload both the question paper and answer sheet.';
        });
        return;
      }

      final questionPaperContent = await MarksEvaluationService.processFile(_uploadedQuestionPaper!);
      final answerSheetContent = await MarksEvaluationService.processFile(_uploadedAnswerSheet!);

      final prompt = '''
Marking Scheme:
${_markingSchemeController.text}

Question Paper:
$questionPaperContent

Answer Sheet:
$answerSheetContent

Evaluate the answer sheet strictly according to the instructions provided in the marking scheme and the questions in the question paper.
Highlight areas where the student is struggling and provide feedback based on the marking scheme and question paper.
Also calculate and provide:
1. Total marks available in the paper
2. Total marks scored by the student
Format these at the start of your response as: "MARKS: [scored]/[total]"
Then continue with the detailed evaluation.
''';

      final response = await MarksEvaluationService.model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? 'No evaluation available.';
      
      // Extract marks from response
      if (responseText.contains('MARKS:')) {
        final marksMatch = RegExp(r'MARKS:\s*(\d+)/(\d+)').firstMatch(responseText);
        if (marksMatch != null) {
          _studentScore = double.parse(marksMatch.group(1)!);
          _totalMarks = double.parse(marksMatch.group(2)!);
          _scoreController.text = '${_studentScore.toStringAsFixed(1)}/${_totalMarks.toStringAsFixed(1)}';
          _studentScoreController.text = _studentScore.toStringAsFixed(1);
          _totalMarksController.text = _totalMarks.toStringAsFixed(1);
        }
      }

      setState(() {
        _aiOverview = responseText.replaceFirst(RegExp(r'MARKS:.*\n'), '').trim();
        _evaluationController.text = _aiOverview;
      });
    } catch (e) {
      setState(() {
        _aiOverview = 'Failed to evaluate marksheet. Please try again.';
      });
    } finally {
      setState(() {
        _isEvaluating = false;
      });
    }
  }

  Future<void> _publishResults() async {
    try {
      // TODO: Implement backend integration
      // Send evaluation data to backend
      final evaluationData = {
        'score': _studentScore,
        'totalMarks': _totalMarks,
        'feedback': _evaluationController.text,
        // Add other necessary fields
      };
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Results published successfully!'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish results. Please try again.'))
      );
    }
  }

  Future<void> _pickFile(bool isQuestionPaper) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (isQuestionPaper) {
          _uploadedQuestionPaper = result.files.first;
        } else {
          _uploadedAnswerSheet = result.files.first;
        }
      });
    }
  }

  Widget _buildUploadSection(String title, bool isQuestionPaper, PlatformFile? file) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingMedium.copyWith(
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : AppTheme.lightPrimaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.white24 : AppTheme.lightPrimaryColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    file?.name ?? 'No file selected',
                    style: AppTheme.bodyLarge.copyWith(
                      color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                TextButton(
                  onPressed: () => _pickFile(isQuestionPaper),
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white10 : AppTheme.lightPrimaryColor.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 10,
                    ),
                  ),
                  child: Text(
                    file == null ? 'Choose File' : 'Change File',
                    style: AppTheme.buttonText.copyWith(
                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final horizontalPadding = isSmallScreen ? 16.0 : (isTablet ? 24.0 : 32.0);
    final verticalPadding = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 24.0);

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Teacher Marksheet',
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            fontSize: isSmallScreen ? 24 : 28,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_aiOverview.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                          decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'AI Evaluation Results',
                                    style: AppTheme.headingMedium.copyWith(
                                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                      fontSize: isSmallScreen ? 20 : 24,
                                    ),
                                  ),
                                  if (_totalMarks > 0)
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            _isEditingMarks ? Icons.save : Icons.edit_note,
                                            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isEditingMarks = !_isEditingMarks;
                                              if (!_isEditingMarks) {
                                                _studentScore = double.tryParse(_studentScoreController.text) ?? _studentScore;
                                                _totalMarks = double.tryParse(_totalMarksController.text) ?? _totalMarks;
                                                _scoreController.text = '${_studentScore.toStringAsFixed(1)}/${_totalMarks.toStringAsFixed(1)}';
                                              }
                                            });
                                          },
                                          tooltip: _isEditingMarks ? 'Save Marks' : 'Edit Marks',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _isEditing ? Icons.save : Icons.edit,
                                            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isEditing = !_isEditing;
                                              if (!_isEditing) {
                                                _aiOverview = _evaluationController.text;
                                              }
                                            });
                                          },
                                          tooltip: _isEditing ? 'Save Feedback' : 'Edit Feedback',
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              if (_totalMarks > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 8 : 12,
                                    horizontal: isSmallScreen ? 16 : 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.white10 : AppTheme.lightPrimaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.white24 : AppTheme.lightPrimaryColor.withOpacity(0.1),
                                    ),
                                  ),
                                  child: _isEditingMarks
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: TextField(
                                                controller: _studentScoreController,
                                                style: AppTheme.bodyLarge.copyWith(
                                                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                                  fontSize: isSmallScreen ? 16 : 18,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(maxWidth: 60),
                                                ),
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                            Text(
                                              ' / ',
                                              style: AppTheme.bodyLarge.copyWith(
                                                color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                                fontSize: isSmallScreen ? 16 : 18,
                                              ),
                                            ),
                                            Flexible(
                                              child: TextField(
                                                controller: _totalMarksController,
                                                style: AppTheme.bodyLarge.copyWith(
                                                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                                  fontSize: isSmallScreen ? 16 : 18,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(maxWidth: 60),
                                                ),
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Score: ${_studentScore.toStringAsFixed(1)}/${_totalMarks.toStringAsFixed(1)}',
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                            fontSize: isSmallScreen ? 16 : 18,
                                          ),
                                        ),
                                ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              _isEditing
                                  ? TextField(
                                      controller: _evaluationController,
                                      maxLines: null,
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDarkMode ? Colors.white24 : AppTheme.lightPrimaryColor.withOpacity(0.1),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDarkMode ? Colors.white24 : AppTheme.lightPrimaryColor.withOpacity(0.1),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.white10 : AppTheme.lightPrimaryColor.withOpacity(0.05),
                                      ),
                                    )
                                  : Text(
                                      _aiOverview,
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                              if (_totalMarks > 0 && !_isEditing)
                                Padding(
                                  padding: EdgeInsets.only(top: isSmallScreen ? 16 : 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = true;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDarkMode ? Colors.white10 : AppTheme.lightPrimaryColor.withOpacity(0.1),
                                          foregroundColor: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 16 : 24,
                                            vertical: isSmallScreen ? 8 : 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Edit',
                                          style: AppTheme.buttonText.copyWith(
                                            fontSize: isSmallScreen ? 14 : 16,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 12 : 16),
                                      ElevatedButton(
                                        onPressed: _publishResults,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 16 : 24,
                                            vertical: isSmallScreen ? 8 : 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Publish',
                                          style: AppTheme.buttonText.copyWith(
                                            fontSize: isSmallScreen ? 14 : 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      SizedBox(height: verticalPadding),
                      
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                        decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Marking Scheme',
                              style: AppTheme.headingMedium.copyWith(
                                color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                fontSize: isSmallScreen ? 18 : 20,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            TextField(
                              controller: _markingSchemeController,
                              decoration: InputDecoration(
                                hintText: 'Enter detailed marking criteria and instructions...',
                                hintStyle: AppTheme.bodyLarge.copyWith(
                                  color: isDarkMode ? Colors.white38 : AppTheme.lightPrimaryColor.withOpacity(0.4),
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.white24 : AppTheme.lightPrimaryColor.withOpacity(0.1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.white24 : AppTheme.lightPrimaryColor.withOpacity(0.1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDarkMode ? Colors.white10 : AppTheme.lightPrimaryColor.withOpacity(0.05),
                              ),
                              maxLines: 5,
                              style: AppTheme.bodyLarge.copyWith(
                                color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      
                      _buildUploadSection('Question Paper', true, _uploadedQuestionPaper),
                      SizedBox(height: verticalPadding),
                      _buildUploadSection('Answer Sheet', false, _uploadedAnswerSheet),
                      SizedBox(height: verticalPadding),

                      Center(
                        child: Container(
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
                            onPressed: _isEvaluating ? null : _evaluateMarksheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isEvaluating
                                ? SizedBox(
                                    width: isSmallScreen ? 20 : 24,
                                    height: isSmallScreen ? 20 : 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Evaluate with AI',
                                    style: AppTheme.buttonText.copyWith(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}