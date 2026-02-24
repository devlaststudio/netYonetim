import 'package:flutter/material.dart';

import '../mock/manager_finance_mock_data.dart';
import '../models/manager/manager_models.dart';

class ManagerFinanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdatedAt;

  List<ChargeBatch> _chargeBatches = [];
  List<CollectionRecord> _collections = [];
  List<CashExpense> _cashExpenses = [];
  List<TransferRecord> _transfers = [];
  List<BankMovement> _bankMovements = [];
  List<ReconciliationRule> _reconciliationRules = [];
  List<CashMovementRecord> _cashMovements = [];
  List<UnitStatementLine> _unitStatementLines = [];
  List<VendorLedgerEntry> _vendorStatementLines = [];
  List<AutoChargeRule> _autoChargeRules = [];
  List<ScheduledChargeExecutionLog> _executionLogs = [];

  final Map<String, double> _accountBalances = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdatedAt => _lastUpdatedAt;

  List<ChargeBatch> get chargeBatches => _chargeBatches;
  List<CollectionRecord> get collections => _collections;
  List<CashExpense> get cashExpenses => _cashExpenses;
  List<TransferRecord> get transfers => _transfers;
  List<BankMovement> get bankMovements => _bankMovements;
  List<ReconciliationRule> get reconciliationRules => _reconciliationRules;
  List<CashMovementRecord> get cashMovements => _cashMovements;
  List<UnitStatementLine> get unitStatementLines => _unitStatementLines;
  List<VendorLedgerEntry> get vendorStatementLines => _vendorStatementLines;
  List<AutoChargeRule> get autoChargeRules => _autoChargeRules;
  List<ScheduledChargeExecutionLog> get executionLogs => _executionLogs;
  Map<String, double> get accountBalances => _accountBalances;

  double get totalChargeAmount =>
      _chargeBatches.fold<double>(0, (sum, batch) => sum + batch.totalAmount);

  double get totalCollectionAmount =>
      _collections.fold<double>(0, (sum, record) => sum + record.amount);

  double get totalExpenseAmount =>
      _cashExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);

  double get totalTransferAmount =>
      _transfers.fold<double>(0, (sum, transfer) => sum + transfer.amount);

  Future<void> loadMockData() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 250));

    try {
      _chargeBatches = ManagerFinanceMockData.getChargeBatches();
      _collections = ManagerFinanceMockData.getCollections();
      _cashExpenses = ManagerFinanceMockData.getCashExpenses();
      _transfers = ManagerFinanceMockData.getTransfers();
      _bankMovements = ManagerFinanceMockData.getBankMovements();
      _reconciliationRules = ManagerFinanceMockData.getReconciliationRules();
      _cashMovements = ManagerFinanceMockData.getCashMovements();
      _unitStatementLines = ManagerFinanceMockData.getUnitStatementLines();
      _vendorStatementLines = ManagerFinanceMockData.getVendorLedgerEntries();
      _autoChargeRules = ManagerFinanceMockData.getAutoChargeRules();
      _executionLogs = ManagerFinanceMockData.getScheduledChargeExecutionLogs();
      _accountBalances
        ..clear()
        ..addEntries(
          ManagerFinanceMockData.defaultBalances.map(
            (entry) => MapEntry<String, double>(
              entry['id'] as String,
              entry['balance'] as double,
            ),
          ),
        );

      _lastUpdatedAt = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createChargeBatch({
    required String title,
    required ChargeMainType mainType,
    required ChargeCalculationMethod calculationMethod,
    required ChargeScope scope,
    required ChargeDistributionType distribution,
    required String period,
    required DateTime dueDate,
    DateTime? accrualDate,
    required double amount,
    Map<String, String> methodParameters = const {},
  }) async {
    final items = ManagerFinanceMockData.units.take(5).map((unit) {
      return ChargeItem(
        id: 'ch-item-${DateTime.now().millisecondsSinceEpoch}-${unit['id']}',
        unitId: unit['id']!,
        unitLabel: unit['label']!,
        amount: amount / 5,
      );
    }).toList();

    final batch = ChargeBatch(
      id: 'charge-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      mainType: mainType,
      calculationMethod: calculationMethod,
      scope: scope,
      distributionType: distribution,
      methodParameters: methodParameters,
      targetIds: items.map((item) => item.unitId).toList(),
      period: period,
      dueDate: dueDate,
      accrualDate: accrualDate,
      items: items,
      status: ChargeBatchStatus.posted,
      createdAt: DateTime.now(),
    );

    _chargeBatches.insert(0, batch);
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addAutoChargeRule({
    required String name,
    required ChargeScope scope,
    required ChargeDistributionType distributionType,
    required SchedulerFrequency frequency,
    required double amount,
    required int dueDay,
  }) async {
    final now = DateTime.now();
    _autoChargeRules.insert(
      0,
      AutoChargeRule(
        id: 'acr-${now.millisecondsSinceEpoch}',
        name: name,
        scope: scope,
        distributionType: distributionType,
        frequency: frequency,
        amount: amount,
        dueDay: dueDay,
        isActive: true,
        nextRunAt: _nextRunFromFrequency(frequency, now),
      ),
    );

    _lastUpdatedAt = now;
    notifyListeners();
  }

  Future<void> toggleAutoChargeRule(String ruleId, bool isActive) async {
    final index = _autoChargeRules.indexWhere((rule) => rule.id == ruleId);
    if (index == -1) {
      return;
    }
    _autoChargeRules[index] = _autoChargeRules[index].copyWith(
      isActive: isActive,
    );
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> runAutoChargeRuleNow(String ruleId) async {
    final index = _autoChargeRules.indexWhere((rule) => rule.id == ruleId);
    if (index == -1) {
      return;
    }

    final rule = _autoChargeRules[index];
    final now = DateTime.now();
    final period = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final targetUnits = ManagerFinanceMockData.units.take(5).toList();
    final itemAmount = rule.amount / targetUnits.length;
    final items = targetUnits.map((unit) {
      return ChargeItem(
        id: 'ch-item-${now.millisecondsSinceEpoch}-${unit['id']}',
        unitId: unit['id']!,
        unitLabel: unit['label']!,
        amount: itemAmount,
      );
    }).toList();

    _chargeBatches.insert(
      0,
      ChargeBatch(
        id: 'charge-${now.millisecondsSinceEpoch}',
        title: '${rule.name} (Otomatik)',
        mainType: ChargeMainType.dues,
        calculationMethod: ChargeCalculationMethod.equalShare,
        scope: rule.scope,
        distributionType: rule.distributionType,
        methodParameters: {'kaynak': 'Otomatik Kural', 'kural': rule.name},
        targetIds: items.map((item) => item.unitId).toList(),
        period: period,
        dueDate: DateTime(now.year, now.month, rule.dueDay),
        items: items,
        status: ChargeBatchStatus.posted,
        createdAt: now,
      ),
    );

    _autoChargeRules[index] = rule.copyWith(
      lastRunAt: now,
      nextRunAt: _nextRunFromFrequency(rule.frequency, now),
    );

    _executionLogs.insert(
      0,
      ScheduledChargeExecutionLog(
        id: 'log-${now.millisecondsSinceEpoch}',
        ruleId: rule.id,
        ruleName: rule.name,
        executedAt: now,
        batchId: 'charge-${now.millisecondsSinceEpoch}',
        period: period,
        unitCount: targetUnits.length,
        totalAmount: rule.amount,
        status: ScheduledExecutionStatus.success,
      ),
    );

    _lastUpdatedAt = now;
    notifyListeners();
  }

  Future<void> deleteAutoChargeRule(String ruleId) async {
    _autoChargeRules.removeWhere((rule) => rule.id == ruleId);
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> regenerateChargeBatch(String batchId) async {
    final index = _chargeBatches.indexWhere((batch) => batch.id == batchId);
    if (index == -1) {
      return;
    }

    final current = _chargeBatches[index];
    final cloned = current.copyWith(
      id: 'charge-${DateTime.now().millisecondsSinceEpoch}',
      title: '${current.title} (Yeniden)',
      createdAt: DateTime.now(),
      status: ChargeBatchStatus.posted,
    );

    _chargeBatches.insert(0, cloned);
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> cancelChargeBatch(String batchId) async {
    final index = _chargeBatches.indexWhere((batch) => batch.id == batchId);
    if (index == -1) {
      return;
    }

    _chargeBatches[index] = _chargeBatches[index].copyWith(
      status: ChargeBatchStatus.cancelled,
    );
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> createCollection({
    required String payerId,
    required String payerName,
    required double amount,
    required AllocationMode allocationMode,
    required String cashAccountId,
    required String cashAccountName,
  }) async {
    final allocations = [
      CollectionAllocationLine(
        dueId: 'due-${DateTime.now().millisecondsSinceEpoch}',
        allocatedAmount: amount,
        remainingAfter: 0,
      ),
    ];

    final record = CollectionRecord(
      id: 'col-${DateTime.now().millisecondsSinceEpoch}',
      payerId: payerId,
      payerName: payerName,
      amount: amount,
      collectionDate: DateTime.now(),
      cashAccountId: cashAccountId,
      cashAccountName: cashAccountName,
      allocationMode: allocationMode,
      allocations: allocations,
      receiptNo:
          'TB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      status: CollectionStatus.approved,
    );

    _collections.insert(0, record);
    _cashMovements.insert(
      0,
      CashMovementRecord(
        id: 'cm-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        sourceType: 'Tahsilat',
        sourceId: record.id,
        accountName: cashAccountName,
        description: '${record.payerName} tahsilati',
        amount: record.amount,
        direction: MovementDirection.incoming,
      ),
    );

    _accountBalances[cashAccountId] =
        (_accountBalances[cashAccountId] ?? 0) + amount;
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> createCashExpense({
    required String vendorId,
    required String vendorName,
    required String category,
    required double amount,
    required String cashAccountId,
    required String cashAccountName,
    String? documentNo,
  }) async {
    final expense = CashExpense(
      id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
      vendorId: vendorId,
      vendorName: vendorName,
      category: category,
      amount: amount,
      expenseDate: DateTime.now(),
      documentNo: documentNo,
      paymentStatus: ExpensePaymentStatus.paid,
      cashAccountId: cashAccountId,
      cashAccountName: cashAccountName,
    );

    _cashExpenses.insert(0, expense);
    _vendorStatementLines.insert(
      0,
      VendorLedgerEntry(
        id: 'vl-${DateTime.now().millisecondsSinceEpoch}',
        vendorId: vendorId,
        vendorName: vendorName,
        date: DateTime.now(),
        entryType: 'Odeme',
        debit: 0,
        credit: amount,
        balance: -amount,
        refType: 'Gider',
        refId: expense.id,
      ),
    );
    _cashMovements.insert(
      0,
      CashMovementRecord(
        id: 'cm-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        sourceType: 'Gider',
        sourceId: expense.id,
        accountName: cashAccountName,
        description: '${expense.vendorName} odemesi',
        amount: amount,
        direction: MovementDirection.outgoing,
      ),
    );

    _accountBalances[cashAccountId] =
        (_accountBalances[cashAccountId] ?? 0) - amount;
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<bool> createTransfer({
    required String fromAccountId,
    required String fromAccountName,
    required String toAccountId,
    required String toAccountName,
    required double amount,
    required String description,
  }) async {
    final fromBalance = _accountBalances[fromAccountId] ?? 0;
    if (fromBalance < amount) {
      _errorMessage = 'Yetersiz bakiye';
      notifyListeners();
      return false;
    }

    final transfer = TransferRecord(
      id: 'tr-${DateTime.now().millisecondsSinceEpoch}',
      fromAccountId: fromAccountId,
      fromAccountName: fromAccountName,
      toAccountId: toAccountId,
      toAccountName: toAccountName,
      amount: amount,
      transferDate: DateTime.now(),
      description: description,
      status: TransferStatus.completed,
    );

    _transfers.insert(0, transfer);
    _accountBalances[fromAccountId] = fromBalance - amount;
    _accountBalances[toAccountId] =
        (_accountBalances[toAccountId] ?? 0) + amount;

    _cashMovements.insertAll(0, [
      CashMovementRecord(
        id: 'cm-${DateTime.now().millisecondsSinceEpoch}-out',
        date: DateTime.now(),
        sourceType: 'Virman',
        sourceId: transfer.id,
        accountName: fromAccountName,
        description: description,
        amount: amount,
        direction: MovementDirection.outgoing,
      ),
      CashMovementRecord(
        id: 'cm-${DateTime.now().millisecondsSinceEpoch}-in',
        date: DateTime.now(),
        sourceType: 'Virman',
        sourceId: transfer.id,
        accountName: toAccountName,
        description: description,
        amount: amount,
        direction: MovementDirection.incoming,
      ),
    ]);

    _errorMessage = null;
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
    return true;
  }

  Future<void> matchBankMovement(String movementId, String reference) async {
    final index = _bankMovements.indexWhere(
      (movement) => movement.id == movementId,
    );
    if (index == -1) {
      return;
    }

    _bankMovements[index] = _bankMovements[index].copyWith(
      matchedStatus: MatchStatus.matched,
      matchedRef: reference,
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> ignoreBankMovement(String movementId) async {
    final index = _bankMovements.indexWhere(
      (movement) => movement.id == movementId,
    );
    if (index == -1) {
      return;
    }

    _bankMovements[index] = _bankMovements[index].copyWith(
      matchedStatus: MatchStatus.ignored,
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addReconciliationRule({
    required String name,
    required String keyword,
    required String defaultRef,
  }) async {
    _reconciliationRules.insert(
      0,
      ReconciliationRule(
        id: 'rule-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        keyword: keyword,
        defaultRef: defaultRef,
        isActive: true,
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> cancelCashMovement(String movementId) async {
    final index = _cashMovements.indexWhere(
      (movement) => movement.id == movementId,
    );
    if (index == -1) {
      return;
    }

    _cashMovements[index] = _cashMovements[index].copyWith(isCancelled: true);
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  List<UnitStatementLine> getUnitStatements(String unitId) {
    if (unitId.isEmpty) {
      return _unitStatementLines;
    }
    return _unitStatementLines.where((line) => line.unitId == unitId).toList();
  }

  List<VendorLedgerEntry> getVendorStatements(String vendorId) {
    if (vendorId.isEmpty) {
      return _vendorStatementLines;
    }
    return _vendorStatementLines
        .where((line) => line.vendorId == vendorId)
        .toList();
  }

  DateTime _nextRunFromFrequency(SchedulerFrequency frequency, DateTime from) {
    switch (frequency) {
      case SchedulerFrequency.daily:
        return from.add(const Duration(days: 1));
      case SchedulerFrequency.weekly:
        return from.add(const Duration(days: 7));
      case SchedulerFrequency.monthly:
        return DateTime(from.year, from.month + 1, from.day);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
