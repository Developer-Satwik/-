import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;

  Future<void> sendNotification(String userId, String title, String message) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
      'read': false,
    });
  }

  Future<List<Notification>> getNotifications(String userId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response)
        .map((data) => Notification.fromMap(data))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'read': true})
        .eq('id', notificationId);
  }

  Future<void> clearAllNotifications(String userId) async {
    await _supabase
        .from('notifications')
        .delete()
        .eq('user_id', userId);
  }
} 