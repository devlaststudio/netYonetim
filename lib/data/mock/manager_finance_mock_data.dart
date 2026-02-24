import '../models/manager/manager_models.dart';

class ManagerFinanceMockData {
  static final List<Map<String, String>> units = [
    {'id': 'unit-a1', 'label': 'A Blok 1'},
    {'id': 'unit-a2', 'label': 'A Blok 2'},
    {'id': 'unit-a3', 'label': 'A Blok 3'},
    {'id': 'unit-a4', 'label': 'A Blok 4'},
    {'id': 'unit-b1', 'label': 'B Blok 1'},
    {'id': 'unit-b2', 'label': 'B Blok 2'},
    {'id': 'unit-b3', 'label': 'B Blok 3'},
    {'id': 'unit-b4', 'label': 'B Blok 4'},
    {'id': 'unit-c1', 'label': 'C Blok 1'},
    {'id': 'unit-c2', 'label': 'C Blok 2'},
  ];

  static final List<Map<String, String>> members = [
    {'id': 'm-001', 'name': 'Ali Demir'},
    {'id': 'm-002', 'name': 'Ayse Yildiz'},
    {'id': 'm-003', 'name': 'Mert Kaya'},
    {'id': 'm-004', 'name': 'Selin Acar'},
    {'id': 'm-005', 'name': 'Hasan Karaca'},
  ];

  static final List<Map<String, String>> accounts = [
    {'id': 'acc-cash', 'name': 'Nakit Kasa'},
    {'id': 'acc-aidat', 'name': 'Aidat Kasasi'},
    {'id': 'acc-extra', 'name': 'Ek Butce Kasasi'},
    {'id': 'acc-bank-teb', 'name': 'TEB Bankasi'},
    {'id': 'acc-bank-ziraat', 'name': 'Ziraat Bankasi'},
  ];

  static final List<Map<String, dynamic>> defaultBalances = [
    {'id': 'acc-cash', 'balance': 186500.0},
    {'id': 'acc-aidat', 'balance': 425000.0},
    {'id': 'acc-extra', 'balance': 132000.0},
    {'id': 'acc-bank-teb', 'balance': 640200.0},
    {'id': 'acc-bank-ziraat', 'balance': 180350.0},
  ];

  static final List<Map<String, String>> vendors = [
    {'id': 'v-001', 'name': 'Mega Temizlik Ltd.'},
    {'id': 'v-002', 'name': 'Asansor Servis A.S.'},
    {'id': 'v-003', 'name': 'Guven Elektrik'},
    {'id': 'v-004', 'name': 'Peyzaj Arti'},
    {'id': 'v-005', 'name': 'Personel Maas Hesabi'},
  ];

  static const List<String> chargeDuesGroups = [
    'Standart Konut Aidati',
    'Dukkan Aidat Grubu',
    'Havuzlu Blok Grubu',
    'Asansorlu Blok Grubu',
  ];

  static const List<String> operatingProjects = [
    '2026 Ocak Isletme Projesi',
    '2026 Subat Isletme Projesi',
    '2026 Mart Isletme Projesi',
  ];

  static const List<String> operatingProjectLines = [
    'Guvenlik Maas Gideri',
    'Temizlik Personeli',
    'Asansor Bakim Sozlesmesi',
    'Peyzaj ve Sulama',
    'Yakit ve Isinma',
  ];

  static const List<String> blockOptions = ['A Blok', 'B Blok', 'C Blok'];

  static const List<String> unitGroupOptions = [
    'Tum Daireler',
    'Dukkanlar',
    'Kiracilar',
    'Sadece Malikler',
  ];

