import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class CustomersState {
  final bool isLoading;
  final List<CustomerModel> customers;
  final String? error;
  final int totalCustomers;
  final int upcomingBirthdays;

  const CustomersState({
    this.isLoading = false,
    this.customers = const [],
    this.error,
    this.totalCustomers = 0,
    this.upcomingBirthdays = 0,
  });

  CustomersState copyWith({
    bool? isLoading,
    List<CustomerModel>? customers,
    String? error,
    int? totalCustomers,
    int? upcomingBirthdays,
  }) {
    return CustomersState(
      isLoading: isLoading ?? this.isLoading,
      customers: customers ?? this.customers,
      error: error,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      upcomingBirthdays: upcomingBirthdays ?? this.upcomingBirthdays,
    );
  }
}

class CustomersNotifier extends StateNotifier<CustomersState> {
  final ApiService _apiService;
  final Ref _ref;

  CustomersNotifier(this._apiService, this._ref)
      : super(const CustomersState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchCustomers() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/businesses/$bid/customers');
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }

      final customers = data
          .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = CustomersState(
        customers: customers,
        totalCustomers: customers.length,
      );

      // Fetch stats separately
      _fetchStats(bid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load customers',
      );
    }
  }

  Future<void> _fetchStats(String bid) async {
    try {
      final birthdayResponse =
          await _apiService.get('/businesses/$bid/customers/upcoming-birthdays');
      final List<dynamic> birthdays;
      if (birthdayResponse.data is List) {
        birthdays = birthdayResponse.data as List<dynamic>;
      } else if (birthdayResponse.data is Map &&
          birthdayResponse.data['data'] != null) {
        birthdays = birthdayResponse.data['data'] as List<dynamic>;
      } else {
        birthdays = [];
      }
      state = state.copyWith(upcomingBirthdays: birthdays.length);
    } catch (_) {
      // Stats are non-critical, ignore errors
    }
  }

  Future<bool> addCustomer({
    required String phone,
    String? name,
    String? dateOfBirth,
  }) async {
    final bid = _businessId;
    if (bid == null) return false;

    try {
      final body = <String, dynamic>{'phone': phone};
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;

      await _apiService.post('/businesses/$bid/customers', data: body);
      await fetchCustomers();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final customersProvider =
    StateNotifierProvider<CustomersNotifier, CustomersState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return CustomersNotifier(apiService, ref);
});
