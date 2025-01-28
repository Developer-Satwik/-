import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

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
          'Community',
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            fontSize: isSmallScreen ? 24 : 28,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              size: isSmallScreen ? 24 : 26,
            ),
            onPressed: () {
              // Navigate to search for study groups or mentors
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          children: [
            // Study Groups Section
            _buildSectionHeader('Study Groups', isDarkMode, isSmallScreen),
            _buildStudyGroupCard(
              'Advanced Calculus',
              '5 members',
              'Solve complex calculus problems together.',
              isDarkMode ? AppTheme.accentColor.withOpacity(0.1) : Colors.blue.shade50,
              isDarkMode,
              isSmallScreen,
            ),
            _buildStudyGroupCard(
              'Machine Learning',
              '8 members',
              'Learn and build ML models as a team.',
              isDarkMode ? AppTheme.secondaryColor.withOpacity(0.1) : Colors.purple.shade50,
              isDarkMode,
              isSmallScreen,
            ),
            SizedBox(height: verticalPadding),
            _buildGradientButton(
              'Create a Study Group',
              () {
                // Navigate to create a new study group
              },
              isSmallScreen,
            ),

            // Virtual Study Rooms Section
            _buildSectionHeader('Virtual Study Rooms', isDarkMode, isSmallScreen),
            _buildStudyRoomCard(
              'Space Exploration Theme',
              'Join this room for a cosmic study experience.',
              AppTheme.accentColor,
              isDarkMode,
              isSmallScreen,
            ),
            _buildStudyRoomCard(
              'Ancient Library Theme',
              'Study in a serene, library-like environment.',
              AppTheme.secondaryColor,
              isDarkMode,
              isSmallScreen,
            ),
            SizedBox(height: verticalPadding),
            _buildGradientButton(
              'Create a Virtual Study Room',
              () {
                // Navigate to create a new virtual study room
              },
              isSmallScreen,
            ),

            // Community Challenges Section
            _buildSectionHeader('Community Challenges', isDarkMode, isSmallScreen),
            _buildChallengeCard(
              'Coding Challenge',
              'Solve 10 programming problems in 24 hours.',
              Icons.code,
              isDarkMode,
              isSmallScreen,
            ),
            _buildChallengeCard(
              'Essay Writing Challenge',
              'Write an essay on climate change.',
              Icons.edit_document,
              isDarkMode,
              isSmallScreen,
            ),
            SizedBox(height: verticalPadding),
            _buildGradientButton(
              'View All Challenges',
              () {
                // Navigate to view all challenges
              },
              isSmallScreen,
            ),

            // Discussion Forums Section
            _buildSectionHeader('Discussion Forums', isDarkMode, isSmallScreen),
            _buildForumCard(
              'AI Ethics',
              'Discuss the ethical implications of AI in healthcare.',
              Icons.psychology,
              isDarkMode,
              isSmallScreen,
            ),
            _buildForumCard(
              'Career Advice',
              'Get advice on internships, jobs, and career paths.',
              Icons.work,
              isDarkMode,
              isSmallScreen,
            ),
            SizedBox(height: verticalPadding),
            _buildGradientButton(
              'View All Forums',
              () {
                // Navigate to view all forums
              },
              isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
      child: Text(
        title,
        style: AppTheme.headingLarge.copyWith(
          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          fontSize: isSmallScreen ? 24 : 28,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildStudyGroupCard(String title, String members, String description, Color bgColor, bool isDarkMode, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black12 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to the study group details screen
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  '$members • $description',
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.8),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudyRoomCard(String title, String description, Color accentColor, bool isDarkMode, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to the virtual study room
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: isSmallScreen ? 50 : 60,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
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
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        description,
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.8),
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(String title, String description, IconData icon, bool isDarkMode, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to the challenge details screen
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white10 : AppTheme.lightPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    size: isSmallScreen ? 22 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
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
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        description,
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.8),
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForumCard(String title, String description, IconData icon, bool isDarkMode, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to the forum discussion screen
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white10 : AppTheme.lightPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    size: isSmallScreen ? 22 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
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
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        description,
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.8),
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed, bool isSmallScreen) {
    return Container(
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: AppTheme.buttonText.copyWith(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}