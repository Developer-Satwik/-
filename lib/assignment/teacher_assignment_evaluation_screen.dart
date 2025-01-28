import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import 'assignment_model.dart';
import 'assignment_evaluation_service.dart';
import 'dart:convert';
import 'dart:io';
import 'assignment_service.dart';
import 'assignment_marks_confirmation_screen.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:html' as html;  // Add this for web support

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
  PlatformFile? _questionSheetFile;
  PlatformFile? _answerSheetFile;
  bool _isProcessing = false;

  Future<void> _pickFile(bool isQuestionSheet) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          if (isQuestionSheet) {
            _questionSheetFile = result.files.first;
            _questionSheetController.text = "Processing..."; // Show processing status
          } else {
            _answerSheetFile = result.files.first;
            _answerSheetController.text = "Processing..."; // Show processing status
          }
          _isProcessing = true;
        });

        // Process OCR in a compute isolate to prevent UI freezing
        final text = await compute(_processOCRInIsolate, result.files.first);
        
        if (mounted) {
          setState(() {
            if (isQuestionSheet) {
              _questionSheetController.text = text ?? "Error processing file";
            } else {
              _answerSheetController.text = text ?? "Error processing file";
            }
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorSnackBar('Error picking file: $e');
      }
    }
  }

  // Isolate function for OCR processing
  static Future<String?> _processOCRInIsolate(PlatformFile file) async {
    try {
      if (kIsWeb) {
        // Web implementation
        final text = await _processWebFile(file);
        return text;
      } else {
        // Mobile implementation
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/${file.name}';
        
        File(file.path!).copySync(tempPath);

        String recognizedText = await FlutterTesseractOcr.extractText(
          tempPath,
          language: 'eng',
          args: {
            "preserve_interword_spaces": "1",
            "tessedit_pageseg_mode": "1",
          },
        );

        await File(tempPath).delete();
        return recognizedText;
      }
    } catch (e) {
      print('OCR Error: $e');
      return null;
    }
  }

  static Future<String> _processWebFile(PlatformFile file) async {
    // For web, we'll just return the file name for now
    // In a production app, you'd want to implement proper web OCR
    return 'File content: ${file.name}';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _analyzeAndEvaluate() async {
    if (_markingSchemeController.text.isEmpty ||
        _questionSheetController.text.isEmpty ||
        _answerSheetController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
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

      final assignment = Assignment(
        id: DateTime.now().toString(),
        title: 'Assignment Analysis',
        description: _questionSheetController.text,
        deadline: DateTime.now(),
        studentId: 'temp_student',
        filePath: null,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentMarksConfirmationScreen(
              assignment: assignment,
              aiOverview: json.encode(analysis),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Widget _buildInputSection(
    String label,
    String hint,
    TextEditingController controller,
    int maxLines,
    bool isDarkMode,
    bool isSmallScreen, {
    bool isQuestionSheet = false,
    bool isAnswerSheet = false,
  }) {
    final hasFile = isQuestionSheet ? _questionSheetFile != null : 
                    isAnswerSheet ? _answerSheetFile != null : false;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.headingMedium.copyWith(
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          const SizedBox(height: 16),
          if (isQuestionSheet || isAnswerSheet) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? Colors.white24 : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasFile ? Icons.check_circle : Icons.upload_file,
                          color: hasFile ? Colors.green : (isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasFile ? 
                              (isQuestionSheet ? _questionSheetFile!.name : _answerSheetFile!.name) :
                              'No file selected',
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _pickFile(isQuestionSheet),
                  icon: Icon(Icons.file_upload, size: isSmallScreen ? 18 : 20),
                  label: Text(
                    hasFile ? 'Change File' : 'Upload File',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            enabled: true,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: AppTheme.bodyLarge.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: isDarkMode ? Colors.white10 : Colors.grey[100],
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
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
        title: Text(
          'Evaluate Assignment',
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            fontSize: isSmallScreen ? 20 : 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () => Navigator.pop(context),
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
                      // Question Sheet Section
                      Text(
                        'Question Sheet',
                        style: AppTheme.headingMedium.copyWith(
                          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? Colors.white24 : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _questionSheetFile != null ? Icons.check_circle : Icons.upload_file,
                                    color: _questionSheetFile != null ? Colors.green : (isDarkMode ? Colors.white70 : Colors.black54),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _questionSheetFile != null ? _questionSheetFile!.name : 'No file selected',
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _pickFile(true),
                            icon: Icon(Icons.file_upload, size: isSmallScreen ? 18 : 20),
                            label: Text(
                              _questionSheetFile != null ? 'Change File' : 'Upload File',
                              style: AppTheme.buttonText.copyWith(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 16 : 20,
                                vertical: isSmallScreen ? 12 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: verticalPadding),

                      // Marking Scheme Section
                      _buildInputSection(
                        'Marking Scheme',
                        'Enter the marking scheme...',
                        _markingSchemeController,
                        8,
                        isDarkMode,
                        isSmallScreen,
                      ),
                      SizedBox(height: verticalPadding),

                      // Answer Sheet Section
                      Text(
                        'Answer Sheet',
                        style: AppTheme.headingMedium.copyWith(
                          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? Colors.white24 : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _answerSheetFile != null ? Icons.check_circle : Icons.upload_file,
                                    color: _answerSheetFile != null ? Colors.green : (isDarkMode ? Colors.white70 : Colors.black54),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _answerSheetFile != null ? _answerSheetFile!.name : 'No file selected',
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _pickFile(false),
                            icon: Icon(Icons.file_upload, size: isSmallScreen ? 18 : 20),
                            label: Text(
                              _answerSheetFile != null ? 'Change File' : 'Upload File',
                              style: AppTheme.buttonText.copyWith(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 16 : 20,
                                vertical: isSmallScreen ? 12 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: verticalPadding * 1.5),

                      // Analyze Button
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 48 : 56,
                          child: ElevatedButton(
                            onPressed: _isAnalyzing ? null : _analyzeAndEvaluate,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppTheme.primaryColor,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 24 : 32,
                                vertical: isSmallScreen ? 12 : 16,
                              ),
                            ),
                            child: _isAnalyzing
                                ? const SizedBox(
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
                                      Icon(
                                        Icons.analytics_outlined,
                                        color: Colors.white,
                                        size: isSmallScreen ? 20 : 24,
                                      ),
                                      SizedBox(width: isSmallScreen ? 8 : 12),
                                      Text(
                                        'Analyze & Evaluate',
                                        style: TextStyle(
                                          color: Colors.white,
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