import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/social_account_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class SocialAccountsState {
  final bool isLoading;
  final List<SocialAccountModel> accounts;
  final String? error;

  const SocialAccountsState({
    this.isLoading = false,
    this.accounts = const [],
    this.error,
  });

  SocialAccountsState copyWith({
    bool? isLoading,
    List<SocialAccountModel>? accounts,
    String? error,
  }) {
    return SocialAccountsState(
      isLoading: isLoading ?? this.isLoading,
      accounts: accounts ?? this.accounts,
      error: error,
    );
  }

  SocialAccountModel? getInstagramAccount() {
    try {
      return accounts.firstWhere(
        (a) => a.platform == 'instagram' && a.isConnected,
      );
    } catch (_) {
      return null;
    }
  }

  bool get isInstagramConnected => getInstagramAccount() != null;

  SocialAccountModel? getFacebookAccount() {
    try {
      return accounts.firstWhere(
        (a) => a.platform == 'facebook' && a.isConnected,
      );
    } catch (_) {
      return null;
    }
  }

  bool get isFacebookConnected => getFacebookAccount() != null;
}

class SocialAccountsNotifier extends StateNotifier<SocialAccountsState> {
  final ApiService _apiService;
  final Ref _ref;

  SocialAccountsNotifier(this._apiService, this._ref)
      : super(const SocialAccountsState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchAccounts([String? businessId]) async {
    final bid = businessId ?? _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response =
          await _apiService.get('/businesses/$bid/social-accounts');
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }

      final accounts = data
          .map((e) => SocialAccountModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = SocialAccountsState(accounts: accounts);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load connected accounts',
      );
    }
  }

  Future<bool> connectInstagram([String? businessId]) async {
    final bid = businessId ?? _businessId;
    if (bid == null) return false;

    try {
      final response = await _apiService
          .post('/businesses/$bid/social-accounts/instagram/connect');
      final data = response.data as Map<String, dynamic>;
      final authUrl = data['authUrl'] as String?;

      if (authUrl != null && authUrl.isNotEmpty) {
        final uri = Uri.parse(authUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to start Instagram connection');
      return false;
    }
  }

  Future<bool> connectFacebook([String? businessId]) async {
    final bid = businessId ?? _businessId;
    if (bid == null) return false;

    try {
      final response = await _apiService
          .post('/businesses/$bid/social-accounts/facebook/connect');
      final data = response.data as Map<String, dynamic>;
      final authUrl = data['authUrl'] as String?;

      if (authUrl != null && authUrl.isNotEmpty) {
        final uri = Uri.parse(authUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to start Facebook connection');
      return false;
    }
  }

  Future<Map<String, dynamic>?> checkWhatsappStatus([
    String? businessId,
  ]) async {
    final bid = businessId ?? _businessId;
    if (bid == null) return null;

    try {
      final response = await _apiService
          .post('/businesses/$bid/social-accounts/whatsapp/status');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      state = state.copyWith(error: 'Failed to check WhatsApp status');
      return null;
    }
  }

  Future<bool> disconnectAccount(String accountId) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      await _apiService
          .delete('/businesses/$bid/social-accounts/$accountId');
      await fetchAccounts();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to disconnect account');
      return false;
    }
  }
}

final socialAccountsProvider =
    StateNotifierProvider<SocialAccountsNotifier, SocialAccountsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return SocialAccountsNotifier(apiService, ref);
});
