import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Theme', isDarkMode),
              const SizedBox(height: 16),
              _buildThemeSelector(context, themeProvider),
              const SizedBox(height: 32),

              _buildSectionHeader('Accessibility', isDarkMode),
              const SizedBox(height: 16),
              _buildSettingTile(
                'High Contrast',
                'Increase contrast for better visibility',
                Icons.contrast,
                themeProvider.isHighContrast,
                (value) {
                  themeProvider.toggleHighContrast();
                  if (themeProvider.isSoundEnabled) {
                    SystemSound.play(SystemSoundType.click);
                  }
                  if (themeProvider.isVibrationEnabled) {
                    HapticFeedback.mediumImpact();
                  }
                },
                isDarkMode,
              ),
              const SizedBox(height: 16),
              _buildTextSizeSlider(context, themeProvider, isDarkMode),
              const SizedBox(height: 16),
              _buildSettingTile(
                'Screen Reader',
                'Enable voice assistance',
                Icons.record_voice_over,
                themeProvider.isScreenReaderEnabled,
                (value) {
                  themeProvider.toggleScreenReader();
                  if (themeProvider.isSoundEnabled) {
                    SystemSound.play(SystemSoundType.click);
                  }
                  if (themeProvider.isVibrationEnabled) {
                    HapticFeedback.mediumImpact();
                  }
                },
                isDarkMode,
              ),
              const SizedBox(height: 32),

              _buildSectionHeader('Feedback', isDarkMode),
              const SizedBox(height: 16),
              _buildSettingTile(
                'Sound',
                'Enable sound effects',
                Icons.volume_up,
                themeProvider.isSoundEnabled,
                (value) {
                  themeProvider.toggleSound();
                  if (themeProvider.isVibrationEnabled) {
                    HapticFeedback.mediumImpact();
                  }
                },
                isDarkMode,
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                'Vibration',
                'Enable haptic feedback',
                Icons.vibration,
                themeProvider.isVibrationEnabled,
                (value) {
                  themeProvider.toggleVibration();
                  if (themeProvider.isSoundEnabled) {
                    SystemSound.play(SystemSoundType.click);
                  }
                },
                isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Row(
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
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildThemeOption(
            'Light',
            Icons.light_mode_outlined,
            themeProvider.themeMode == ThemeMode.light,
            () {
              themeProvider.setThemeMode(ThemeMode.light);
              if (themeProvider.isSoundEnabled) {
                SystemSound.play(SystemSoundType.click);
              }
              if (themeProvider.isVibrationEnabled) {
                HapticFeedback.mediumImpact();
              }
            },
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            'Dark',
            Icons.dark_mode_outlined,
            themeProvider.themeMode == ThemeMode.dark,
            () {
              themeProvider.setThemeMode(ThemeMode.dark);
              if (themeProvider.isSoundEnabled) {
                SystemSound.play(SystemSoundType.click);
              }
              if (themeProvider.isVibrationEnabled) {
                HapticFeedback.mediumImpact();
              }
            },
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            'System',
            Icons.settings_system_daydream_outlined,
            themeProvider.themeMode == ThemeMode.system,
            () {
              themeProvider.setThemeMode(ThemeMode.system);
              if (themeProvider.isSoundEnabled) {
                SystemSound.play(SystemSoundType.click);
              }
              if (themeProvider.isVibrationEnabled) {
                HapticFeedback.mediumImpact();
              }
            },
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? Colors.white.withOpacity(0.1) : AppTheme.lightPrimaryColor.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: AppTheme.bodyLarge.copyWith(
                  color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: value ? AppTheme.accentGradient : null,
            color: value ? null : (isDarkMode ? Colors.white.withOpacity(0.1) : AppTheme.lightPrimaryColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: value
                ? Colors.white
                : (isDarkMode ? Colors.white : AppTheme.lightPrimaryColor),
          ),
        ),
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodyLarge.copyWith(
            color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppTheme.accentColor,
        ),
      ),
    );
  }

  Widget _buildTextSizeSlider(BuildContext context, ThemeProvider themeProvider, bool isDarkMode) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.text_fields,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Size',
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adjust the size of text throughout the app',
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white70 : AppTheme.lightPrimaryColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.text_decrease, size: 20),
              Expanded(
                child: Slider(
                  value: themeProvider.textScaleFactor,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  onChanged: (value) {
                    themeProvider.setTextScaleFactor(value);
                    if (themeProvider.isVibrationEnabled) {
                      HapticFeedback.selectionClick();
                    }
                  },
                  activeColor: AppTheme.accentColor,
                ),
              ),
              const Icon(Icons.text_increase, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}