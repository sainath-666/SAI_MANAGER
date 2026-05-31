class FinanceSummary {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<double> weeklyData;

  const FinanceSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.weeklyData,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalBalance: (json['totalBalance'] as num).toDouble(),
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] as num).toDouble(),
      weeklyData: (json['weeklyData'] as List<dynamic>)
          .map((value) => (value as num).toDouble())
          .toList(),
    );
  }
}
