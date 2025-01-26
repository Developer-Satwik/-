import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'assignment_model.dart';
import 'assignment_service.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class AssignmentUploadScreen extends StatefulWidget {
  final Assignment assignment;
  
  const AssignmentUploadScreen({
    super.key,
    required this.assignment,
  });

  @override
  _AssignmentUploadScreenState createState() => _AssignmentUploadScreenState();
}

class _AssignmentUploadScreenState extends State<AssignmentUploadScreen> {
  PlatformFile? _uploadedFile;

  Future<void> _uploadAssignment() async {
    if (_uploadedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Please upload a file.'),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    try {
      final updatedAssignment = Assignment(
        id: widget.assignment.id,
        title: widget.assignment.title,
        description: widget.assignment.description,
        deadline: widget.assignment.deadline,
        studentId: widget.assignment.studentId,
        filePath: _uploadedFile!.path,
        marks: widget.assignment.marks,
        feedback: widget.assignment.feedback,
      );
      await AssignmentService.uploadAssignment(updatedAssignment);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Assignment uploaded successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Failed to upload assignment. Please try again.'),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _uploadedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.assignment.title,
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
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
                    Text(
                      'Assignment Details',
                      style: AppTheme.headingMedium.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.assignment.description,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Due: ${widget.assignment.deadline.toString().split(' ')[0]}',
                          style: AppTheme.bodyLarge.copyWith(
                            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Assignment',
                      style: AppTheme.headingMedium.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        fontSize: isSmallScreen ? 20 : 24,
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
                          onPressed: _pickFile,
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
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: isSmallScreen ? 24 : 28,
                              ),
                              SizedBox(width: isSmallScreen ? 12 : 16),
                              Text(
                                'Choose File',
                                style: AppTheme.buttonText.copyWith(
                                  fontSize: isSmallScreen ? 16 : 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_uploadedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.white.withOpacity(0.1) : AppTheme.lightSurfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? Colors.white24 : AppTheme.lightPrimaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.white.withOpacity(0.1) : AppTheme.lightPrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.description_rounded,
                                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _uploadedFile!.name,
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(_uploadedFile!.size / 1024).toStringAsFixed(2)} KB',
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
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
                  onPressed: _uploadAssignment,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Submit Assignment',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
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
}