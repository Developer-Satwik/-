import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class TeacherProfile {
  final String name;
  final String department;
  final String email;
  final String phoneNumber;
  final String officeRoom;
  final String designation;
  final String specialization;
  final List<String> subjects;
  final String education;
  final String officeHours;
  final String researchInterests;
  final List<String> publications;

  TeacherProfile({
    required this.name,
    required this.department,
    required this.email,
    required this.phoneNumber,
    required this.officeRoom,
    required this.designation,
    required this.specialization,
    required this.subjects,
    required this.education,
    required this.officeHours,
    required this.researchInterests,
    required this.publications,
  });
}

class TeacherProfileScreen extends StatelessWidget {
  final TeacherProfile profile;

  const TeacherProfileScreen({
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
                      profile.designation,
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
                'Contact Information',
                [
                  _buildInfoRow('Email', profile.email, Icons.email_outlined, isDarkMode),
                  _buildInfoRow('Phone', profile.phoneNumber, Icons.phone_outlined, isDarkMode),
                  _buildInfoRow('Office', profile.officeRoom, Icons.location_on_outlined, isDarkMode),
                  _buildInfoRow('Office Hours', profile.officeHours, Icons.access_time_outlined, isDarkMode),
                ],
                isDarkMode,
              ),
              _buildInfoSection(
                'Academic Information',
                [
                  _buildInfoRow('Department', profile.department, Icons.business_outlined, isDarkMode),
                  _buildInfoRow('Specialization', profile.specialization, Icons.school_outlined, isDarkMode),
                  _buildInfoRow('Education', profile.education, Icons.psychology_outlined, isDarkMode),
                ],
                isDarkMode,
              ),
              _buildInfoSection(
                'Teaching',
                [
                  const Text(
                    'Subjects',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildChipList(profile.subjects, isDarkMode),
                ],
                isDarkMode,
              ),
              _buildInfoSection(
                'Research',
                [
                  _buildInfoRow('Research Interests', profile.researchInterests, Icons.science_outlined, isDarkMode),
                  const SizedBox(height: 16),
                  const Text(
                    'Recent Publications',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...profile.publications.map((publication) {
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
                              publication,
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