  static List<ChargeBatch> getChargeBatches() {
    final now = DateTime.now();
    return List.generate(8, (index) {
      final scope = ChargeScope.values[index % ChargeScope.values.length];
      final distribution = ChargeDistributionType
          .values[index % ChargeDistributionType.values.length];
      final mainType =
          ChargeMainType.values[index % ChargeMainType.values.length];
      final method = ChargeCalculationMethod
          .values[index % ChargeCalculationMethod.values.length];
      final items = List.generate(5, (line) {
        final unit = units[(index + line) % units.length];
        final amount = 850 + (line * 120) + (index * 10);
        return ChargeItem(
          id: 'ch-item-$index-$line',
          unitId: unit['id']!,
          unitLabel: unit['label']!,
          amount: amount.toDouble(),
        );
      });

      return ChargeBatch(
        id: 'charge-batch-$index',
        title: 'Donem Tahakkuku ${index + 1}',
        mainType: mainType,
        calculationMethod: method,
        scope: scope,
        distributionType: distribution,
        methodParameters: {'kaynak': method.label, 'anaTur': mainType.label},
        targetIds: items.map((e) => e.unitId).toList(),
        period: '2026-${((index % 12) + 1).toString().padLeft(2, '0')}',
        dueDate: now.add(Duration(days: 8 + (index * 2))),
        items: items,
        status: index == 1
            ? ChargeBatchStatus.cancelled
            : index < 5
            ? ChargeBatchStatus.posted
            : ChargeBatchStatus.draft,
        createdAt: now.subtract(Duration(days: index * 5)),
      );
    });
  }

  static List<CollectionRecord> getCollections() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final member = members[index % members.length];
      final allocations = List.generate(2, (line) {
        final allocated = 600 + (line * 220) + (index * 15);
        return CollectionAllocationLine(
          dueId: 'due-${index + line}',
          allocatedAmount: allocated.toDouble(),
          remainingAfter: line == 0 ? 300.0 : 0,
        );
      });
      final total = allocations.fold<double>(
        0,
        (sum, line) => sum + line.allocatedAmount,
      );

      final account = accounts[index % accounts.length];

