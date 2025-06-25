import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService with ChangeNotifier {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  User? _user;

  AuthService() {
    _auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      _updateSessionInPrefs(data.session);
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> _updateSessionInPrefs(Session? session) async {
    final prefs = await SharedPreferences.getInstance();
    if (session != null) {
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', session.user.id);
    } else {
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userId');
    }
  }
  
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signUp(email: email, password: password);
      await _updateSessionInPrefs(response.session);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(email: email, password: password);
      await _updateSessionInPrefs(response.session);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _updateSessionInPrefs(null);
  }
}
