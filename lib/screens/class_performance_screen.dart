import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/marks_evaluation_service.dart';
import '../results/marksheet_model.dart';

class ClassPerformanceScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  const ClassPerformanceScreen({
    Key? key,
    required this.classData,
  }) : super(key: key);

  @override
  _ClassPerformanceScreenState createState() => _ClassPerformanceScreenState();
}

class _ClassPerformanceScreenState extends State<ClassPerformanceScreen> {
  bool _isAnalyzing = false;
  String _aiFeedback = '';
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.school_rounded, color: Colors.white, size: 32),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.classData['name']} - Section ${widget.classData['section']}',
                                      style: AppTheme.headingLarge.copyWith(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 24 : 28,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${widget.classData['totalStudents']} Students',
                                      style: AppTheme.bodyLarge.copyWith(
                                        color: Colors.white70,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bar_chart_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Class Average: ${widget.classData['averagePerformance']}%',
                                  style: AppTheme.bodyLarge.copyWith(color: Colors.white),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                            hintText: 'Search students...',
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
                      SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final filter in ['All', 'Outstanding', 'Excellent', 'Good', 'Satisfactory'])
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  onSelected: (selected) {
                                    setState(() => _selectedFilter = filter);
                                  },
                                  backgroundColor: isDarkMode ? Colors.white12 : AppTheme.lightSurfaceColor,
                                  selectedColor: AppTheme.accentColor,
                                  labelStyle: AppTheme.bodyLarge.copyWith(
                                    color: _selectedFilter == filter
                                        ? Colors.white
                                        : (isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_aiFeedback.isNotEmpty) ...[
                        SizedBox(height: 24),
                        Container(
                          decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.psychology, color: AppTheme.accentColor),
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
                      ],
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 8,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenSize.width > 1200 ? 3 : (screenSize.width > 800 ? 2 : 1),
                    childAspectRatio: isSmallScreen ? 1.6 : 1.8,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = widget.classData['students'][index];
                      if (_selectedFilter != 'All' && student['performance'] != _selectedFilter) {
                        return null;
                      }
                      return Container(
                        decoration: isDarkMode ? AppTheme.glassDecoration : AppTheme.lightGlassDecoration,
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              _isAnalyzing = true;
                              _aiFeedback = '';
                            });
                            try {
                              final feedback = await MarksEvaluationService.analyzeMarksheet(student['marksheet']);
                              setState(() {
                                _isAnalyzing = false;
                                _aiFeedback = feedback;
                              });
                            } catch (e) {
                              setState(() {
                                _isAnalyzing = false;
                                _aiFeedback = 'Analysis failed: $e';
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
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
                                        gradient: AppTheme.accentGradient,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.person_outline, color: Colors.white),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student['name'],
                                            style: AppTheme.headingMedium.copyWith(
                                              color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                              fontSize: isSmallScreen ? 18 : 20,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Grade: ${student['grades']}',
                                            style: AppTheme.bodyLarge.copyWith(
                                              color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
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
                                            'Attendance',
                                            style: AppTheme.bodyLarge.copyWith(
                                              color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getPerformanceColor(double.parse(student['attendance'].replaceAll('%', ''))).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              student['attendance'],
                                              style: AppTheme.bodyLarge.copyWith(
                                                color: _getPerformanceColor(double.parse(student['attendance'].replaceAll('%', ''))),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getPerformanceColor(double.parse(student['attendance'].replaceAll('%', ''))).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          student['performance'],
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: _getPerformanceColor(double.parse(student['attendance'].replaceAll('%', ''))),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: widget.classData['students'].length,
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