import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../mock/finance_mock.dart';
import '../../data/models/finance_summary.dart';

final financeSummaryProvider = FutureProvider<FinanceSummary>((ref) async {
  if (!ApiClient.isConfigured) {
    return FinanceSummary.fromJson(mockFinanceSummary);
  }

  final data = await ApiClient().get('/finance/summary');
  return FinanceSummary.fromJson(data);
});
