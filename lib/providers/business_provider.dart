import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/business_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class BusinessState {
  final bool isLoading;
  final BusinessModel? currentBusiness;
  final List<BusinessModel> businesses;
  final String? error;

  const BusinessState({
    this.isLoading = false,
    this.currentBusiness,
    this.businesses = const [],
    this.error,
  });

  BusinessState copyWith({
    bool? isLoading,
    BusinessModel? currentBusiness,
    List<BusinessModel>? businesses,
    String? error,
  }) {
    return BusinessState(
      isLoading: isLoading ?? this.isLoading,
      currentBusiness: currentBusiness ?? this.currentBusiness,
      businesses: businesses ?? this.businesses,
      error: error,
    );
  }
}

class BusinessNotifier extends StateNotifier<BusinessState> {
  final ApiService _apiService;

  BusinessNotifier(this._apiService) : super(const BusinessState());

  Future<void> fetchBusinesses() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(ApiConfig.businesses);
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }
      final businesses = data
          .map((e) => BusinessModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = BusinessState(
        isLoading: false,
        businesses: businesses,
        currentBusiness: businesses.isNotEmpty ? businesses.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load businesses',
      );
    }
  }

  Future<bool> createBusiness({
    required String name,
    required String category,
    required String city,
    String? phone,
    String? address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final body = <String, dynamic>{
        'name': name,
        'category': category,
        'city': city,
      };
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (address != null && address.isNotEmpty) body['address'] = address;

      final response = await _apiService.post(
        ApiConfig.businesses,
        data: body,
      );

      final business =
          BusinessModel.fromJson(response.data as Map<String, dynamic>);
      state = BusinessState(
        isLoading: false,
        currentBusiness: business,
        businesses: [...state.businesses, business],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create business',
      );
      return false;
    }
  }

  bool get hasBusiness => state.currentBusiness != null;

  String? get businessId => state.currentBusiness?.id;
}

final businessProvider =
    StateNotifierProvider<BusinessNotifier, BusinessState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return BusinessNotifier(apiService);
});
