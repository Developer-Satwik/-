import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../screens/class_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animated_gradient/animated_gradient.dart';
import 'package:rive/rive.dart' as rive;
import 'package:lottie/lottie.dart';
import 'package:blur/blur.dart';
import '../ai_tutor/ai_tutor_screen.dart';
import '../quizzes/quiz_taking_screen.dart';
import '../study_tools/note_taking_screen.dart';
import '../community/community_screen.dart';
import '../gamification/rewards_screen.dart';
import '../results/result_screen.dart';
import '../results/marksheet_model.dart';
import '../assignment/assignment_upload_screen.dart';
import '../assignment/assignment_model.dart';
import '../screens/class_details_screen.dart';
import '../services/ai_service.dart';
import '../screens/student_profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  final String name;

  const StudentDashboard({super.key, required this.name});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  String motivationalQuote = 'Loading motivational quote...';
  bool isLoading = true;
  List<Map<String, dynamic>> assignments = [
    {
      'title': 'Math Assignment',
      'deadline': DateTime.now().add(const Duration(hours: 2)),
      'isCompleted': false,
      'progress': 0.7,
    },
    {
      'title': 'Science Project',
      'deadline': DateTime.now().add(const Duration(days: 1)), 
      'isCompleted': false,
      'progress': 0.3,
    },
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isChatOpen = false;
  final TextEditingController _chatController = TextEditingController();
  String _aiResponse = '';
  bool _isAiLoading = false;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _fetchMotivationalQuote();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAssignmentDeadlines();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSmallScreen) Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
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
                    Icons.school_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                if (!isSmallScreen) const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    isSmallScreen ? 'EduGPT' : 'EducationGPT',
                    style: AppTheme.headingMedium.copyWith(
                      fontSize: isSmallScreen ? 24 : 28,
                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            centerTitle: false,
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
                              '2',
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
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
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
                            builder: (context) => StudentProfileScreen(
                              profile: StudentProfile(
                                name: widget.name,
                                rollNumber: 'CS21-001',
                                department: 'Computer Science',
                                email: 'student@university.edu',
                                phoneNumber: '+1 234 567 8901',
                                semester: '4th',
                                section: 'A',
                                cgpa: 3.75,
                                creditsCompleted: 60,
                                enrolledCourses: [
                                  'Advanced Algorithms',
                                  'Database Systems',
                                  'Software Engineering',
                                  'Computer Networks',
                                  'Machine Learning',
                                ],
                                achievements: [
                                  'Dean\'s List - Fall 2023',
                                  'First Prize in Coding Competition',
                                  'Best Project Award',
                                ],
                                attendance: {
                                  'Advanced Algorithms': 85.5,
                                  'Database Systems': 92.0,
                                  'Software Engineering': 88.5,
                                  'Computer Networks': 78.0,
                                  'Machine Learning': 90.0,
                                },
                                guardianName: 'Mr. Robert Smith',
                                guardianContact: '+1 234 567 8902',
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome back,',
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.name,
                      style: AppTheme.headingMedium.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.school_outlined, 'AI Tutor', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AITutorScreen()),
                );
              }),
              _buildDrawerItem(Icons.quiz_outlined, 'Take a Quiz', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizTakingScreen(quizTitle: 'Sample Quiz'),
                  ),
                );
              }),
              _buildDrawerItem(Icons.note_outlined, 'Notes', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoteTakingScreen()),
                );
              }),
              _buildDrawerItem(Icons.people_outline, 'Community', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommunityScreen()),
                );
              }),
              _buildDrawerItem(Icons.emoji_events_outlined, 'Rewards', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RewardsScreen()),
                );
              }),
              _buildDrawerItem(Icons.assessment_outlined, 'Results', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsScreen(
                      marksheet: [
                        Marksheet(
                          subject: 'Mathematics',
                          marksObtained: 60,
                          totalMarks: 100,
                          feedback: 'Needs improvement in calculus.',
                        ),
                        Marksheet(
                          subject: 'English',
                          marksObtained: 70,
                          totalMarks: 100,
                          feedback: 'Good, but improve essay writing.',
                        ),
                        Marksheet(
                          subject: 'Physics',
                          marksObtained: 65,
                          totalMarks: 100,
                          feedback: 'Revise key concepts.',
                        ),
                      ],
                    ),
                  ),
                );
              }),
              _buildDrawerItem(Icons.upload_file_outlined, 'Upload Assignment', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentUploadScreen(
                      assignment: Assignment(
                        id: DateTime.now().toString(),
                        title: 'New Assignment',
                        description: 'Please upload your assignment.',
                        deadline: DateTime.now().add(const Duration(days: 7)),
                        studentId: 'current_student_id',
                        filePath: null,
                        marks: null,
                        feedback: null,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Container(
                                width: double.infinity,
                                height: 260,
                                decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                                child: SingleChildScrollView(
                                  child: Container(
                                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.accentGradient,
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
                                            Icons.waving_hand_rounded,
                                            size: isSmallScreen ? 24 : 32,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 12 : 16),
                                        Text(
                                          'Welcome back,',
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                            fontSize: isSmallScreen ? 14 : 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.name,
                                          style: AppTheme.headingLarge.copyWith(
                                            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                            fontSize: isSmallScreen ? 24 : 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 12 : 16),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 12 : 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.primaryGradient,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryColor.withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.trending_up_rounded,
                                                color: Colors.white,
                                                size: isSmallScreen ? 18 : 20,
                                              ),
                                              SizedBox(width: isSmallScreen ? 6 : 8),
                                              Text(
                                                '85% Progress',
                                                style: AppTheme.buttonText.copyWith(
                                                  fontSize: isSmallScreen ? 12 : 14,
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
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      isLoading
                          ? Shimmer.fromColors(
                              baseColor: isDarkMode
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              highlightColor: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[100]!,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            )
                          : AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _slideAnimation.value),
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: Container(
                                      width: double.infinity,
                                      height: 120,
                                      decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                                      child: SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                                                decoration: BoxDecoration(
                                                  gradient: AppTheme.accentGradient,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.format_quote_rounded,
                                                  color: Colors.white,
                                                  size: isSmallScreen ? 20 : 24,
                                                ),
                                              ),
                                              SizedBox(width: isSmallScreen ? 8 : 12),
                                              Flexible(
                                                child: Text(
                                                  motivationalQuote,
                                                  style: AppTheme.bodyLarge.copyWith(
                                                    color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                                    fontSize: isSmallScreen ? 12 : 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 32),
                      _buildSection(
                        'Class Schedule',
                        [
                          _buildClassItem('Mathematics', '10:00 AM', 'Room 101'),
                          _buildClassItem('Science', '12:00 PM', 'Room 202'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSection(
                        'Assignments',
                        assignments.map((assignment) {
                          final deadline = assignment['deadline'];
                          final timeLeft = deadline.difference(DateTime.now());
                          return _buildAssignmentItem(
                            assignment['title'],
                            timeLeft.inHours,
                            assignment['progress'],
                            () => _showNotification(assignment['title']),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            if (_isChatOpen) _buildChatInterface(),
          ],
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
            onPressed: () => setState(() => _isChatOpen = !_isChatOpen),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              _isChatOpen ? Icons.close : Icons.chat_bubble_outline,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              title,
              style: AppTheme.headingMedium.copyWith(
                color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildClassItem(String subject, String time, String room) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetailsScreen(
                classDetails: ClassDetails(
                  className: subject,
                  professorName: 'Dr. John Smith',
                  startTime: time,
                  endTime: '11:30 AM',
                  roomNumber: room,
                  department: 'Science & Technology',
                  description: 'This course covers advanced topics in $subject.',
                  professorEmail: 'john.smith@university.edu',
                  upcomingTopics: [
                    'Introduction to Advanced Concepts',
                    'Theoretical Foundations',
                    'Practical Applications',
                  ],
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subject,
                        style: AppTheme.headingMedium.copyWith(
                          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$time • $room',
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDarkMode ? Colors.white54 : AppTheme.lightPrimaryColor.withOpacity(0.5),
                  size: isSmallScreen ? 20 : 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentItem(String title, int hoursLeft, double progress, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final assignment = Assignment(
            id: DateTime.now().toString(),
            title: title,
            description: 'Please complete and upload your $title.',
            deadline: DateTime.now().add(Duration(hours: hoursLeft)),
            studentId: 'current_student_id',
            filePath: null,
            marks: null,
            feedback: null,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssignmentUploadScreen(
                assignment: assignment,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
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
                        Icons.assignment_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.headingMedium.copyWith(
                              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (hoursLeft < 24 ? AppTheme.warningColor : AppTheme.successColor).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$hoursLeft hours left',
                              style: AppTheme.bodyLarge.copyWith(
                                color: hoursLeft < 24 ? AppTheme.warningColor : AppTheme.successColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDarkMode ? Colors.white54 : AppTheme.lightPrimaryColor.withOpacity(0.5),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress < 0.3
                                ? AppTheme.errorColor
                                : progress < 0.7
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor,
                          ),
                          minHeight: 8,
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

  void _showNotification(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Assignment "$title" is due soon!',
          style: AppTheme.bodyLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _fetchMotivationalQuote() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        motivationalQuote = 'Success is not final, failure is not fatal: it is the courage to continue that counts.';
        isLoading = false;
      });
    }
  }

  void _checkAssignmentDeadlines() {
    for (var assignment in assignments) {
      if (!assignment['isCompleted'] &&
          assignment['deadline'].difference(DateTime.now()).inHours < 24) {
        _showNotification(assignment['title']);
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isAiLoading = true;
    });

    try {
      final response = await AIService.askQuestion(_chatController.text);
      setState(() {
        _aiResponse = response;
        _isAiLoading = false;
        _chatController.clear();
      });
    } catch (e) {
      setState(() {
        _aiResponse = 'Sorry, I encountered an error. Please try again.';
        _isAiLoading = false;
      });
    }
  }

  Widget _buildChatInterface() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: 16,
      bottom: _isChatOpen ? 80 : -400,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Tutor Chat',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _isChatOpen = false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_aiResponse.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : AppTheme.lightPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _aiResponse,
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                            ),
                          ),
                        ),
                      if (_isAiLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? AppTheme.surfaceColor 
                    : AppTheme.lightSurfaceColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: AppTheme.accentColor,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}