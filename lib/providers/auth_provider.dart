import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      final user = await _authService.getCurrentUser();
      state = AuthState(
        isLoggedIn: user != null,
        user: user,
        isLoading: false,
      );
    } else {
      state = const AuthState(isLoading: false);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        state = AuthState(isLoggedIn: true, user: user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign in was cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign in failed. Please try again.',
      );
    }
  }

  Future<void> sendPhoneOtp(String phoneNumber) async {
    await _authService.sendPhoneOtp(phoneNumber);
  }

  Future<void> verifyPhoneOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.verifyPhoneOtp(otp);
      if (user != null) {
        state = AuthState(isLoggedIn: true, user: user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Verification failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid OTP. Try again.',
      );
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return ApiService(storageService: storageService);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  return AuthService(apiService: apiService, storageService: storageService);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});
