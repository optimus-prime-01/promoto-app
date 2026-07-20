import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class CommentsState {
  final bool isLoading;
  final List<CommentModel> comments;
  final String? error;

  const CommentsState({
    this.isLoading = false,
    this.comments = const [],
    this.error,
  });

  CommentsState copyWith({
    bool? isLoading,
    List<CommentModel>? comments,
    String? error,
  }) {
    return CommentsState(
      isLoading: isLoading ?? this.isLoading,
      comments: comments ?? this.comments,
      error: error,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  final ApiService _apiService;
  final Ref _ref;

  CommentsNotifier(this._apiService, this._ref)
      : super(const CommentsState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchComments() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/businesses/$bid/comments');
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }

      final comments = data
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = CommentsState(comments: comments);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load comments',
      );
    }
  }

  Future<String?> generateReply(String commentId) async {
    final bid = _businessId;
    if (bid == null) return null;

    try {
      final response = await _apiService.post(
        '/businesses/$bid/comments/$commentId/generate-reply',
      );
      final data = response.data as Map<String, dynamic>;
      final reply = data['suggestedReply'] as String?;

      if (reply != null) {
        final updated = state.comments.map((c) {
          if (c.id == commentId) {
            return c.copyWith(aiSuggestedReply: reply);
          }
          return c;
        }).toList();
        state = state.copyWith(comments: updated);
      }

      return reply;
    } catch (e) {
      return null;
    }
  }

  Future<bool> postReply(String commentId, String text) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      await _apiService.post(
        '/businesses/$bid/comments/$commentId/reply',
        data: {'replyText': text},
      );
      await fetchComments();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final commentsProvider =
    StateNotifierProvider<CommentsNotifier, CommentsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return CommentsNotifier(apiService, ref);
});
