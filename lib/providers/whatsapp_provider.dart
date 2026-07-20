import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class WhatsappMessage {
  final String id;
  final String businessId;
  final String type;
  final String message;
  final String targetAudience;
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final String status;
  final int recipientCount;
  final DateTime createdAt;

  const WhatsappMessage({
    required this.id,
    required this.businessId,
    required this.type,
    required this.message,
    required this.targetAudience,
    required this.scheduledAt,
    this.sentAt,
    required this.status,
    required this.recipientCount,
    required this.createdAt,
  });

  factory WhatsappMessage.fromJson(Map<String, dynamic> json) {
    return WhatsappMessage(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      type: json['type'] as String? ?? 'broadcast',
      message: json['message'] as String? ?? '',
      targetAudience: json['targetAudience'] as String? ?? 'all_customers',
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : DateTime.now(),
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      status: json['status'] as String? ?? 'scheduled',
      recipientCount: json['recipientCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String get typeDisplay {
    switch (type) {
      case 'broadcast':
        return 'Broadcast';
      case 'birthday':
        return 'Birthday';
      case 'festival':
        return 'Festival';
      case 'offer':
        return 'Offer';
      default:
        return type;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'sent':
        return 'Sent';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class WhatsappSettings {
  final String id;
  final String businessId;
  final bool birthdayOfferEnabled;
  final int birthdayOfferPercent;
  final String birthdayMessage;
  final bool festivalAutoPost;
  final bool broadcastEnabled;

  const WhatsappSettings({
    required this.id,
    required this.businessId,
    required this.birthdayOfferEnabled,
    required this.birthdayOfferPercent,
    required this.birthdayMessage,
    required this.festivalAutoPost,
    required this.broadcastEnabled,
  });

  factory WhatsappSettings.fromJson(Map<String, dynamic> json) {
    return WhatsappSettings(
      id: json['id'] as String? ?? '',
      businessId: json['businessId'] as String? ?? '',
      birthdayOfferEnabled: json['birthdayOfferEnabled'] as bool? ?? true,
      birthdayOfferPercent: json['birthdayOfferPercent'] as int? ?? 10,
      birthdayMessage: json['birthdayMessage'] as String? ??
          'Happy Birthday! Enjoy {percent}% off on your next visit at {business_name}',
      festivalAutoPost: json['festivalAutoPost'] as bool? ?? true,
      broadcastEnabled: json['broadcastEnabled'] as bool? ?? true,
    );
  }
}

class WhatsappState {
  final bool isLoading;
  final List<WhatsappMessage> messages;
  final WhatsappSettings? settings;
  final String? error;

  const WhatsappState({
    this.isLoading = false,
    this.messages = const [],
    this.settings,
    this.error,
  });

  WhatsappState copyWith({
    bool? isLoading,
    List<WhatsappMessage>? messages,
    WhatsappSettings? settings,
    String? error,
  }) {
    return WhatsappState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      settings: settings ?? this.settings,
      error: error,
    );
  }
}

class WhatsappNotifier extends StateNotifier<WhatsappState> {
  final ApiService _apiService;
  final Ref _ref;

  WhatsappNotifier(this._apiService, this._ref) : super(const WhatsappState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchMessages() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response =
          await _apiService.get('/businesses/$bid/whatsapp/messages');
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }

      final messages = data
          .map((e) => WhatsappMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(isLoading: false, messages: messages);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load WhatsApp messages',
      );
    }
  }

  Future<bool> createMessage({
    required String type,
    required String message,
    required String targetAudience,
    required String scheduledAt,
  }) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      await _apiService.post(
        '/businesses/$bid/whatsapp/messages',
        data: {
          'type': type,
          'message': message,
          'targetAudience': targetAudience,
          'scheduledAt': scheduledAt,
        },
      );
      await fetchMessages();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelMessage(String messageId) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      await _apiService
          .post('/businesses/$bid/whatsapp/messages/$messageId/cancel');
      await fetchMessages();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchSettings() async {
    final bid = _businessId;
    if (bid == null) return;

    try {
      final response =
          await _apiService.get('/businesses/$bid/whatsapp/settings');
      final data = response.data as Map<String, dynamic>;
      final settings = WhatsappSettings.fromJson(data);
      state = state.copyWith(settings: settings);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load WhatsApp settings');
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> settingsData) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      final response = await _apiService.patch(
        '/businesses/$bid/whatsapp/settings',
        data: settingsData,
      );
      final data = response.data as Map<String, dynamic>;
      final settings = WhatsappSettings.fromJson(data);
      state = state.copyWith(settings: settings);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final whatsappProvider =
    StateNotifierProvider<WhatsappNotifier, WhatsappState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return WhatsappNotifier(apiService, ref);
});
