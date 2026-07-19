import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class KeywordsState {
  final bool isLoading;
  final List<String> keywords;
  final String? error;

  const KeywordsState({
    this.isLoading = false,
    this.keywords = const [],
    this.error,
  });

  KeywordsState copyWith({
    bool? isLoading,
    List<String>? keywords,
    String? error,
  }) {
    return KeywordsState(
      isLoading: isLoading ?? this.isLoading,
      keywords: keywords ?? this.keywords,
      error: error,
    );
  }
}

class KeywordsNotifier extends StateNotifier<KeywordsState> {
  final ApiService _apiService;
  final Ref _ref;

  KeywordsNotifier(this._apiService, this._ref) : super(const KeywordsState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> generateKeywords({String? category, String? city}) async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final body = <String, dynamic>{};
      if (category != null && category.isNotEmpty) body['category'] = category;
      if (city != null && city.isNotEmpty) body['city'] = city;

      final response = await _apiService.post(
        '/businesses/$bid/keywords',
        data: body,
      );

      final data = response.data as Map<String, dynamic>;
      final keywords = (data['keywords'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      state = KeywordsState(
        isLoading: false,
        keywords: keywords,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate keywords. Please try again.',
      );
    }
  }
}

final keywordsProvider =
    StateNotifierProvider<KeywordsNotifier, KeywordsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return KeywordsNotifier(apiService, ref);
});
