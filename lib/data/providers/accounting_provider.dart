import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/accounting_entry_model.dart';
import '../models/budget_model.dart';
import '../models/financial_report_model.dart';
import '../mock/accounting_mock_data.dart';

class AccountingProvider extends ChangeNotifier {
  // State
  bool _isLoading = false;
  List<AccountModel> _accounts = [];
  List<AccountingEntryModel> _entries = [];
  List<BudgetModel> _budgets = [];
  List<FinancialReportModel> _reports = [];

  // Filters
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  EntryType? _filterEntryType;
  String? _filterAccountId;

  // Getters
  bool get isLoading => _isLoading;
  List<AccountModel> get accounts => _accounts;
  List<AccountingEntryModel> get entries => _entries;
  List<BudgetModel> get budgets => _budgets;
  List<FinancialReportModel> get reports => _reports;

  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  EntryType? get filterEntryType => _filterEntryType;
  String? get filterAccountId => _filterAccountId;

  // Computed getters
  List<AccountModel> get parentAccounts =>
      _accounts.where((a) => a.isParent).toList();

  List<AccountModel> get incomeAccounts =>
      _accounts.where((a) => a.type == AccountType.income).toList();

  List<AccountModel> get expenseAccounts =>
      _accounts.where((a) => a.type == AccountType.expense).toList();