      return CollectionRecord(
        id: 'col-$index',
        payerId: member['id']!,
        payerName: member['name']!,
        amount: total,
        collectionDate: now.subtract(Duration(days: index)),
        cashAccountId: account['id']!,
        cashAccountName: account['name']!,
        allocationMode:
            AllocationMode.values[index % AllocationMode.values.length],
        allocations: allocations,
        receiptNo: 'TB-${1000 + index}',
        status: index == 3
            ? CollectionStatus.cancelled
            : index < 8
            ? CollectionStatus.approved
            : CollectionStatus.draft,
      );
    });
  }

  static List<CashExpense> getCashExpenses() {
    final now = DateTime.now();
    const categories = [
      'Personel',
      'Bakim Onarim',
      'Guvenlik',
      'Temizlik',
      'Ortak Alan',
    ];

    return List.generate(12, (index) {
      final vendor = vendors[index % vendors.length];
      final account = accounts[index % accounts.length];
      return CashExpense(
        id: 'exp-$index',
        vendorId: vendor['id']!,
        vendorName: vendor['name']!,
        category: categories[index % categories.length],
        amount: (1450 + index * 370).toDouble(),
        expenseDate: now.subtract(Duration(days: index * 2)),
        documentNo: 'FTR-2026-${index + 1}',
        paymentStatus: ExpensePaymentStatus
            .values[index % ExpensePaymentStatus.values.length],
        cashAccountId: account['id']!,
        cashAccountName: account['name']!,
      );
    });
  }

  static List<TransferRecord> getTransfers() {
    final now = DateTime.now();
    return List.generate(10, (index) {
      final from = accounts[index % accounts.length];
      final to = accounts[(index + 1) % accounts.length];
      return TransferRecord(
        id: 'tr-$index',
        fromAccountId: from['id']!,
        fromAccountName: from['name']!,
        toAccountId: to['id']!,
        toAccountName: to['name']!,
        amount: (1500 + (index * 350)).toDouble(),
        transferDate: now.subtract(Duration(days: index * 3)),
        description: 'Virman kaydi #${index + 1}',
        status: index == 2 ? TransferStatus.failed : TransferStatus.completed,
      );
    });
  }

  static List<BankMovement> getBankMovements() {
    final now = DateTime.now();
    return List.generate(14, (index) {
      final account = accounts
          .where((a) => a['id']!.contains('bank'))
          .toList()[index % 2];
      return BankMovement(
        id: 'bm-$index',
        bankAccountId: account['id']!,
        bankAccountName: account['name']!,
        txnDate: now.subtract(Duration(hours: index * 6)),
        amount: (1100 + index * 210).toDouble(),
        direction: index.isEven
            ? MovementDirection.incoming
            : MovementDirection.outgoing,
        description: index % 3 == 0
            ? 'Aidat odemesi A Blok ${index + 1}'
            : index % 3 == 1
            ? 'Fatura odemesi #${200 + index}'
            : 'Tanimsiz havale',
        matchedStatus: index % 4 == 0
            ? MatchStatus.matched
            : index % 4 == 1
            ? MatchStatus.suggested
            : MatchStatus.unmatched,
        matchedRef: index % 4 == 0 ? 'Tahsilat TB-${1000 + index}' : null,
      );
    });
  }

  static List<ReconciliationRule> getReconciliationRules() {
    return const [
      ReconciliationRule(
        id: 'rule-1',
        name: 'Aidat Tahsilat Eslestirme',
        keyword: 'Aidat',
        defaultRef: 'Tahsilat',
        isActive: true,
      ),
      ReconciliationRule(
        id: 'rule-2',
        name: 'Fatura Odeme Eslestirme',
        keyword: 'Fatura',
        defaultRef: 'Gider',
        isActive: true,
      ),
      ReconciliationRule(
        id: 'rule-3',
        name: 'Personel Odeme Eslestirme',
        keyword: 'Maas',
        defaultRef: 'Cari',
        isActive: false,
      ),
    ];
  }

  static List<CashMovementRecord> getCashMovements() {
    final now = DateTime.now();
    return List.generate(18, (index) {
      final incoming = index % 2 == 0;
      return CashMovementRecord(
        id: 'cm-$index',
        date: now.subtract(Duration(hours: index * 4)),
        sourceType: incoming ? 'Tahsilat' : 'Gider',
        sourceId: incoming ? 'col-${index % 12}' : 'exp-${index % 12}',
        accountName: incoming ? 'Aidat Kasasi' : 'Nakit Kasa',
        description: incoming
            ? 'Daire tahsilati #$index'
            : 'Tedarikci odemesi #$index',
        amount: (700 + index * 95).toDouble(),
        direction: incoming
            ? MovementDirection.incoming
            : MovementDirection.outgoing,
        isCancelled: index == 7,
      );
    });
  }

  static List<UnitStatementLine> getUnitStatementLines() {
    final now = DateTime.now();
    return List.generate(24, (index) {
      final unit = units[index % units.length];
      final debt = index.isEven ? (900 + index * 15).toDouble() : 0.0;
      final paid = index.isOdd ? (700 + index * 10).toDouble() : 0.0;
      final balance = debt - paid;
      return UnitStatementLine(
        id: 'us-$index',
        unitId: unit['id']!,
        unitLabel: unit['label']!,
        date: now.subtract(Duration(days: index * 2)),
        description: index.isEven ? 'Aidat tahakkuku' : 'Tahsilat',
        debt: debt,
        paid: paid,
        balance: balance,
      );
    });
  }

  static List<VendorLedgerEntry> getVendorLedgerEntries() {
    final now = DateTime.now();
    return List.generate(20, (index) {
      final vendor = vendors[index % vendors.length];
      final debit = index.isEven ? (1200 + index * 30).toDouble() : 0.0;
      final credit = index.isOdd ? (1000 + index * 25).toDouble() : 0.0;
      return VendorLedgerEntry(
        id: 'vl-$index',
        vendorId: vendor['id']!,
        vendorName: vendor['name']!,
        date: now.subtract(Duration(days: index)),
        entryType: index.isEven ? 'Fatura' : 'Odeme',
        debit: debit,
        credit: credit,
        balance: debit - credit,
        refType: index.isEven ? 'Gider' : 'Banka',
        refId: index.isEven ? 'exp-${index % 12}' : 'bm-${index % 14}',
      );
    });
  }

  static List<AutoChargeRule> getAutoChargeRules() {
    final now = DateTime.now();
    return [
      AutoChargeRule(
        id: 'acr-1',
        name: 'Aylik Aidat Tahakkuku',
        scope: ChargeScope.allUnits,
        distributionType: ChargeDistributionType.equal,
        frequency: SchedulerFrequency.monthly,
        amount: 420000,
        dueDay: 10,
        isActive: true,
        lastRunAt: now.subtract(const Duration(days: 19)),
        nextRunAt: now.add(const Duration(days: 11)),
      ),
      AutoChargeRule(
        id: 'acr-2',
        name: 'Asansor Bakim Fonu',
        scope: ChargeScope.block,
        distributionType: ChargeDistributionType.sqm,
        frequency: SchedulerFrequency.monthly,
        amount: 58000,
        dueDay: 15,
        isActive: true,
        lastRunAt: now.subtract(const Duration(days: 5)),
        nextRunAt: now.add(const Duration(days: 25)),
      ),
      AutoChargeRule(
        id: 'acr-3',
        name: 'Ek Temizlik Tahakkuku',
        scope: ChargeScope.unitGroup,
        distributionType: ChargeDistributionType.fixed,
        frequency: SchedulerFrequency.weekly,
        amount: 7200,
        dueDay: 7,
        isActive: false,
        lastRunAt: now.subtract(const Duration(days: 16)),
        nextRunAt: now.add(const Duration(days: 4)),
      ),
    ];
  }

  static List<ScheduledChargeExecutionLog> getScheduledChargeExecutionLogs() {
    final now = DateTime.now();
    return [
      ScheduledChargeExecutionLog(
        id: 'log-1',
        ruleId: 'acr-1',
        ruleName: 'Aylik Aidat Tahakkuku',
        executedAt: now.subtract(const Duration(days: 19)),
        batchId: 'charge-batch-0',
        period: '2026-01',
        unitCount: 5,
        totalAmount: 420000,
        status: ScheduledExecutionStatus.success,
      ),
      ScheduledChargeExecutionLog(
        id: 'log-2',
        ruleId: 'acr-2',
        ruleName: 'Asansor Bakim Fonu',
        executedAt: now.subtract(const Duration(days: 5)),
        batchId: 'charge-batch-1',
        period: '2026-02',
        unitCount: 5,
        totalAmount: 58000,
        status: ScheduledExecutionStatus.success,
      ),
      ScheduledChargeExecutionLog(
        id: 'log-3',
        ruleId: 'acr-1',
        ruleName: 'Aylik Aidat Tahakkuku',
        executedAt: now.subtract(const Duration(days: 49)),
        batchId: 'charge-batch-2',
        period: '2025-12',
        unitCount: 5,
        totalAmount: 420000,
        status: ScheduledExecutionStatus.success,
      ),
      ScheduledChargeExecutionLog(
        id: 'log-4',
        ruleId: 'acr-3',
        ruleName: 'Ek Temizlik Tahakkuku',
        executedAt: now.subtract(const Duration(days: 16)),
        batchId: null,
        period: '2026-01',
        unitCount: 0,
        totalAmount: 0,
        status: ScheduledExecutionStatus.failed,
      ),
      ScheduledChargeExecutionLog(
        id: 'log-5',
        ruleId: 'acr-2',
        ruleName: 'Asansor Bakim Fonu',
        executedAt: now.subtract(const Duration(days: 35)),
        batchId: 'charge-batch-3',
        period: '2026-01',
        unitCount: 5,
        totalAmount: 58000,
        status: ScheduledExecutionStatus.success,
      ),
    ];
  }
}
