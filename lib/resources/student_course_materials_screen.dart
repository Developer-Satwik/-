import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class StudentCourseMaterialsScreen extends StatefulWidget {
  const StudentCourseMaterialsScreen({super.key});

  @override
  _StudentCourseMaterialsScreenState createState() => _StudentCourseMaterialsScreenState();
}

class _StudentCourseMaterialsScreenState extends State<StudentCourseMaterialsScreen> {
  // This would come from your database
  final Map<String, List<Map<String, dynamic>>> _subjectMaterials = {
    'Mathematics': [
      {
        'name': 'Calculus Notes.pdf',
        'type': 'pdf',
        'uploadedAt': DateTime.now(),
      },
      {
        'name': 'Algebra Practice.pdf',
        'type': 'pdf',
        'uploadedAt': DateTime.now(),
      },
    ],
    'Physics': [
      {
        'name': 'Mechanics Lecture.mp4',
        'type': 'mp4',
        'uploadedAt': DateTime.now(),
      },
    ],
    'Chemistry': [
      {
        'name': 'Organic Chemistry Notes.pdf',
        'type': 'pdf',
        'uploadedAt': DateTime.now(),
      },
    ],
  };

  Widget _buildSubjectCard(String subject, List<Map<String, dynamic>> materials, bool isDarkMode) {
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
      child: ExpansionTile(
        title: Text(
          subject,
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.subject,
            color: AppTheme.accentColor,
            size: 24,
          ),
        ),
        children: materials.map((material) => _buildMaterialTile(material, isDarkMode)).toList(),
      ),
    );
  }

  Widget _buildMaterialTile(Map<String, dynamic> material, bool isDarkMode) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          material['type'] == 'pdf'
              ? Icons.picture_as_pdf_rounded
              : material['type'] == 'mp4' || material['type'] == 'mov'
                  ? Icons.video_library_rounded
                  : Icons.insert_drive_file_rounded,
          color: AppTheme.accentColor,
          size: 24,
        ),
      ),
      title: Text(
        material['name'],
        style: AppTheme.bodyLarge.copyWith(
          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
        ),
      ),
      subtitle: Text(
        'Uploaded: ${material['uploadedAt'].toString().split('.')[0]}',
        style: AppTheme.bodyMedium.copyWith(
          color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.7),
        ),
      ),
      onTap: () {
        // Implement file viewing/downloading functionality
      },
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
                  'My Subjects',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: _subjectMaterials.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 80,
                                color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.3),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No materials available',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: _subjectMaterials.entries
                              .map((entry) => _buildSubjectCard(entry.key, entry.value, isDarkMode))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any controllers or streams
    super.dispose();
  }

  Future<void> loadMaterials() async {
    try {
      // Add error handling
      // ... existing code ...
    } catch (e) {
      print('Error loading materials: $e');
    }
  }
} 