  List<AccountingEntryModel> get filteredEntries {
    var filtered = _entries;

    if (_filterStartDate != null) {
      filtered = filtered
          .where(
            (e) => e.transactionDate.isAfter(
              _filterStartDate!.subtract(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    if (_filterEndDate != null) {
      filtered = filtered
          .where(
            (e) => e.transactionDate.isBefore(
              _filterEndDate!.add(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    if (_filterEntryType != null) {
      filtered = filtered
          .where((e) => e.entryType == _filterEntryType)
          .toList();
    }

    if (_filterAccountId != null) {
      filtered = filtered
          .where((e) => e.accountId == _filterAccountId)
          .toList();
    }

    return filtered;
  }

  List<AccountingEntryModel> get incomeEntries =>
      _entries.where((e) => e.entryType == EntryType.income).toList();

  List<AccountingEntryModel> get expenseEntries =>
      _entries.where((e) => e.entryType == EntryType.expense).toList();

  double get totalIncome =>
      incomeEntries.fold(0.0, (sum, entry) => sum + entry.amount);

  double get totalExpense =>
      expenseEntries.fold(0.0, (sum, entry) => sum + entry.amount);

  double get netIncome => totalIncome - totalExpense;

  BudgetModel? get activeBudget => _budgets.firstWhere(
    (b) => b.status == BudgetStatus.active,
    orElse: () => _budgets.isNotEmpty ? _budgets.first : _budgets.first,
  );

  /// Initialize accounting data
  Future<void> loadAccountingData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _accounts = AccountingMockData.getChartOfAccounts();
    _entries = AccountingMockData.getAccountingEntries();
    _budgets = AccountingMockData.getBudgets();
    _reports = AccountingMockData.getFinancialReports();

    _isLoading = false;
    notifyListeners();
  }

  /// Get child accounts of a parent account
  List<AccountModel> getChildAccounts(String parentId) {
    return _accounts.where((a) => a.parentId == parentId).toList();
  }

  /// Get account by ID
  AccountModel? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get account by code
  AccountModel? getAccountByCode(String code) {
    try {
      return _accounts.firstWhere((a) => a.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get entries for an account
  List<AccountingEntryModel> getEntriesForAccount(String accountId) {
    return _entries.where((e) => e.accountId == accountId).toList();
  }

  /// Add new accounting entry
  Future<bool> addEntry(AccountingEntryModel entry) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _entries.insert(0, entry);

    // Update account balance
    final accountIndex = _accounts.indexWhere((a) => a.id == entry.accountId);
    if (accountIndex != -1) {
      final account = _accounts[accountIndex];
      final newBalance = entry.entryType == EntryType.income
          ? account.balance + entry.amount
          : account.balance - entry.amount;

      _accounts[accountIndex] = account.copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Update entry
  Future<bool> updateEntry(
    String entryId,
    AccountingEntryModel updatedEntry,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      final oldEntry = _entries[index];

      // Revert old balance change
      final oldAccountIndex = _accounts.indexWhere(
        (a) => a.id == oldEntry.accountId,
      );
      if (oldAccountIndex != -1) {
        final account = _accounts[oldAccountIndex];
        final revertedBalance = oldEntry.entryType == EntryType.income
            ? account.balance - oldEntry.amount
            : account.balance + oldEntry.amount;
        _accounts[oldAccountIndex] = account.copyWith(balance: revertedBalance);
      }

      // Apply new balance change
      final newAccountIndex = _accounts.indexWhere(
        (a) => a.id == updatedEntry.accountId,
      );
      if (newAccountIndex != -1) {
        final account = _accounts[newAccountIndex];
        final newBalance = updatedEntry.entryType == EntryType.income
            ? account.balance + updatedEntry.amount
            : account.balance - updatedEntry.amount;
        _accounts[newAccountIndex] = account.copyWith(
          balance: newBalance,
          updatedAt: DateTime.now(),
        );
      }

      _entries[index] = updatedEntry;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Delete entry
  Future<bool> deleteEntry(String entryId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      final entry = _entries[index];

      // Revert balance change
      final accountIndex = _accounts.indexWhere((a) => a.id == entry.accountId);
      if (accountIndex != -1) {
        final account = _accounts[accountIndex];
        final revertedBalance = entry.entryType == EntryType.income
            ? account.balance - entry.amount
            : account.balance + entry.amount;
        _accounts[accountIndex] = account.copyWith(balance: revertedBalance);
      }

      _entries.removeAt(index);
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Add new account
  Future<bool> addAccount(AccountModel account) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _accounts.add(account);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Update account
  Future<bool> updateAccount(
    String accountId,
    AccountModel updatedAccount,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      _accounts[index] = updatedAccount;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Add new budget
  Future<bool> addBudget(BudgetModel budget) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _budgets.insert(0, budget);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Update budget
  Future<bool> updateBudget(String budgetId, BudgetModel updatedBudget) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _budgets.indexWhere((b) => b.id == budgetId);
    if (index != -1) {
      _budgets[index] = updatedBudget;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Generate financial report
  Future<FinancialReportModel> generateReport({
    required ReportType type,
    required DateTime startDate,
    required DateTime endDate,
    String? generatedBy,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Filter entries by date range
    final periodEntries = _entries.where((e) {
      return e.transactionDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          e.transactionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    final incomeTotal = periodEntries
        .where((e) => e.entryType == EntryType.income)
        .fold(0.0, (sum, e) => sum + e.amount);

    final expenseTotal = periodEntries
        .where((e) => e.entryType == EntryType.expense)
        .fold(0.0, (sum, e) => sum + e.amount);

    // Build category breakdown
    final Map<String, double> categoryBreakdown = {};
    for (var entry in periodEntries) {
      final category = entry.accountName;
      categoryBreakdown[category] =
          (categoryBreakdown[category] ?? 0) + entry.amount;
    }

    final report = FinancialReportModel(
      id: 'report-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      period: ReportPeriod.custom,
      startDate: startDate,
      endDate: endDate,
      generatedAt: DateTime.now(),
      generatedBy: generatedBy,
      data: {'entries': periodEntries.map((e) => e.toJson()).toList()},
      summary: ReportSummary(
        totalIncome: incomeTotal,
        totalExpense: expenseTotal,
        netIncome: incomeTotal - expenseTotal,
        transactionCount: periodEntries.length,
        categoryBreakdown: categoryBreakdown,
      ),
    );

    _reports.insert(0, report);

    _isLoading = false;
    notifyListeners();
    return report;
  }

  /// Set filters
  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    notifyListeners();
  }

  void setEntryTypeFilter(EntryType? type) {
    _filterEntryType = type;
    notifyListeners();
  }

  void setAccountFilter(String? accountId) {
    _filterAccountId = accountId;
    notifyListeners();
  }

  void clearFilters() {
    _filterStartDate = null;
    _filterEndDate = null;
    _filterEntryType = null;
    _filterAccountId = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadAccountingData();
  }
}
