import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/audit_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'business_provider.dart';

class AuditState {
  final bool isLoading;
  final bool isRunning;
  final AuditModel? latestAudit;
  final List<AuditModel> auditHistory;
  final String? error;

  const AuditState({
    this.isLoading = false,
    this.isRunning = false,
    this.latestAudit,
    this.auditHistory = const [],
    this.error,
  });

  AuditState copyWith({
    bool? isLoading,
    bool? isRunning,
    AuditModel? latestAudit,
    List<AuditModel>? auditHistory,
    String? error,
  }) {
    return AuditState(
      isLoading: isLoading ?? this.isLoading,
      isRunning: isRunning ?? this.isRunning,
      latestAudit: latestAudit ?? this.latestAudit,
      auditHistory: auditHistory ?? this.auditHistory,
      error: error,
    );
  }
}

class AuditNotifier extends StateNotifier<AuditState> {
  final ApiService _apiService;
  final Ref _ref;

  AuditNotifier(this._apiService, this._ref) : super(const AuditState());

  String? get _businessId => _ref.read(businessProvider).currentBusiness?.id;

  Future<void> fetchAudits() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/businesses/$bid/audits');
      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }

      final audits = data
          .map((e) => AuditModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AuditState(
        isLoading: false,
        auditHistory: audits,
        latestAudit: audits.isNotEmpty ? audits.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load audit history',
      );
    }
  }

  Future<void> runAudit() async {
    final bid = _businessId;
    if (bid == null) return;

    state = state.copyWith(isRunning: true, error: null);

    try {
      final response = await _apiService.post('/businesses/$bid/audits');
      final audit =
          AuditModel.fromJson(response.data as Map<String, dynamic>);

      state = AuditState(
        isRunning: false,
        latestAudit: audit,
        auditHistory: [audit, ...state.auditHistory],
      );
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
        error: 'Failed to run audit. Please try again.',
      );
    }
  }
}

final auditProvider =
    StateNotifierProvider<AuditNotifier, AuditState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuditNotifier(apiService, ref);
});
