import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class CompetitorModel {
  final String name;
  final double rating;
  final int reviewCount;
  final double distance;
  final String category;

  const CompetitorModel({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.category,
  });

  factory CompetitorModel.fromJson(Map<String, dynamic> json) {
    return CompetitorModel(
      name: json['name'] as String? ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
      distance: double.tryParse(json['distance']?.toString() ?? '0') ?? 0,
      category: json['category'] as String? ?? '',
    );
  }
}

class CompetitorsState {
  final bool isLoading;
  final List<CompetitorModel> competitors;
  final String? error;
  final int radius;

  const CompetitorsState({
    this.isLoading = false,
    this.competitors = const [],
    this.error,
    this.radius = 5000,
  });

  CompetitorsState copyWith({
    bool? isLoading,
    List<CompetitorModel>? competitors,
    String? error,
    int? radius,
  }) {
    return CompetitorsState(
      isLoading: isLoading ?? this.isLoading,
      competitors: competitors ?? this.competitors,
      error: error,
      radius: radius ?? this.radius,
    );
  }
}

class CompetitorsNotifier extends StateNotifier<CompetitorsState> {
  final ApiService _apiService;
  final Ref _ref;

  CompetitorsNotifier(this._apiService, this._ref)
      : super(const CompetitorsState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  void setRadius(int radius) {
    state = state.copyWith(radius: radius);
  }

  Future<void> analyzeCompetitors() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        '/businesses/$bid/competitors',
        data: {'radius': state.radius},
      );

      final data = response.data as Map<String, dynamic>;
      final competitorsList = (data['competitors'] as List<dynamic>)
          .map((e) => CompetitorModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        competitors: competitorsList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to analyze competitors. Please try again.',
      );
    }
  }
}

final competitorsProvider =
    StateNotifierProvider<CompetitorsNotifier, CompetitorsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return CompetitorsNotifier(apiService, ref);
});
