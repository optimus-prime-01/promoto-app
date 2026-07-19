import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService({
    required this._apiService,
    required this._storageService,
  })  : _firebaseAuth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user == null) return null;

    final firebaseToken = await userCredential.user!.getIdToken();
    if (firebaseToken == null) return null;

    return _authenticateWithBackend(firebaseToken);
  }

  Future<UserModel?> _authenticateWithBackend(String firebaseToken) async {
    final response = await _apiService.post(
      ApiConfig.login,
      data: {'firebaseToken': firebaseToken},
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    await _storageService.saveToken(token);

    if (data['refreshToken'] != null) {
      await _storageService.saveRefreshToken(data['refreshToken'] as String);
    }

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
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
    final token = await _storageService.getToken();
    return token != null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await _storageService.clearAll();
  }
}
