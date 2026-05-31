const List<Map<String, dynamic>> mockTransactionsJson = [
  {
    'id': 'tx-1',
    'title': 'Client UI Milestone payout',
    'amount': 2500.0,
    'type': 'income',
    'category': 'Freelance',
    'date': '2026-05-25T10:00:00Z',
  },
  {
    'id': 'tx-2',
    'title': 'AWS Cloud Hosting Fees',
    'amount': 65.0,
    'type': 'expense',
    'category': 'Developer',
    'date': '2026-05-28T14:30:00Z',
  },
  {
    'id': 'tx-3',
    'title': 'Ergonomic Developer Chair',
    'amount': 350.0,
    'type': 'expense',
    'category': 'Office Work',
    'date': '2026-05-29T09:15:00Z',
  },
  {
    'id': 'tx-4',
    'title': 'Freelance Consulting Payment',
    'amount': 1200.0,
    'type': 'income',
    'category': 'Freelance',
    'date': '2026-05-30T08:00:00Z',
  },
  {
    'id': 'tx-5',
    'title': 'Gym Membership Renewal',
    'amount': 50.0,
    'type': 'expense',
    'category': 'Goals',
    'date': '2026-05-31T09:00:00Z',
  }
];

const Map<String, dynamic> mockFinanceSummary = {
  'totalBalance': 12450.0,
  'monthlyIncome': 3700.0,
  'monthlyExpenses': 465.0,
  'weeklyData': [0.0, 0.0, 0.0, 65.0, 350.0, 0.0, 50.0], // Mon-Sun expense chart data
};
