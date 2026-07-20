import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class ScheduledPostsState {
  final bool isLoading;
  final List<PostModel> posts;
  final String? error;

  const ScheduledPostsState({
    this.isLoading = false,
    this.posts = const [],
    this.error,
  });

  ScheduledPostsState copyWith({
    bool? isLoading,
    List<PostModel>? posts,
    String? error,
  }) {
    return ScheduledPostsState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      error: error,
    );
  }
}

class ScheduledPostsNotifier extends StateNotifier<ScheduledPostsState> {
  final ApiService _apiService;
  final Ref _ref;

  ScheduledPostsNotifier(this._apiService, this._ref)
      : super(const ScheduledPostsState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchScheduledPosts() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/businesses/$bid/posts/scheduled');
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }

      final posts = data
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = ScheduledPostsState(posts: posts);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load scheduled posts',
      );
    }
  }

  Future<bool> cancelPost(String postId) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      await _apiService.post('/businesses/$bid/posts/$postId/cancel');
      await fetchScheduledPosts();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePost(
    String postId, {
    String? caption,
    String? scheduledAt,
  }) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      final body = <String, dynamic>{};
      if (caption != null) body['caption'] = caption;
      if (scheduledAt != null) body['scheduledAt'] = scheduledAt;

      await _apiService.patch('/businesses/$bid/posts/$postId', data: body);
      await fetchScheduledPosts();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final scheduledPostsProvider =
    StateNotifierProvider<ScheduledPostsNotifier, ScheduledPostsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ScheduledPostsNotifier(apiService, ref);
});
