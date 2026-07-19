import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class ReviewsState {
  final bool isLoading;
  final List<ReviewModel> reviews;
  final String? error;
  final String? generatingReplyForId;

  const ReviewsState({
    this.isLoading = false,
    this.reviews = const [],
    this.error,
    this.generatingReplyForId,
  });

  ReviewsState copyWith({
    bool? isLoading,
    List<ReviewModel>? reviews,
    String? error,
    String? generatingReplyForId,
  }) {
    return ReviewsState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      error: error,
      generatingReplyForId: generatingReplyForId,
    );
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  int get totalReviews => reviews.length;

  double get responseRate {
    if (reviews.isEmpty) return 0;
    final replied = reviews.where((r) => r.hasReply).length;
    return (replied / reviews.length) * 100;
  }
}

class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final ApiService _apiService;
  final Ref _ref;

  ReviewsNotifier(this._apiService, this._ref) : super(const ReviewsState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchReviews() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/businesses/$bid/reviews');
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }

      final reviews = data
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = ReviewsState(reviews: reviews);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reviews',
      );
    }
  }

  Future<String?> generateAiReply(String reviewId) async {
    final bid = _businessId;
    if (bid == null) return null;

    state = state.copyWith(generatingReplyForId: reviewId);

    try {
      final response = await _apiService.post(
        '/businesses/$bid/reviews/$reviewId/generate-reply',
      );

      final reply = response.data is Map
          ? (response.data['reply'] as String? ??
              response.data['aiSuggestedReply'] as String? ??
              response.data.toString())
          : response.data.toString();

      // Update the review in local state
      final updatedReviews = state.reviews.map((r) {
        if (r.id == reviewId) {
          return ReviewModel(
            id: r.id,
            businessId: r.businessId,
            reviewerName: r.reviewerName,
            rating: r.rating,
            text: r.text,
            replyText: r.replyText,
            repliedAt: r.repliedAt,
            aiSuggestedReply: reply,
            createdAt: r.createdAt,
          );
        }
        return r;
      }).toList();

      state = ReviewsState(reviews: updatedReviews);
      return reply;
    } catch (e) {
      state = state.copyWith(generatingReplyForId: null);
      return null;
    }
  }

  Future<bool> postReply(String reviewId, String replyText) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      await _apiService.post(
        '/businesses/$bid/reviews/$reviewId/reply',
        data: {'replyText': replyText},
      );

      // Update local state
      final updatedReviews = state.reviews.map((r) {
        if (r.id == reviewId) {
          return ReviewModel(
            id: r.id,
            businessId: r.businessId,
            reviewerName: r.reviewerName,
            rating: r.rating,
            text: r.text,
            replyText: replyText,
            repliedAt: DateTime.now(),
            aiSuggestedReply: r.aiSuggestedReply,
            createdAt: r.createdAt,
          );
        }
        return r;
      }).toList();

      state = ReviewsState(reviews: updatedReviews);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, ReviewsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ReviewsNotifier(apiService, ref);
});
