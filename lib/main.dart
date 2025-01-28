import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:animated_background/animated_background.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'dashboard/student_dashboard.dart';
import 'dashboard/teacher_dashboard.dart';
import 'settings/settings_screen.dart';
import 'utils/ocr_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && Platform.isIOS) {
    await OCRHelper.initializeTessdata();
  }
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  await Supabase.initialize(
    url: 'https://aqfqpjhvxwxvxvxvxvxv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxZnFwamh2eHd4dnh2eHZ4dnhidiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjk5NjQ0NjQ4LCJleHAiOjIwMTUyMjA2NDh9.Yx_Q9J2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2Z2',
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        title: 'Lessons',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        home: const HomeScreen(),
        routes: {
          '/student': (context) => const StudentDashboard(name: 'Student'),
          '/teacher': (context) => const TeacherDashboard(),
          '/settings': (context) => SettingsScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: themeProvider.textScaleFactor,
            ),
            child: child!,
          );
        },
        showSemanticsDebugger: themeProvider.isScreenReaderEnabled,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      body: Stack(
        children: [
          AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                baseColor: isDarkMode ? Colors.white : Colors.blue,
                spawnOpacity: 0.0,
                opacityChangeRate: 0.25,
                minOpacity: 0.1,
                maxOpacity: 0.3,
                particleCount: isSmallScreen ? 20 : 30,
                spawnMaxRadius: isSmallScreen ? 10.0 : 15.0,
                spawnMaxSpeed: 50.0,
                spawnMinSpeed: 20.0,
                spawnMinRadius: isSmallScreen ? 3.0 : 5.0,
              ),
            ),
            vsync: this,
            child: Container(
              decoration: BoxDecoration(
                gradient: isDarkMode ? 
                  const LinearGradient(
                    colors: [Color(0xFF1a1a1a), Color(0xFF0d47a1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ) :
                  const LinearGradient(
                    colors: [Colors.white, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: isSmallScreen ? 45 : 50,
                  height: isSmallScreen ? 45 : 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: isDarkMode ? Colors.white : Colors.blue,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.04,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? size.width * 0.04 : size.width * 0.05),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Color(0xFF2196F3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: isSmallScreen ? size.width * 0.12 : size.width * 0.15,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Lessons',
                                textStyle: AppTheme.headingLarge.copyWith(
                                  color: isDarkMode ? Colors.white : Colors.blue,
                                  fontSize: isSmallScreen ? size.width * 0.07 : size.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                                speed: const Duration(milliseconds: 200),
                              ),
                            ],
                            totalRepeatCount: 1,
                          ),
                          SizedBox(height: size.height * 0.02),
                          Text(
                            'Empowering Education Through Innovation',
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.blue.withOpacity(0.7),
                              fontSize: isSmallScreen ? size.width * 0.035 : size.width * 0.04,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: size.height * 0.04),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildRoleButton(
                                context,
                                'Student',
                                Icons.person_outline_rounded,
                                () => Navigator.pushNamed(context, '/student'),
                                isDarkMode,
                                size,
                                isSmallScreen,
                              ),
                              SizedBox(width: size.width * 0.04),
                              _buildRoleButton(
                                context,
                                'Teacher',
                                Icons.school_outlined,
                                () => Navigator.pushNamed(context, '/teacher'),
                                isDarkMode,
                                size,
                                isSmallScreen,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
    Size size,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? size.width * 0.06 : size.width * 0.08,
              vertical: isSmallScreen ? size.height * 0.02 : size.height * 0.025,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isSmallScreen ? size.width * 0.06 : size.width * 0.08,
                  color: Colors.white,
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  title,
                  style: AppTheme.buttonText.copyWith(
                    fontSize: isSmallScreen ? size.width * 0.035 : size.width * 0.04,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}