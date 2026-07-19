import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class AutomationSettings {
  final bool autoReplyReviews;
  final bool autoPostSocial;
  final bool autoBirthdayWishes;
  final bool autoWeeklyReport;
  final bool autoFestivalPosts;

  const AutomationSettings({
    this.autoReplyReviews = false,
    this.autoPostSocial = false,
    this.autoBirthdayWishes = false,
    this.autoWeeklyReport = true,
    this.autoFestivalPosts = false,
  });

  factory AutomationSettings.fromJson(Map<String, dynamic> json) {
    return AutomationSettings(
      autoReplyReviews: json['autoReplyReviews'] as bool? ?? false,
      autoPostSocial: json['autoPostSocial'] as bool? ?? false,
      autoBirthdayWishes: json['autoBirthdayWishes'] as bool? ?? false,
      autoWeeklyReport: json['autoWeeklyReport'] as bool? ?? true,
      autoFestivalPosts: json['autoFestivalPosts'] as bool? ?? false,
    );
  }

  AutomationSettings copyWith({
    bool? autoReplyReviews,
    bool? autoPostSocial,
    bool? autoBirthdayWishes,
    bool? autoWeeklyReport,
    bool? autoFestivalPosts,
  }) {
    return AutomationSettings(
      autoReplyReviews: autoReplyReviews ?? this.autoReplyReviews,
      autoPostSocial: autoPostSocial ?? this.autoPostSocial,
      autoBirthdayWishes: autoBirthdayWishes ?? this.autoBirthdayWishes,
      autoWeeklyReport: autoWeeklyReport ?? this.autoWeeklyReport,
      autoFestivalPosts: autoFestivalPosts ?? this.autoFestivalPosts,
    );
  }
}

class AutomationState {
  final bool isLoading;
  final AutomationSettings settings;
  final String? error;

  const AutomationState({
    this.isLoading = false,
    this.settings = const AutomationSettings(),
    this.error,
  });

  AutomationState copyWith({
    bool? isLoading,
    AutomationSettings? settings,
    String? error,
  }) {
    return AutomationState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      error: error,
    );
  }
}

class AutomationNotifier extends StateNotifier<AutomationState> {
  final ApiService _apiService;
  final Ref _ref;

  AutomationNotifier(this._apiService, this._ref)
      : super(const AutomationState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchSettings() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/businesses/$bid/automation');
      final data = response.data as Map<String, dynamic>;
      state = AutomationState(
        settings: AutomationSettings.fromJson(data),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load automation settings',
      );
    }
  }

  Future<void> updateSetting(String key, bool value) async {
    final bid = _businessId;
    if (bid == null) return;

    // Optimistic update
    final oldSettings = state.settings;
    final newSettings = _applyUpdate(oldSettings, key, value);
    state = state.copyWith(settings: newSettings);

    try {
      await _apiService.patch(
        '/businesses/$bid/automation',
        data: {key: value},
      );
    } catch (e) {
      // Revert on failure
      state = state.copyWith(settings: oldSettings);
    }
  }

  AutomationSettings _applyUpdate(
      AutomationSettings settings, String key, bool value) {
    switch (key) {
      case 'autoReplyReviews':
        return settings.copyWith(autoReplyReviews: value);
      case 'autoPostSocial':
        return settings.copyWith(autoPostSocial: value);
      case 'autoBirthdayWishes':
        return settings.copyWith(autoBirthdayWishes: value);
      case 'autoWeeklyReport':
        return settings.copyWith(autoWeeklyReport: value);
      case 'autoFestivalPosts':
        return settings.copyWith(autoFestivalPosts: value);
      default:
        return settings;
    }
  }
}

final automationProvider =
    StateNotifierProvider<AutomationNotifier, AutomationState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AutomationNotifier(apiService, ref);
});
