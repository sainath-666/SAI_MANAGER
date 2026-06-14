import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../mock/finance_mock.dart';
import '../../data/models/finance_summary.dart';
import '../../data/models/transaction_model.dart';

class FinanceSummaryNotifier extends StateNotifier<AsyncValue<FinanceSummary>> {
  FinanceSummaryNotifier() : super(const AsyncValue.loading()) {
    loadSummary();
  }

  Future<void> loadSummary() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ApiClient.isConfigured) {
        return FinanceSummary.fromJson(mockFinanceSummary);
      }
      final data = await ApiClient().get('/finance/summary');
      return FinanceSummary.fromJson(data);
    });
  }

  void updateSummary(FinanceSummary summary) {
    state = AsyncValue.data(summary);
  }
}

final financeSummaryProvider = StateNotifierProvider<FinanceSummaryNotifier, AsyncValue<FinanceSummary>>((ref) {
  return FinanceSummaryNotifier();
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final Ref _ref;

  TransactionsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ApiClient.isConfigured) {
        return mockTransactionsJson.map((json) => TransactionModel.fromJson(json)).toList();
      }
      final data = await ApiClient().get('/finance/transactions');
      final list = (data['transactions'] as List)
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return list;
    });
  }

  Future<void> addTransaction(TransactionModel tx) async {
    state = await AsyncValue.guard(() async {
      if (ApiClient.isConfigured) {
        final body = {
          'title': tx.title,
          'amount': tx.amount,
          'type': tx.type,
          'category': tx.category,
          'date': tx.date.toIso8601String(),
        };
        final data = await ApiClient().post('/finance/transactions', body);
        final newTx = TransactionModel.fromJson(data['transaction'] as Map<String, dynamic>);
        
        // Refresh summary
        _ref.read(financeSummaryProvider.notifier).loadSummary();
        
        final currentList = state.value ?? [];
        return [newTx, ...currentList];
      }

      final currentList = state.value ?? [];
      final newList = [tx, ...currentList];

      // Update summary dynamically in mock mode!
      final summaryAsync = _ref.read(financeSummaryProvider);
      if (summaryAsync.hasValue) {
        final currentSummary = summaryAsync.value!;
        final isIncome = tx.type == 'income';
        final newBalance = currentSummary.totalBalance + (isIncome ? tx.amount : -tx.amount);
        final newIncome = currentSummary.monthlyIncome + (isIncome ? tx.amount : 0);
        final newExpenses = currentSummary.monthlyExpenses + (isIncome ? 0 : tx.amount);

        // Update Sunday (index 6) or today's weekday in weeklyData for the chart
        final todayWeekday = DateTime.now().weekday - 1; // 0 (Mon) to 6 (Sun)
        final newWeeklyData = List<double>.from(currentSummary.weeklyData);
        if (!isIncome && todayWeekday >= 0 && todayWeekday < 7) {
          newWeeklyData[todayWeekday] += tx.amount;
        }

        _ref.read(financeSummaryProvider.notifier).updateSummary(
          FinanceSummary(
            totalBalance: newBalance,
            monthlyIncome: newIncome,
            monthlyExpenses: newExpenses,
            weeklyData: newWeeklyData,
          ),
        );
      }
      return newList;
    });
  }

  Future<void> deleteTransaction(String id) async {
    state = await AsyncValue.guard(() async {
      if (ApiClient.isConfigured) {
        await ApiClient().delete('/finance/transactions/$id');
        
        // Refresh summary
        _ref.read(financeSummaryProvider.notifier).loadSummary();
        
        final currentList = state.value ?? [];
        return currentList.where((element) => element.id != id).toList();
      }

      final currentList = state.value ?? [];
      final txIndex = currentList.indexWhere((element) => element.id == id);
      if (txIndex == -1) return currentList;

      final tx = currentList[txIndex];
      final newList = currentList.where((element) => element.id != id).toList();

      final summaryAsync = _ref.read(financeSummaryProvider);
      if (summaryAsync.hasValue) {
        final currentSummary = summaryAsync.value!;
        final isIncome = tx.type == 'income';
        final newBalance = currentSummary.totalBalance - (isIncome ? tx.amount : -tx.amount);
        final newIncome = currentSummary.monthlyIncome - (isIncome ? tx.amount : 0);
        final newExpenses = currentSummary.monthlyExpenses - (isIncome ? 0 : tx.amount);

        final todayWeekday = tx.date.weekday - 1;
        final newWeeklyData = List<double>.from(currentSummary.weeklyData);
        if (!isIncome && todayWeekday >= 0 && todayWeekday < 7) {
          newWeeklyData[todayWeekday] = (newWeeklyData[todayWeekday] - tx.amount).clamp(0, double.infinity);
        }

        _ref.read(financeSummaryProvider.notifier).updateSummary(
          FinanceSummary(
            totalBalance: newBalance,
            monthlyIncome: newIncome,
            monthlyExpenses: newExpenses,
            weeklyData: newWeeklyData,
          ),
        );
      }
      return newList;
    });
  }
}

final transactionsListProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  return TransactionsNotifier(ref);
});
