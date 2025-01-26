import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> saveNote(String note) async {
    await _supabase.from('notes').insert({'content': note});
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    return await _supabase.from('notes').select();
  }
}