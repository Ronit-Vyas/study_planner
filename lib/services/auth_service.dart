import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _sessionKey = 'current_user_session';
  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;


  static Future<UserModel?> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_sessionKey);
    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(userJson);
        return _currentUser;
      } catch (_) {
        await prefs.remove(_sessionKey);
      }
    }
    return null;
  }

  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }


    final existing = await UserModel.findByEmail(trimmedEmail);
    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }

    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final passwordHash = _hashPassword(password);
    final now = DateTime.now();

    final userRow = {
      'id': userId,
      'name': trimmedName,
      'email': trimmedEmail,
      'password': passwordHash,
      'created_at': now.millisecondsSinceEpoch,
    };

    await UserModel.insertUser(userRow);

    final user = UserModel(
      id: userId,
      name: trimmedName,
      email: trimmedEmail,
      createdAt: now,
    );


    await _saveSession(user);
    _currentUser = user;
    return user;
  }


  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final userRow = await UserModel.findByEmail(trimmedEmail);

    if (userRow == null) {
      throw Exception('No account found with this email.');
    }

    final expectedHash = _hashPassword(password);
    if (userRow['password'] != expectedHash) {
      throw Exception('Incorrect password. Please try again.');
    }

    final user = UserModel(
      id: userRow['id'] as String,
      name: userRow['name'] as String,
      email: userRow['email'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(userRow['created_at'] as int),
    );

    await _saveSession(user);
    _currentUser = user;
    return user;
  }


  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
  }

  static Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.toJson());
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return crypto.sha256.convert(bytes).toString();
  }
}
