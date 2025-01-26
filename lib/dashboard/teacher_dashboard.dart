import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../quizzes/quiz_creation_screen.dart';
import '../settings/settings_screen.dart';
import '../results/teacher_marksheet_screen.dart';
import '../resources/course_materials_screen.dart';
import '../resources/announcement_screen.dart';
import '../resources/student_progress_screen.dart';
import '../assignment/teacher_assignment_evaluation_screen.dart';
import '../screens/class_details_screen.dart';
import '../screens/teacher_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Colors.transparent,
      hoverColor: isDarkMode ? Colors.white.withOpacity(0.1) : AppTheme.lightPrimaryColor.withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final horizontalPadding = screenSize.width * 0.06;
    final verticalPadding = screenSize.height * 0.03;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSmallScreen) Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            Flexible(
              child: Text(
                isSmallScreen ? 'EduGPT' : 'EducationGPT',
                style: AppTheme.headingMedium.copyWith(
                  fontSize: isSmallScreen ? 20 : 24,
                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              size: 28,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // TODO: Implement notifications view
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.1) : AppTheme.lightPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        size: isSmallScreen ? 24 : 26,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '3',
                          style: AppTheme.bodyLarge.copyWith(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: isSmallScreen ? 4 : 8,
              right: isSmallScreen ? 8 : 16,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pushNamed(context, '/settings'),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : AppTheme.lightPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    size: isSmallScreen ? 24 : 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherProfileScreen(
                            profile: TeacherProfile(
                              name: 'Dr. John Smith',
                              department: 'Science & Technology',
                              email: 'john.smith@university.edu',
                              phoneNumber: '+1 234 567 8900',
                              officeRoom: 'Room 405',
                              designation: 'Professor',
                              specialization: 'Computer Science',
                              subjects: [
                                'Advanced Algorithms',
                                'Machine Learning',
                                'Data Structures',
                                'Software Engineering',
                              ],
                              education: 'Ph.D. in Computer Science',
                              officeHours: 'Mon-Thu 2:00 PM - 4:00 PM',
                              researchInterests: 'Artificial Intelligence, Machine Learning, Data Mining',
                              publications: [
                                'Machine Learning Applications in Education (2023)',
                                'Advanced Algorithms for Big Data Processing (2022)',
                                'Artificial Intelligence in Modern Education (2021)',
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dr. John Smith',
                    style: AppTheme.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Professor',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  _buildDrawerItem(context, Icons.quiz_outlined, 'Create Quiz', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizCreationScreen()),
                    );
                  }),
                  _buildDrawerItem(context, Icons.assessment_outlined, 'Evaluate Marksheets', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeacherMarksheetScreen()),
                    );
                  }),
                  _buildDrawerItem(context, Icons.trending_up_outlined, 'Student Progress', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentProgressScreen()),
                    );
                  }),
                  _buildDrawerItem(context, Icons.campaign_outlined, 'Announcements', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnnouncementScreen()),
                    );
                  }),
                  _buildDrawerItem(context, Icons.assignment_outlined, 'Evaluate Assignments', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeacherAssignmentEvaluationScreen()),
                    );
                  }),
                  _buildDrawerItem(context, Icons.book_outlined, 'Course Materials', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CourseMaterialsScreen()),
                    );
                  }),
                  _buildDrawerItem(context, Icons.settings_outlined, 'Settings', () {
                    Navigator.pushNamed(context, '/settings');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: isSmallScreen ? 30 : 36,
                  fontWeight: FontWeight.w300,
                  color: isDarkMode ? Colors.white.withOpacity(0.9) : AppTheme.lightPrimaryColor.withOpacity(0.9),
                ),
              ),
              Text(
                'Professor',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: isSmallScreen ? 30 : 36,
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..shader = AppTheme.accentGradient.createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              SizedBox(height: screenSize.height * 0.04),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: screenSize.width < 600 ? 1 : (screenSize.width < 1200 ? 2 : 3),
                mainAxisSpacing: screenSize.height * 0.02,
                crossAxisSpacing: screenSize.width * 0.04,
                childAspectRatio: isSmallScreen ? 2.2 : (screenSize.width < 1200 ? 1.8 : 1.6),
                children: [
                  _buildQuickActionCard(
                    context,
                    'Create Quiz',
                    Icons.add_circle_outline,
                    AppTheme.primaryGradient,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizCreationScreen())),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Evaluate Marksheets',
                    Icons.assessment_outlined,
                    AppTheme.accentGradient,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherMarksheetScreen())),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Student Progress',
                    Icons.trending_up_outlined,
                    AppTheme.primaryGradient,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => StudentProgressScreen())),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Announcements',
                    Icons.campaign_outlined,
                    AppTheme.accentGradient,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnnouncementScreen())),
                  ),
                ],
              ),
              
              SizedBox(height: screenSize.height * 0.04),
              
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Today's Schedule",
                    style: AppTheme.headingMedium.copyWith(
                      fontSize: isSmallScreen ? 22 : 26,
                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsScreen(
                        classDetails: ClassDetails(
                          className: 'Mathematics',
                          professorName: 'Dr. John Smith',
                          startTime: '10:00 AM',
                          endTime: '11:30 AM',
                          roomNumber: '101',
                          department: 'Science & Technology',
                          description: 'This course covers advanced topics in Mathematics.',
                          professorEmail: 'john.smith@university.edu',
                          upcomingTopics: [
                            'Advanced Calculus',
                            'Linear Algebra',
                            'Differential Equations',
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: _buildScheduleCard(
                    'Mathematics',
                    '10:00 AM',
                    'Section A • Room 101',
                    AppTheme.primaryGradient,
                    isDarkMode,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsScreen(
                        classDetails: ClassDetails(
                          className: 'Science',
                          professorName: 'Dr. John Smith',
                          startTime: '12:00 PM',
                          endTime: '1:30 PM',
                          roomNumber: '202',
                          department: 'Science & Technology',
                          description: 'This course covers fundamental concepts in Science.',
                          professorEmail: 'john.smith@university.edu',
                          upcomingTopics: [
                            'Physics Fundamentals',
                            'Chemical Reactions',
                            'Biology Basics',
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: _buildScheduleCard(
                    'Science',
                    '12:00 PM',
                    'Section B • Room 202',
                    AppTheme.accentGradient,
                    isDarkMode,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.04),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TeacherAssignmentEvaluationScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.assignment_outlined, color: Colors.white, size: isSmallScreen ? 24 : 28),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkMode ? Colors.white.withOpacity(0.12) : AppTheme.lightSurfaceColor.withOpacity(0.8),
            isDarkMode ? Colors.white.withOpacity(0.06) : AppTheme.lightSurfaceColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.12) : AppTheme.lightPrimaryColor.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode ? Colors.white.withOpacity(0.5) : AppTheme.lightPrimaryColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    String subject,
    String time,
    String details,
    LinearGradient gradient,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkMode ? Colors.white.withOpacity(0.12) : AppTheme.lightSurfaceColor.withOpacity(0.8),
            isDarkMode ? Colors.white.withOpacity(0.06) : AppTheme.lightSurfaceColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.12) : AppTheme.lightPrimaryColor.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.school_outlined, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$time • $details',
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDarkMode ? Colors.white.withOpacity(0.7) : AppTheme.lightPrimaryColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}