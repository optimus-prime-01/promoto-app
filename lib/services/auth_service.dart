import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user == null) return null;

      final firebaseToken = await userCredential.user!.getIdToken();
      if (firebaseToken == null) return null;

      return _authenticateWithBackend(firebaseToken);
    } catch (e) {
      debugPrint('Google sign in failed: $e');
      return null;
    }
  }

  Future<UserModel?> _authenticateWithBackend(String firebaseToken) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {'firebaseToken': firebaseToken},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['accessToken'] as String;
      await _storageService.saveToken(token);

      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Backend auth failed: $e');
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await _storageService.getToken();
    if (token == null) return null;

    try {
      final response = await _apiService.get(ApiConfig.me);
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final token = await _storageService.getToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // ignore firebase signout errors
    }
    await _storageService.clearAll();
  }
}
