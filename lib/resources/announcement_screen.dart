import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class AnnouncementScreen extends StatefulWidget {
  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      } else {
        _showSnackBar('No file selected.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Failed to pick file: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: isError ? AppTheme.errorColor.withOpacity(0.95) : AppTheme.successColor.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  void _sendAnnouncement() {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showSnackBar('Please fill in all fields.', isError: true);
      return;
    }

    print('Announcement Sent:');
    print('Title: $title');
    print('Description: $description');
    if (_selectedFile != null) {
      print('Attachment: ${_selectedFile!.name}');
    }

    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedFile = null;
    });

    _showSnackBar('Announcement sent successfully!');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1024;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'New Announcement',
          style: AppTheme.headingMedium.copyWith(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : (isTablet ? 800 : double.infinity),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : (isTablet ? 32 : 24),
                  vertical: isDesktop ? 40 : (isTablet ? 32 : 24),
                ),
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.85,
                  borderRadius: 20,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDarkMode ? Colors.white.withOpacity(0.1) : AppTheme.lightSurfaceColor.withOpacity(0.1),
                      isDarkMode ? Colors.white.withOpacity(0.05) : AppTheme.lightSurfaceColor.withOpacity(0.05),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDarkMode ? Colors.white.withOpacity(0.15) : AppTheme.lightSurfaceColor.withOpacity(0.15),
                      isDarkMode ? Colors.white.withOpacity(0.05) : AppTheme.lightSurfaceColor.withOpacity(0.05),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 32 : 24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          controller: _titleController,
                          label: 'Title',
                          hint: 'Enter announcement title',
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: isDesktop ? 36 : (isTablet ? 32 : 28)),
                        _buildInputField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Enter announcement details',
                          maxLines: 5,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: isDesktop ? 40 : (isTablet ? 36 : 32)),
                        Text(
                          'Attachment',
                          style: AppTheme.headingMedium.copyWith(
                            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (_selectedFile != null)
                          Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getFileIcon(),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                _selectedFile!.name,
                                style: AppTheme.bodyLarge.copyWith(
                                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                  fontSize: isDesktop ? 16 : 14,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.close, color: isDarkMode ? Colors.white60 : AppTheme.lightPrimaryColor.withOpacity(0.6)),
                                onPressed: () => setState(() => _selectedFile = null),
                              ),
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: Icon(Icons.attach_file),
                          label: Text(
                            'Add Attachment',
                            style: AppTheme.buttonText.copyWith(
                              fontSize: isDesktop ? 16 : 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppTheme.accentColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 32 : 24,
                              vertical: isDesktop ? 20 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 48 : (isTablet ? 40 : 36)),
                        Container(
                          width: double.infinity,
                          height: isDesktop ? 64 : (isTablet ? 56 : 48),
                          child: ElevatedButton(
                            onPressed: _sendAnnouncement,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 32 : 24,
                                vertical: isDesktop ? 20 : 16,
                              ),
                            ),
                            child: Text(
                              'Send Announcement',
                              style: AppTheme.buttonText.copyWith(
                                fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    required bool isDesktop,
    required bool isTablet,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.headingMedium.copyWith(
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTheme.bodyLarge.copyWith(
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.bodyLarge.copyWith(
                color: isDarkMode ? Colors.white38 : AppTheme.lightPrimaryColor.withOpacity(0.4),
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon() {
    if (_selectedFile == null) return Icons.attach_file;
    switch (_selectedFile!.extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}