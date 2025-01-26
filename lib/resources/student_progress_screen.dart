import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/marks_evaluation_service.dart';
import '../results/marksheet_model.dart';
import '../screens/class_performance_screen.dart';

class StudentProgressScreen extends StatefulWidget {
  @override
  _StudentProgressScreenState createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  final List<Map<String, dynamic>> classes = [
    {
      'name': 'Mathematics',
      'section': 'A',
      'averagePerformance': 85.5,
      'totalStudents': 30,
      'students': [
        {
          'name': 'John Doe',
          'attendance': '90%',
          'grades': 'A',
          'performance': 'Excellent',
          'marksheet': [
            Marksheet(subject: 'Math', marksObtained: 85, totalMarks: 100, feedback: ''),
            Marksheet(subject: 'Quiz 1', marksObtained: 90, totalMarks: 100, feedback: ''),
            Marksheet(subject: 'Mid-term', marksObtained: 80, totalMarks: 100, feedback: ''),
          ],
        },
        {
          'name': 'Jane Smith',
          'attendance': '85%',
          'grades': 'B+',
          'performance': 'Good',
          'marksheet': [
            Marksheet(subject: 'Math', marksObtained: 75, totalMarks: 100, feedback: ''),
            Marksheet(subject: 'Quiz 1', marksObtained: 80, totalMarks: 100, feedback: ''),
            Marksheet(subject: 'Mid-term', marksObtained: 85, totalMarks: 100, feedback: ''),
          ],
        },
      ],
    },
    {
      'name': 'Physics',
      'section': 'B',
      'averagePerformance': 82.0,
      'totalStudents': 25,
      'students': [
        {
          'name': 'Alice Johnson',
          'attendance': '95%',
          'grades': 'A+',
          'performance': 'Outstanding',
          'marksheet': [
            Marksheet(subject: 'Physics', marksObtained: 95, totalMarks: 100, feedback: ''),
            Marksheet(subject: 'Lab Work', marksObtained: 98, totalMarks: 100, feedback: ''),
            Marksheet(subject: 'Project', marksObtained: 92, totalMarks: 100, feedback: ''),
          ],
        },
        {
          'name': 'Bob Brown',
          'attendance': '80%',
          'grades': 'B',
          'performance': 'Satisfactory',
          'marksheet': [
            Marksheet(subject: 'Physics', marksObtained: 65, totalMarks: 100, feedback: ''),
            Marksheet(subject: 'Lab Work', marksObtained: 70, totalMarks: 100, feedback: ''),
            Marksheet(subject: 'Project', marksObtained: 75, totalMarks: 100, feedback: ''),
          ],
        },
      ],
    },
  ];

  bool _isAnalyzing = false;
  String _aiFeedback = '';
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Class Progress',
                    style: AppTheme.headingLarge.copyWith(
                      color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                        child: TextField(
                          controller: _searchController,
                          style: AppTheme.bodyLarge.copyWith(
                            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search classes or students...',
                            hintStyle: AppTheme.bodyLarge.copyWith(
                              color: isDarkMode ? Colors.white60 : AppTheme.lightPrimaryColor.withOpacity(0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDarkMode ? Colors.white60 : AppTheme.lightPrimaryColor.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                      if (_aiFeedback.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Container(
                            decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.psychology,
                                      color: AppTheme.accentColor,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'AI Insights',
                                      style: AppTheme.headingMedium.copyWith(
                                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  _aiFeedback,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: isDarkMode ? Colors.white.withOpacity(0.9) : AppTheme.lightPrimaryColor.withOpacity(0.9),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final classData = classes[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassPerformanceScreen(
                                  classData: classData,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.school_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${classData['name']} - Section ${classData['section']}',
                                              style: AppTheme.headingMedium.copyWith(
                                                color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${classData['totalStudents']} Students',
                                              style: AppTheme.bodyLarge.copyWith(
                                                color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getPerformanceColor(classData['averagePerformance']).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _getPerformanceColor(classData['averagePerformance']).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          '${classData['averagePerformance']}%',
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: _getPerformanceColor(classData['averagePerformance']),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Performance Distribution',
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: classData['averagePerformance'] / 100,
                                            backgroundColor: (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor).withOpacity(0.1),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              _getPerformanceColor(classData['averagePerformance']),
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
                    },
                    childCount: classes.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPerformanceColor(double performance) {
    if (performance >= 90) return AppTheme.successColor;
    if (performance >= 80) return AppTheme.primaryColor;
    if (performance >= 70) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}