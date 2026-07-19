import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class PostsState {
  final bool isLoading;
  final bool isGenerating;
  final List<PostModel> posts;
  final String? error;
  final String? generatedCaption;
  final String? generatedImageUrl;

  const PostsState({
    this.isLoading = false,
    this.isGenerating = false,
    this.posts = const [],
    this.error,
    this.generatedCaption,
    this.generatedImageUrl,
  });

  PostsState copyWith({
    bool? isLoading,
    bool? isGenerating,
    List<PostModel>? posts,
    String? error,
    String? generatedCaption,
    String? generatedImageUrl,
  }) {
    return PostsState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      posts: posts ?? this.posts,
      error: error,
      generatedCaption: generatedCaption ?? this.generatedCaption,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  final ApiService _apiService;
  final Ref _ref;

  PostsNotifier(this._apiService, this._ref) : super(const PostsState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchPosts() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/businesses/$bid/posts');
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

      state = PostsState(posts: posts);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load posts',
      );
    }
  }

  Future<void> generatePost(String topic) async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isGenerating: true, error: null);

    try {
      final response = await _apiService.post(
        '/businesses/$bid/posts/generate',
        data: {'topic': topic},
      );

      final data = response.data as Map<String, dynamic>;
      state = state.copyWith(
        isGenerating: false,
        generatedCaption: data['caption'] as String? ?? data['content'] as String?,
        generatedImageUrl: data['imageUrl'] as String?,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate post content',
      );
    }
  }

  void clearGenerated() {
    state = PostsState(posts: state.posts);
  }

  Future<bool> createPost({
    required String caption,
    String? imageUrl,
    required String platform,
    required String status,
  }) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      final body = <String, dynamic>{
        'caption': caption,
        'platform': platform,
        'status': status,
      };
      if (imageUrl != null) body['imageUrl'] = imageUrl;

      await _apiService.post('/businesses/$bid/posts', data: body);
      await fetchPosts();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> publishPost(String postId) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      await _apiService.post('/businesses/$bid/posts/$postId/publish');
      await fetchPosts();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final postsProvider =
    StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PostsNotifier(apiService, ref);
});
