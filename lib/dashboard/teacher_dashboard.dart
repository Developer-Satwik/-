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
import '../widgets/notification_dropdown.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LayerLink _notificationLayerLink = LayerLink();
  OverlayEntry? _notificationOverlay;

  void _toggleNotificationDropdown() {
    if (_notificationOverlay == null) {
      _notificationOverlay = OverlayEntry(
        builder: (context) => NotificationDropdown(
          userId: 'teacher_id', // Replace with actual teacher ID
          layerLink: _notificationLayerLink,
          onClose: () {
            _notificationOverlay?.remove();
            _notificationOverlay = null;
          },
        ),
      );
      Overlay.of(context).insert(_notificationOverlay!);
    } else {
      _notificationOverlay?.remove();
      _notificationOverlay = null;
    }
  }

  @override
  void dispose() {
    _notificationOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final horizontalPadding = screenSize.width * (isSmallScreen ? 0.04 : 0.06);
    final verticalPadding = screenSize.height * (isSmallScreen ? 0.02 : 0.03);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      drawer: Drawer(
        backgroundColor: isDarkMode ? AppTheme.surfaceColor : AppTheme.lightSurfaceColor,
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
                              name: 'Dr. Divyanshu',
                              department: 'Science & Technology',
                              email: 'divyanshu.singh@xyz.edu',
                              phoneNumber: '+91 7321908788',
                              officeRoom: 'Room 405',
                              designation: 'Professor',
                              specialization: 'Computer Science',
                              subjects: ['Data Structures', 'Algorithms', 'Machine Learning'],
                              education: 'Ph.D. in Computer Science, M.S. in Software Engineering',
                              officeHours: 'Mon-Fri: 2:00 PM - 4:00 PM',
                              researchInterests: 'Artificial Intelligence, Data Mining, Cloud Computing',
                              publications: ['Machine Learning in Education', 'Cloud-based Learning Systems'],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Dr. Divyanshu',
                                style: AppTheme.headingMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'Professor',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Icon(
              Icons.menu,
              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              size: 24,
            ),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        actions: [
          CompositedTransformTarget(
            link: _notificationLayerLink,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _toggleNotificationDropdown,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkMode ? AppTheme.backgroundColor : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, left: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pushNamed(context, '/settings'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.settings_outlined,
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
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
                  'Welcome back,\nDr. Divyanshu',
                  style: AppTheme.headingLarge.copyWith(
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    fontSize: isSmallScreen ? 28 : 32,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                Text(
                  'Quick Actions',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    fontSize: isSmallScreen ? 22 : 26,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: isSmallScreen ? 1 : (screenSize.width < 900 ? 2 : 3),
                  mainAxisSpacing: screenSize.height * (isSmallScreen ? 0.015 : 0.02),
                  crossAxisSpacing: screenSize.width * (isSmallScreen ? 0.03 : 0.04),
                  childAspectRatio: isSmallScreen ? 3 : (screenSize.width < 900 ? 2.2 : 1.8),
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
                      'Evaluate Assignments',
                      Icons.assignment_outlined,
                      AppTheme.accentGradient,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherAssignmentEvaluationScreen())),
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
                _buildScheduleCard(
                  context,
                  'Mathematics',
                  '10:00 AM',
                  '11:30 AM',
                  'Room 101',
                  () => Navigator.push(
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
                ),
                SizedBox(height: screenSize.height * 0.02),
                _buildScheduleCard(
                  context,
                  'Science',
                  '12:00 PM',
                  '1:30 PM',
                  'Room 202',
                  () => Navigator.push(
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
                ),
              ],
            ),
          ),
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
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
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.12) : AppTheme.lightPrimaryColor.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: isSmallScreen ? 8 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 20),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode ? Colors.white.withOpacity(0.5) : AppTheme.lightPrimaryColor.withOpacity(0.5),
                  size: isSmallScreen ? 16 : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    String subject,
    String startTime,
    String endTime,
    String room,
    VoidCallback onTap,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;

    return Container(
      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : (isTablet ? 16 : 20),
              vertical: isSmallScreen ? 12 : (isTablet ? 14 : 16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : (isTablet ? 12 : 14)),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.3),
                        blurRadius: isSmallScreen ? 8 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.class_outlined,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : (isTablet ? 22 : 24),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : (isTablet ? 14 : 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: AppTheme.headingMedium.copyWith(
                          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                          fontSize: isSmallScreen ? 16 : (isTablet ? 18 : 20),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        '$startTime - $endTime • $room',
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                          fontSize: isSmallScreen ? 12 : (isTablet ? 13 : 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDarkMode ? Colors.white54 : AppTheme.lightPrimaryColor.withOpacity(0.5),
                  size: isSmallScreen ? 20 : (isTablet ? 22 : 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
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
}