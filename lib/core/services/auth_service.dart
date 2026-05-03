import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Auth state
enum AuthState { unknown, loggedOut, loggedIn, loading }

// User model
class NovaUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime loginTime;
  
  NovaUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.loginTime,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'loginTime': loginTime.toIso8601String(),
  };
  
  factory NovaUser.fromJson(Map<String, dynamic> json) => NovaUser(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    photoUrl: json['photoUrl'],
    loginTime: DateTime.parse(json['loginTime']),
  );
}

// Authentication service - simulates Firebase Auth for demo
// In production, connect to real Firebase
class AuthService {
  static const String _userKey = 'nova_user';
  static const String _loginTimeKey = 'nova_login_time';
  
  NovaUser? _currentUser;
  AuthState _state = AuthState.unknown;
  
  NovaUser? get currentUser => _currentUser;
  AuthState get state => _state;
  bool get isLoggedIn => _state == AuthState.loggedIn && _currentUser != null;
  
  // Initialize - check for existing session
  Future<void> init() async {
    _state = AuthState.loading;
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        _currentUser = NovaUser.fromJson(jsonDecode(userJson));
        _state = AuthState.loggedIn;
      } catch (e) {
        _state = AuthState.loggedOut;
      }
    } else {
      _state = AuthState.loggedOut;
    }
  }
  
  // Sign in with Google - in production use Firebase Google Sign-In
  Future<bool> signInWithGoogle() async {
    _state = AuthState.loading;
    
    try {
      // Simulate Google Sign-In delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Create demo user - in production this comes from Firebase
      _currentUser = NovaUser(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        name: 'NOVA User',
        photoUrl: null,
        loginTime: DateTime.now(),
      );
      
      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      _state = AuthState.loggedIn;
      return true;
    } catch (e) {
      _state = AuthState.loggedOut;
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    _state = AuthState.loading;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_loginTimeKey);
    
    _currentUser = null;
    _state = AuthState.loggedOut;
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    await signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}