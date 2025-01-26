import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class ClassDetails {
  final String className;
  final String professorName;
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String department;
  final String description;
  
  final String professorEmail;
  final List<String> upcomingTopics;

  ClassDetails({
    required this.className,
    required this.professorName,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    required this.department,
    required this.description,
    required this.professorEmail,
    required this.upcomingTopics,
  });
}

class ClassDetailsScreen extends StatelessWidget {
  final ClassDetails classDetails;

  const ClassDetailsScreen({
    super.key,
    required this.classDetails,
  });

  Future<void> _cancelClass(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Class'),
        content: const Text('Are you sure you want to cancel this class? Students will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Send notifications to students
      final notificationService = NotificationService();
      await notificationService.sendNotification(
        'all_students', // You would typically have a list of enrolled student IDs
        'Class Cancelled',
        '${classDetails.className} scheduled for ${classDetails.startTime} has been cancelled.',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class cancelled successfully')),
        );
        Navigator.pop(context);
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
          'Class Details',
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
          IconButton(
            icon: Icon(
              Icons.cancel_outlined,
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            ),
            onPressed: () => _cancelClass(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classDetails.className,
                                style: AppTheme.headingLarge.copyWith(
                                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                  fontSize: isSmallScreen ? 24 : 28,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                classDetails.department,
                                style: AppTheme.bodyLarge.copyWith(
                                  color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(
                      context,
                      Icons.access_time_rounded,
                      '${classDetails.startTime} - ${classDetails.endTime}',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      Icons.room_rounded,
                      'Room ${classDetails.roomNumber}',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      Icons.person_outline_rounded,
                      classDetails.professorName,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      Icons.email_outlined,
                      classDetails.professorEmail,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Description',
                style: AppTheme.headingMedium.copyWith(
                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                  fontSize: isSmallScreen ? 20 : 24,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                child: Text(
                  classDetails.description,
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Upcoming Topics',
                style: AppTheme.headingMedium.copyWith(
                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                  fontSize: isSmallScreen ? 20 : 24,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                child: Column(
                  children: classDetails.upcomingTopics.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: AppTheme.accentGradient,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              topic,
                              style: AppTheme.bodyLarge.copyWith(
                                color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Row(
      children: [
        Icon(
          icon,
          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyLarge.copyWith(
              color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
} 