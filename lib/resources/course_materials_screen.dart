import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class CourseMaterialsScreen extends StatefulWidget {
  const CourseMaterialsScreen({super.key});

  @override
  _CourseMaterialsScreenState createState() => _CourseMaterialsScreenState();
}

class _CourseMaterialsScreenState extends State<CourseMaterialsScreen> {
  List<Map<String, dynamic>> _courseMaterials = [];

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'mp4', 'mov'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        String fileName = file.name;
        String fileType = file.extension ?? 'Unknown';

        setState(() {
          _courseMaterials.add({
            'name': fileName,
            'type': fileType,
            'uploadedAt': DateTime.now(),
            'subject': 'Mathematics', // Add subject field - this should come from a dropdown or form
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'File uploaded successfully',
                  style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            elevation: 4,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'No file selected',
                  style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            elevation: 4,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Failed to upload file: $e',
                style: AppTheme.bodyLarge.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          elevation: 4,
        ),
      );
    }
  }

  void _deleteFile(int index) {
    setState(() {
      _courseMaterials.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'File deleted successfully',
              style: AppTheme.bodyLarge.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Course Materials',
          style: AppTheme.headingLarge.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: _uploadFile,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              label: Text(
                'Upload',
                style: AppTheme.buttonText,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uploaded Materials',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: _courseMaterials.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_rounded,
                                size: 80,
                                color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.3),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No materials uploaded yet',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _courseMaterials.length,
                          itemBuilder: (context, index) {
                            final material = _courseMaterials[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.12),
                                    (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.06),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.15),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(20),
                                leading: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentColor.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    material['type'] == 'pdf'
                                        ? Icons.picture_as_pdf_rounded
                                        : material['type'] == 'mp4' ||
                                                material['type'] == 'mov'
                                            ? Icons.video_library_rounded
                                            : Icons.insert_drive_file_rounded,
                                    color: AppTheme.accentColor,
                                    size: 32,
                                  ),
                                ),
                                title: Text(
                                  material['name'],
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Subject: ${material['subject']}',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Uploaded: ${material['uploadedAt'].toString().split('.')[0]}',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.red.shade400,
                                    size: 28,
                                  ),
                                  onPressed: () => _deleteFile(index),
                                  splashRadius: 24,
                                ),
                              ),
                            );
                          },
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