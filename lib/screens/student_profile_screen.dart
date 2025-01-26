import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class StudentProfile {
  final String name;
  final String rollNumber;
  final String department;
  final String email;
  final String phoneNumber;
  final String semester;
  final String section;
  final double cgpa;
  final int creditsCompleted;
  final List<String> enrolledCourses;
  final List<String> achievements;
  final Map<String, double> attendance;
  final String guardianName;
  final String guardianContact;

  StudentProfile({
    required this.name,
    required this.rollNumber,
    required this.department,
    required this.email,
    required this.phoneNumber,
    required this.semester,
    required this.section,
    required this.cgpa,
    required this.creditsCompleted,
    required this.enrolledCourses,
    required this.achievements,
    required this.attendance,
    required this.guardianName,
    required this.guardianContact,
  });
}

class StudentProfileScreen extends StatelessWidget {
  final StudentProfile profile;

  const StudentProfileScreen({
    super.key,
    required this.profile,
  });

  Widget _buildInfoSection(String title, List<Widget> children, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingMedium.copyWith(
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipList(List<String> items, bool isDarkMode) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item,
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttendanceCard(String subject, double percentage, bool isDarkMode) {
    final color = percentage >= 75 ? AppTheme.successColor : AppTheme.warningColor;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              subject,
              style: AppTheme.bodyLarge.copyWith(
                color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: AppTheme.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
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

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
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
              Icons.edit_outlined,
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            ),
            onPressed: () {
              // TODO: Implement edit profile functionality
            },
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
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Colors.white24 : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: AppTheme.headingLarge.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        fontSize: isSmallScreen ? 24 : 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.rollNumber,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoSection(
                'Academic Information',
                [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'CGPA',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                profile.cgpa.toStringAsFixed(2),
                                style: AppTheme.headingLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Credits',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                profile.creditsCompleted.toString(),
                                style: AppTheme.headingLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow('Department', profile.department, Icons.business_outlined, isDarkMode),
                  _buildInfoRow('Semester', profile.semester, Icons.calendar_today_outlined, isDarkMode),
                  _buildInfoRow('Section', profile.section, Icons.group_outlined, isDarkMode),
                ],
                isDarkMode,
              ),
              _buildInfoSection(
                'Contact Information',
                [
                  _buildInfoRow('Email', profile.email, Icons.email_outlined, isDarkMode),
                  _buildInfoRow('Phone', profile.phoneNumber, Icons.phone_outlined, isDarkMode),
                  _buildInfoRow('Guardian Name', profile.guardianName, Icons.person_outline, isDarkMode),
                  _buildInfoRow('Guardian Contact', profile.guardianContact, Icons.contact_phone_outlined, isDarkMode),
                ],
                isDarkMode,
              ),
              _buildInfoSection(
                'Current Courses',
                [
                  _buildChipList(profile.enrolledCourses, isDarkMode),
                ],
                isDarkMode,
              ),
              _buildInfoSection(
                'Attendance',
                profile.attendance.entries.map((entry) {
                  return _buildAttendanceCard(entry.key, entry.value, isDarkMode);
                }).toList(),
                isDarkMode,
              ),
              if (profile.achievements.isNotEmpty)
                _buildInfoSection(
                  'Achievements',
                  [
                    ...profile.achievements.map((achievement) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                achievement,
                                style: AppTheme.bodyLarge.copyWith(
                                  color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  isDarkMode,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 