import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class SubscriptionState {
  final bool isLoading;
  final String? currentPlan;
  final String? subscriptionId;
  final String? error;
  final bool isUpgrading;

  const SubscriptionState({
    this.isLoading = false,
    this.currentPlan,
    this.subscriptionId,
    this.error,
    this.isUpgrading = false,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    String? currentPlan,
    String? subscriptionId,
    String? error,
    bool? isUpgrading,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      currentPlan: currentPlan ?? this.currentPlan,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      error: error,
      isUpgrading: isUpgrading ?? this.isUpgrading,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ApiService _apiService;

  SubscriptionNotifier(this._apiService) : super(const SubscriptionState());

  Future<void> fetchCurrentSubscription() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(ApiConfig.subscription);
      final data = response.data is Map ? response.data as Map<String, dynamic> : <String, dynamic>{};
      final subData = data['data'] is Map ? data['data'] as Map<String, dynamic> : data;

      state = SubscriptionState(
        isLoading: false,
        currentPlan: subData['plan'] as String? ?? 'free',
        subscriptionId: subData['id']?.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        currentPlan: 'free',
        error: null,
      );
    }
  }

  Future<Map<String, dynamic>?> createSubscription(String plan) async {
    state = state.copyWith(isUpgrading: true, error: null);

    try {
      final response = await _apiService.post(
        ApiConfig.subscription,
        data: {'plan': plan},
      );
      final data = response.data is Map ? response.data as Map<String, dynamic> : <String, dynamic>{};
      final subData = data['data'] is Map ? data['data'] as Map<String, dynamic> : data;

      state = state.copyWith(
        isUpgrading: false,
        currentPlan: plan,
        subscriptionId: subData['id']?.toString(),
      );
      return subData;
    } catch (e) {
      state = state.copyWith(
        isUpgrading: false,
        error: 'Failed to create subscription',
      );
      return null;
    }
  }

  Future<bool> cancelSubscription() async {
    if (state.subscriptionId == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.post(
        '${ApiConfig.subscription}/${state.subscriptionId}/cancel',
      );
      state = SubscriptionState(
        isLoading: false,
        currentPlan: 'free',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to cancel subscription',
      );
      return false;
    }
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return SubscriptionNotifier(apiService);
});
