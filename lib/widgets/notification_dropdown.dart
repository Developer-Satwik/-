import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import 'package:intl/intl.dart';

class NotificationDropdown extends StatefulWidget {
  final String userId;
  final LayerLink layerLink;
  final VoidCallback onClose;

  const NotificationDropdown({
    Key? key,
    required this.userId,
    required this.layerLink,
    required this.onClose,
  }) : super(key: key);

  @override
  _NotificationDropdownState createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<NotificationDropdown> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _notificationService.getNotifications(widget.userId);
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications(widget.userId);
      if (mounted) {
        setState(() {
          _notifications = [];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      await _loadNotifications();
    } catch (e) {
      // Handle error
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    // Calculate responsive dimensions
    final dropdownWidth = isSmallScreen ? screenSize.width * 0.85 : (isTablet ? 360.0 : 400.0);
    final maxHeight = screenSize.height * (isSmallScreen ? 0.4 : (isTablet ? 0.5 : 0.4));
    final horizontalOffset = isSmallScreen 
        ? -(dropdownWidth - 32) 
        : -dropdownWidth + 60;
    
    return CompositedTransformFollower(
      link: widget.layerLink,
      offset: Offset(horizontalOffset, isSmallScreen ? 50 : 60),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        color: isDarkMode ? AppTheme.surfaceColor : AppTheme.lightSurfaceColor,
        child: Container(
          width: dropdownWidth,
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 16,
                  vertical: isSmallScreen ? 8 : 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: AppTheme.headingMedium.copyWith(
                        color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                        fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 22),
                      ),
                    ),
                    if (_notifications.isNotEmpty)
                      TextButton(
                        onPressed: _clearAllNotifications,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 12,
                            vertical: isSmallScreen ? 2 : 8,
                          ),
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Clear All',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 11 : 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                  child: SizedBox(
                    width: isSmallScreen ? 20 : 24,
                    height: isSmallScreen ? 20 : 24,
                    child: CircularProgressIndicator(
                      strokeWidth: isSmallScreen ? 2 : 3,
                      color: AppTheme.accentColor,
                    ),
                  ),
                )
              else if (_notifications.isEmpty)
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: isSmallScreen ? 32 : 48,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 12),
                      Text(
                        'No notifications yet',
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                          fontSize: isSmallScreen ? 12 : 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _markAsRead(notification.id),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 16,
                              vertical: isSmallScreen ? 8 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: notification.read
                                  ? Colors.transparent
                                  : (isDarkMode ? Colors.white.withOpacity(0.05) : AppTheme.lightPrimaryColor.withOpacity(0.05)),
                              border: Border(
                                bottom: BorderSide(
                                  color: isDarkMode ? Colors.white12 : Colors.black12,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: AppTheme.bodyLarge.copyWith(
                                          color: isDarkMode ? Colors.white : AppTheme.lightPrimaryColor,
                                          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                                          fontSize: isSmallScreen ? 13 : (isTablet ? 15 : 16),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(notification.createdAt),
                                      style: AppTheme.bodySmall.copyWith(
                                        color: isDarkMode ? Colors.white38 : Colors.black38,
                                        fontSize: isSmallScreen ? 9 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 4),
                                Text(
                                  notification.message,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: isDarkMode ? Colors.white70 : Colors.black87,
                                    fontSize: isSmallScreen ? 11 : (isTablet ? 13 : 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 