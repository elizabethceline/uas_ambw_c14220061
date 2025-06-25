// lib/services/supabase_service.dart
import 'package:uas_ambw_c14220061/main.dart';
import 'package:uas_ambw_c14220061/models/mood.dart';

class SupabaseService {
  Future<void> addMood(Mood entry) async {
    try {
      await supabase.from('moods').insert(entry.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Mood>> getMoodHistory(String userId) {
    return supabase
        .from('moods')
        .stream(primaryKey: ['id']) 
        .eq('user_id', userId) 
        .order('created_at', ascending: false) 
        .map((maps) => maps.map((map) => Mood.fromJson(map)).toList());
  }
}
