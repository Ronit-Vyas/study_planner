import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  // Firebase Authentication instance
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Local representation of the logged-in user
  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;

  // Firebase User
  static User? get firebaseUser => _auth.currentUser;

  // Check whether Firebase has a logged-in user
  static bool get isLoggedIn => _auth.currentUser != null;

  static Future<UserModel?> init() async {
    // Firebase automatically restores the authentication session.
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      _currentUser = null;
      return null;
    }

    // Try to find the user's local profile using Firebase UID
    final localUser = await UserModel.findById(
      firebaseUser.uid,
    );

    if (localUser != null) {
      _currentUser = UserModel.fromMap(localUser);

      return _currentUser;
    }


    final name =
        firebaseUser.displayName ??
            firebaseUser.email?.split('@').first ??
            'User';

    final user = UserModel(
      id: firebaseUser.uid,
      name: name,
      email: firebaseUser.email ?? '',
    );

    await UserModel.insertUser(
      user.toMap(),
    );

    _currentUser = user;

    return user;
  }


  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim().toLowerCase();


    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }

    if (trimmedEmail.isEmpty ||
        !trimmedEmail.contains('@')) {
      throw Exception(
        'Please enter a valid email address.',
      );
    }

    if (password.length < 6) {
      throw Exception(
        'Password must be at least 6 characters.',
      );
    }


    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception(
        'Unable to create account.',
      );
    }


    await firebaseUser.updateDisplayName(
      trimmedName,
    );


    final user = UserModel(
      id: firebaseUser.uid,
      name: trimmedName,
      email: firebaseUser.email ?? trimmedEmail,
    );

    await UserModel.insertUser(
      user.toMap(),
    );

    // Update local state
    _currentUser = user;

    return user;
  }


  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty) {
      throw Exception(
        'Please enter your email address.',
      );
    }

    if (password.isEmpty) {
      throw Exception(
        'Please enter your password.',
      );
    }


    final credential =
    await _auth.signInWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Login failed.');
    }


    final localUser = await UserModel.findById(
      firebaseUser.uid,
    );

    if (localUser != null) {
      _currentUser = UserModel.fromMap(
        localUser,
      );

      return _currentUser!;
    }

    final name =
        firebaseUser.displayName ??
            firebaseUser.email?.split('@').first ??
            'User';

    final user = UserModel(
      id: firebaseUser.uid,
      name: name,
      email: firebaseUser.email ?? trimmedEmail,
    );

    await UserModel.insertUser(
      user.toMap(),
    );

    _currentUser = user;

    return user;
  }


  static Future<void> logout() async {
    // Firebase handles the authentication session.
    await _auth.signOut();

    // Clear local in-memory user
    _currentUser = null;
  }

  static Future<void> updateName(
      String newName,
      ) async {
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) {
      throw Exception(
        'Name cannot be empty.',
      );
    }

    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    // Update Firebase profile
    await firebaseUser.updateDisplayName(
      trimmedName,
    );

    // Update local profile
    await UserModel.updateUser(
      firebaseUser.uid,
      {
        'name': trimmedName,
      },
    );

    // Update in-memory user
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: trimmedName,
        email: _currentUser!.email,
        createdAt: _currentUser!.createdAt,
      );
    }
  }
}