import 'package:flutter/material.dart';

enum ChargeScope {
  allUnits,
  block,
  unitGroup,
  person,
  excelImport,
  budgetBased,
}

enum ChargeDistributionType {
  equal,
  sqm,
  fixed,
  custom,
}

enum ChargeMainType {
  dues,
  fuel,
  fixture,
  maintenance,
  personnel,
  operating,
  reserveFund,
  other,
}

enum ChargeCalculationMethod {
  duesGroup,
  operatingProject,
  manualAmount,
  bySquareMeter,
  byLandShare,
  byPersonCount,
  equalShare,
}

enum ChargeBatchStatus {
  draft,
  posted,
  cancelled,
}

enum AllocationMode {
  oldestFirst,
  newestFirst,
  manual,
}

enum CollectionStatus {
  draft,
  approved,
  cancelled,
}

enum ExpensePaymentStatus {
  draft,
  approved,
  paid,
  cancelled,
}

enum TransferStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum MovementDirection {
  incoming,
  outgoing,
}

enum MatchStatus {
  unmatched,
  suggested,
  matched,
  ignored,
}

enum NotificationChannel {
  app,
  sms,
  email,
  whatsapp,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

enum TaskStatus {
  open,
  inProgress,
  completed,
  cancelled,
}

enum MeterType {
  hotWater,
  coldWater,
  electricity,
  heatShare,
}

enum MeterReadingStatus {
  draft,
  approved,
  billed,
}

enum StaffRoleType {
  manager,
  accountant,
  security,
  cleaning,
  technical,
}

enum LegacyOccupancyType {
  owner,
  tenant,
}

enum SchedulerFrequency {
  daily,
  weekly,
  monthly,
}

enum ImportRowStatus {
  valid,
  warning,
  error,
}

enum ReportTypeKey {
  cashStatus,
  monthlyIncomeExpense,
  accrualMovements,
  collection,
  unitStatement,
  vendorStatement,
  auditor,
  warningLetter,
  noDebt,
  posBank,
  budgetComparison,
}

class ChargeItem {
  final String id;
  final String unitId;
  final String unitLabel;
  final double amount;

  const ChargeItem({
    required this.id,
    required this.unitId,
    required this.unitLabel,
    required this.amount,
  });
}

class ChargeBatch {
  final String id;
  final String title;
  final ChargeMainType mainType;
  final ChargeCalculationMethod calculationMethod;
  final ChargeScope scope;
  final ChargeDistributionType distributionType;
  final Map<String, String> methodParameters;
  final List<String> targetIds;
  final String period;
  final DateTime dueDate;
  final List<ChargeItem> items;
  final ChargeBatchStatus status;
  final DateTime createdAt;

  const ChargeBatch({
    required this.id,
    required this.title,
    required this.mainType,
    required this.calculationMethod,
    required this.scope,
    required this.distributionType,
    this.methodParameters = const {},
    required this.targetIds,
    required this.period,
    required this.dueDate,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  double get totalAmount =>
      items.fold<double>(0, (sum, item) => sum + item.amount);

  ChargeBatch copyWith({
    String? id,
    String? title,
    ChargeMainType? mainType,
    ChargeCalculationMethod? calculationMethod,
    ChargeScope? scope,
    ChargeDistributionType? distributionType,
    Map<String, String>? methodParameters,
    List<String>? targetIds,
    String? period,
    DateTime? dueDate,
    List<ChargeItem>? items,
    ChargeBatchStatus? status,
    DateTime? createdAt,
  }) {
    return ChargeBatch(
      id: id ?? this.id,
      title: title ?? this.title,
      mainType: mainType ?? this.mainType,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      scope: scope ?? this.scope,
      distributionType: distributionType ?? this.distributionType,
      methodParameters: methodParameters ?? this.methodParameters,
      targetIds: targetIds ?? this.targetIds,
      period: period ?? this.period,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CollectionAllocationLine {
  final String dueId;
  final double allocatedAmount;
  final double remainingAfter;

  const CollectionAllocationLine({
    required this.dueId,
    required this.allocatedAmount,
    required this.remainingAfter,
  });
}

class CollectionRecord {
  final String id;
  final String payerId;
  final String payerName;
  final double amount;
  final DateTime collectionDate;
  final String cashAccountId;
  final String cashAccountName;
  final AllocationMode allocationMode;
  final List<CollectionAllocationLine> allocations;
  final String receiptNo;
  final CollectionStatus status;

  const CollectionRecord({
    required this.id,
    required this.payerId,
    required this.payerName,
    required this.amount,
    required this.collectionDate,
    required this.cashAccountId,
    required this.cashAccountName,
    required this.allocationMode,
    required this.allocations,
    required this.receiptNo,
    required this.status,
  });

  CollectionRecord copyWith({
    String? id,
    String? payerId,
    String? payerName,
    double? amount,
    DateTime? collectionDate,
    String? cashAccountId,
    String? cashAccountName,
    AllocationMode? allocationMode,
    List<CollectionAllocationLine>? allocations,
    String? receiptNo,
    CollectionStatus? status,
  }) {
    return CollectionRecord(
      id: id ?? this.id,
      payerId: payerId ?? this.payerId,
      payerName: payerName ?? this.payerName,
      amount: amount ?? this.amount,
      collectionDate: collectionDate ?? this.collectionDate,
      cashAccountId: cashAccountId ?? this.cashAccountId,
      cashAccountName: cashAccountName ?? this.cashAccountName,
      allocationMode: allocationMode ?? this.allocationMode,
      allocations: allocations ?? this.allocations,
      receiptNo: receiptNo ?? this.receiptNo,
      status: status ?? this.status,
    );
  }
}

class CashExpense {
  final String id;
  final String vendorId;
  final String vendorName;
  final String category;
  final double amount;
  final DateTime expenseDate;
  final String? documentNo;
  final ExpensePaymentStatus paymentStatus;
  final String cashAccountId;
  final String cashAccountName;

  const CashExpense({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.documentNo,
    required this.paymentStatus,
    required this.cashAccountId,
    required this.cashAccountName,
  });

  CashExpense copyWith({
    String? id,
    String? vendorId,
    String? vendorName,
    String? category,
    double? amount,
    DateTime? expenseDate,
    String? documentNo,
    ExpensePaymentStatus? paymentStatus,
    String? cashAccountId,
    String? cashAccountName,
  }) {
    return CashExpense(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      documentNo: documentNo ?? this.documentNo,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cashAccountId: cashAccountId ?? this.cashAccountId,
      cashAccountName: cashAccountName ?? this.cashAccountName,
    );
  }
}

class VendorLedgerEntry {
  final String id;
  final String vendorId;
  final String vendorName;
  final DateTime date;
  final String entryType;
  final double debit;
  final double credit;
  final double balance;
  final String refType;
  final String refId;

  const VendorLedgerEntry({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.date,
    required this.entryType,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.refType,
    required this.refId,
  });
}

class TransferRecord {
  final String id;
  final String fromAccountId;
  final String fromAccountName;
  final String toAccountId;
  final String toAccountName;
  final double amount;
  final DateTime transferDate;
  final String description;
  final TransferStatus status;

  const TransferRecord({
    required this.id,
    required this.fromAccountId,
    required this.fromAccountName,
    required this.toAccountId,
    required this.toAccountName,
    required this.amount,
    required this.transferDate,
    required this.description,
    required this.status,
  });

  TransferRecord copyWith({
    String? id,
    String? fromAccountId,
    String? fromAccountName,
    String? toAccountId,
    String? toAccountName,
    double? amount,
    DateTime? transferDate,
    String? description,
    TransferStatus? status,
  }) {
    return TransferRecord(
      id: id ?? this.id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      fromAccountName: fromAccountName ?? this.fromAccountName,
      toAccountId: toAccountId ?? this.toAccountId,
      toAccountName: toAccountName ?? this.toAccountName,
      amount: amount ?? this.amount,
      transferDate: transferDate ?? this.transferDate,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}

class BankMovement {
  final String id;
  final String bankAccountId;
  final String bankAccountName;
  final DateTime txnDate;
  final double amount;
  final MovementDirection direction;
  final String description;
  final MatchStatus matchedStatus;
  final String? matchedRef;

  const BankMovement({
    required this.id,
    required this.bankAccountId,
    required this.bankAccountName,
    required this.txnDate,
    required this.amount,
    required this.direction,
    required this.description,
    required this.matchedStatus,
    this.matchedRef,
  });

  BankMovement copyWith({
    String? id,
    String? bankAccountId,
    String? bankAccountName,
    DateTime? txnDate,
    double? amount,
    MovementDirection? direction,
    String? description,
    MatchStatus? matchedStatus,
    String? matchedRef,
  }) {
    return BankMovement(
      id: id ?? this.id,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      txnDate: txnDate ?? this.txnDate,
      amount: amount ?? this.amount,
      direction: direction ?? this.direction,
      description: description ?? this.description,
      matchedStatus: matchedStatus ?? this.matchedStatus,
      matchedRef: matchedRef ?? this.matchedRef,
    );
  }
}

class ReconciliationRule {
  final String id;
  final String name;
  final String keyword;
  final String defaultRef;
  final bool isActive;

  const ReconciliationRule({
    required this.id,
    required this.name,
    required this.keyword,
    required this.defaultRef,
    required this.isActive,
  });

  ReconciliationRule copyWith({
    String? id,
    String? name,
    String? keyword,
    String? defaultRef,
    bool? isActive,
  }) {
    return ReconciliationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      keyword: keyword ?? this.keyword,
      defaultRef: defaultRef ?? this.defaultRef,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CashMovementRecord {
  final String id;
  final DateTime date;
  final String sourceType;
  final String sourceId;
  final String accountName;
  final String description;
  final double amount;
  final MovementDirection direction;
  final bool isCancelled;

  const CashMovementRecord({
    required this.id,
    required this.date,
    required this.sourceType,
    required this.sourceId,
    required this.accountName,
    required this.description,
    required this.amount,
    required this.direction,
    this.isCancelled = false,
  });

  CashMovementRecord copyWith({
    String? id,
    DateTime? date,
    String? sourceType,
    String? sourceId,
    String? accountName,
    String? description,
    double? amount,
    MovementDirection? direction,
    bool? isCancelled,
  }) {
    return CashMovementRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      accountName: accountName ?? this.accountName,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      direction: direction ?? this.direction,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}

class UnitStatementLine {
  final String id;
  final String unitId;
  final String unitLabel;
  final DateTime date;
  final String description;
  final double debt;
  final double paid;
  final double balance;

  const UnitStatementLine({
    required this.id,
    required this.unitId,
    required this.unitLabel,
    required this.date,
    required this.description,
    required this.debt,
    required this.paid,
    required this.balance,
  });
}

class NotificationTemplate {
  final String id;
  final String name;
  final NotificationChannel channel;
  final String title;
  final String body;
  final List<String> variables;

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.channel,
    required this.title,
    required this.body,
    required this.variables,
  });
}

class NotificationDispatch {
  final String id;
  final String templateId;
  final String templateName;
  final String targetFilter;
  final int targetCount;
  final int sentCount;
  final int failedCount;
  final DateTime createdAt;

  const NotificationDispatch({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.targetFilter,
    required this.targetCount,
    required this.sentCount,
    required this.failedCount,
    required this.createdAt,
  });
}

class MeterReading {
  final String id;
  final String unitId;
  final String unitLabel;
  final MeterType meterType;
  final String period;
  final double startIndex;
  final double endIndex;
  final double consumption;
  final MeterReadingStatus status;

  const MeterReading({
    required this.id,
    required this.unitId,
    required this.unitLabel,
    required this.meterType,
    required this.period,
    required this.startIndex,
    required this.endIndex,
    required this.consumption,
    required this.status,
  });

  MeterReading copyWith({
    String? id,
    String? unitId,
    String? unitLabel,
    MeterType? meterType,
    String? period,
    double? startIndex,
    double? endIndex,
    double? consumption,
    MeterReadingStatus? status,
  }) {
    return MeterReading(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      unitLabel: unitLabel ?? this.unitLabel,
      meterType: meterType ?? this.meterType,
      period: period ?? this.period,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      consumption: consumption ?? this.consumption,
      status: status ?? this.status,
    );
  }
}

class DecisionRecord {
  final String id;
  final String title;
  final DateTime meetingDate;
  final String decisionNo;
  final String summary;
  final List<String> attachmentIds;

  const DecisionRecord({
    required this.id,
    required this.title,
    required this.meetingDate,
    required this.decisionNo,
    required this.summary,
    required this.attachmentIds,
  });
}

class CallLogRecord {
  final String id;
  final String memberId;
  final String memberName;
  final String staffId;
  final String staffName;
  final DateTime callDate;
  final String note;
  final DateTime? nextActionDate;

  const CallLogRecord({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.staffId,
    required this.staffName,
    required this.callDate,
    required this.note,
    this.nextActionDate,
  });
}

class AssetRecord {
  final String id;
  final String name;
  final String category;
  final String location;
  final String status;
  final DateTime? lastMaintenanceDate;

  const AssetRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.status,
    this.lastMaintenanceDate,
  });
}

class TaskRecord {
  final String id;
  final String title;
  final String assignedStaffId;
  final String assignedStaffName;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime dueDate;
  final String notes;

  const TaskRecord({
    required this.id,
    required this.title,
    required this.assignedStaffId,
    required this.assignedStaffName,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.notes,
  });

  TaskRecord copyWith({
    String? id,
    String? title,
    String? assignedStaffId,
    String? assignedStaffName,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    String? notes,
  }) {
    return TaskRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }
}

class StaffRoleRecord {
  final String id;
  final String fullName;
  final StaffRoleType role;
  final bool mobileVisible;
  final List<String> permissions;

  const StaffRoleRecord({
    required this.id,
    required this.fullName,
    required this.role,
    required this.mobileVisible,
    required this.permissions,
  });

  StaffRoleRecord copyWith({
    String? id,
    String? fullName,
    StaffRoleType? role,
    bool? mobileVisible,
    List<String>? permissions,
  }) {
    return StaffRoleRecord(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      mobileVisible: mobileVisible ?? this.mobileVisible,
      permissions: permissions ?? this.permissions,
    );
  }
}

class FileArchiveItem {
  final String id;
  final String name;
  final String folder;
  final DateTime uploadedAt;
  final String uploadedBy;

  const FileArchiveItem({
    required this.id,
    required this.name,
    required this.folder,
    required this.uploadedAt,
    required this.uploadedBy,
  });
}

class SiteUnitGroup {
  final String id;
  final String name;
  final int unitCount;

  const SiteUnitGroup({
    required this.id,
    required this.name,
    required this.unitCount,
  });
}

class AutoChargeRule {
  final String id;
  final String name;
  final ChargeScope scope;
  final ChargeDistributionType distributionType;
  final SchedulerFrequency frequency;
  final double amount;
  final int dueDay;
  final bool isActive;
  final DateTime? lastRunAt;
  final DateTime nextRunAt;

  const AutoChargeRule({
    required this.id,
    required this.name,
    required this.scope,
    required this.distributionType,
    required this.frequency,
    required this.amount,
    required this.dueDay,
    required this.isActive,
    required this.nextRunAt,
    this.lastRunAt,
  });

  AutoChargeRule copyWith({
    String? id,
    String? name,
    ChargeScope? scope,
    ChargeDistributionType? distributionType,
    SchedulerFrequency? frequency,
    double? amount,
    int? dueDay,
    bool? isActive,
    DateTime? lastRunAt,
    DateTime? nextRunAt,
  }) {
    return AutoChargeRule(
      id: id ?? this.id,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      distributionType: distributionType ?? this.distributionType,
      frequency: frequency ?? this.frequency,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      isActive: isActive ?? this.isActive,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      nextRunAt: nextRunAt ?? this.nextRunAt,
    );
  }
}

class AutoNotificationRule {
  final String id;
  final String name;
  final String templateId;
  final String templateName;
  final NotificationChannel channel;
  final String targetFilter;
  final SchedulerFrequency frequency;
  final bool isActive;
  final DateTime? lastRunAt;
  final DateTime nextRunAt;

  const AutoNotificationRule({
    required this.id,
    required this.name,
    required this.templateId,
    required this.templateName,
    required this.channel,
    required this.targetFilter,
    required this.frequency,
    required this.isActive,
    required this.nextRunAt,
    this.lastRunAt,
  });

  AutoNotificationRule copyWith({
    String? id,
    String? name,
    String? templateId,
    String? templateName,
    NotificationChannel? channel,
    String? targetFilter,
    SchedulerFrequency? frequency,
    bool? isActive,
    DateTime? lastRunAt,
    DateTime? nextRunAt,
  }) {
    return AutoNotificationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      channel: channel ?? this.channel,
      targetFilter: targetFilter ?? this.targetFilter,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      nextRunAt: nextRunAt ?? this.nextRunAt,
    );
  }
}

class ImportPreviewRow {
  final int rowNumber;
  final String block;
  final String unitNo;
  final String ownerName;
  final String? tenantName;
  final double sqm;
  final ImportRowStatus status;
  final List<String> issues;

  const ImportPreviewRow({
    required this.rowNumber,
    required this.block,
    required this.unitNo,
    required this.ownerName,
    required this.tenantName,
    required this.sqm,
    required this.status,
    required this.issues,
  });

  ImportPreviewRow copyWith({
    int? rowNumber,
    String? block,
    String? unitNo,
    String? ownerName,
    String? tenantName,
    bool clearTenantName = false,
    double? sqm,
    ImportRowStatus? status,
    List<String>? issues,
  }) {
    return ImportPreviewRow(
      rowNumber: rowNumber ?? this.rowNumber,
      block: block ?? this.block,
      unitNo: unitNo ?? this.unitNo,
      ownerName: ownerName ?? this.ownerName,
      tenantName: clearTenantName ? null : (tenantName ?? this.tenantName),
      sqm: sqm ?? this.sqm,
      status: status ?? this.status,
      issues: issues ?? this.issues,
    );
  }
}

class ImportCommitSummary {
  final int inserted;
  final int updated;
  final int skipped;
  final int errors;

  const ImportCommitSummary({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.errors,
  });
}

class LegacyMemberRecord {
  final String id;
  final String fullName;
  final LegacyOccupancyType occupancyType;
  final String unitLabel;
  final DateTime moveInDate;
  final DateTime moveOutDate;
  final String reason;
  final String? phone;
  final String? note;

  const LegacyMemberRecord({
    required this.id,
    required this.fullName,
    required this.occupancyType,
    required this.unitLabel,
    required this.moveInDate,
    required this.moveOutDate,
    required this.reason,
    this.phone,
    this.note,
  });
}

class ManagerReportItem {
  final String id;
  final ReportTypeKey type;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;
  final Map<String, double> summary;

  const ManagerReportItem({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.summary,
  });
}

extension ChargeScopeLabel on ChargeScope {
  String get label {
    switch (this) {
      case ChargeScope.allUnits:
        return 'Tum Daireler';
      case ChargeScope.block:
        return 'Blok Bazli';
      case ChargeScope.unitGroup:
        return 'Daire Grubu';
      case ChargeScope.person:
        return 'Kisi Bazli';
      case ChargeScope.excelImport:
        return 'Excel';
      case ChargeScope.budgetBased:
        return 'Butce Bazli';
    }
  }
}

extension ChargeDistributionLabel on ChargeDistributionType {
  String get label {
    switch (this) {
      case ChargeDistributionType.equal:
        return 'Esit';
      case ChargeDistributionType.sqm:
        return 'm2';
      case ChargeDistributionType.fixed:
        return 'Sabit';
      case ChargeDistributionType.custom:
        return 'Ozel';
    }
  }
}

extension ChargeMainTypeLabel on ChargeMainType {
  String get label {
    switch (this) {
      case ChargeMainType.dues:
        return 'Aidat';
      case ChargeMainType.fuel:
        return 'Yakit';
      case ChargeMainType.fixture:
        return 'Demirbas';
      case ChargeMainType.maintenance:
        return 'Bakim Onarim';
      case ChargeMainType.personnel:
        return 'Personel';
      case ChargeMainType.operating:
        return 'Isletme';
      case ChargeMainType.reserveFund:
        return 'Yedek Butce';
      case ChargeMainType.other:
        return 'Diger';
    }
  }

  IconData get icon {
    switch (this) {
      case ChargeMainType.dues:
        return Icons.home_work_outlined;
      case ChargeMainType.fuel:
        return Icons.local_fire_department_outlined;
      case ChargeMainType.fixture:
        return Icons.build_circle_outlined;
      case ChargeMainType.maintenance:
        return Icons.handyman_outlined;
      case ChargeMainType.personnel:
        return Icons.badge_outlined;
      case ChargeMainType.operating:
        return Icons.settings_suggest_outlined;
      case ChargeMainType.reserveFund:
        return Icons.savings_outlined;
      case ChargeMainType.other:
        return Icons.category_outlined;
    }
  }
}

extension ChargeCalculationMethodLabel on ChargeCalculationMethod {
  String get label {
    switch (this) {
      case ChargeCalculationMethod.duesGroup:
        return 'Aidat Grubuna Gore Borclandir';
      case ChargeCalculationMethod.operatingProject:
        return 'Isletme Projesine Gore Borclandir';
      case ChargeCalculationMethod.manualAmount:
        return 'Tutar Girerek Borclandir';
      case ChargeCalculationMethod.bySquareMeter:
        return 'Metrekareye Gore Borclandir';
      case ChargeCalculationMethod.byLandShare:
        return 'Arsa Payina Gore Borclandir';
      case ChargeCalculationMethod.byPersonCount:
        return 'Kisi Sayisina Gore Borclandir';
      case ChargeCalculationMethod.equalShare:
        return 'Esit Paylasimli Borclandir';
    }
  }

  IconData get icon {
    switch (this) {
      case ChargeCalculationMethod.duesGroup:
        return Icons.folder_shared_outlined;
      case ChargeCalculationMethod.operatingProject:
        return Icons.assignment_outlined;
      case ChargeCalculationMethod.manualAmount:
        return Icons.edit_note_outlined;
      case ChargeCalculationMethod.bySquareMeter:
        return Icons.square_foot_outlined;
      case ChargeCalculationMethod.byLandShare:
        return Icons.landscape_outlined;
      case ChargeCalculationMethod.byPersonCount:
        return Icons.groups_outlined;
      case ChargeCalculationMethod.equalShare:
        return Icons.balance_outlined;
    }
  }
}

extension ChargeStatusLabel on ChargeBatchStatus {
  String get label {
    switch (this) {
      case ChargeBatchStatus.draft:
        return 'Taslak';
      case ChargeBatchStatus.posted:
        return 'Onayli';
      case ChargeBatchStatus.cancelled:
        return 'Iptal';
    }
  }

  Color get color {
    switch (this) {
      case ChargeBatchStatus.draft:
        return Colors.orange;
      case ChargeBatchStatus.posted:
        return Colors.green;
      case ChargeBatchStatus.cancelled:
        return Colors.red;
    }
  }
}

extension AllocationModeLabel on AllocationMode {
  String get label {
    switch (this) {
      case AllocationMode.oldestFirst:
        return 'En Eski Borc';
      case AllocationMode.newestFirst:
        return 'En Yeni Borc';
      case AllocationMode.manual:
        return 'Manuel';
    }
  }
}

extension MatchStatusLabel on MatchStatus {
  String get label {
    switch (this) {
      case MatchStatus.unmatched:
        return 'Eslesmedi';
      case MatchStatus.suggested:
        return 'Onerildi';
      case MatchStatus.matched:
        return 'Eslesti';
      case MatchStatus.ignored:
        return 'Yoksayildi';
    }
  }

  Color get color {
    switch (this) {
      case MatchStatus.unmatched:
        return Colors.orange;
      case MatchStatus.suggested:
        return Colors.blue;
      case MatchStatus.matched:
        return Colors.green;
      case MatchStatus.ignored:
        return Colors.grey;
    }
  }
}

extension NotificationChannelLabel on NotificationChannel {
  String get label {
    switch (this) {
      case NotificationChannel.app:
        return 'Uygulama';
      case NotificationChannel.sms:
        return 'SMS';
      case NotificationChannel.email:
        return 'E-Posta';
      case NotificationChannel.whatsapp:
        return 'WhatsApp';
    }
  }
}

extension TaskPriorityLabel on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Dusuk';
      case TaskPriority.medium:
        return 'Normal';
      case TaskPriority.high:
        return 'Yuksek';
      case TaskPriority.urgent:
        return 'Acil';
    }
  }
}

extension TaskStatusLabel on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.open:
        return 'Acik';
      case TaskStatus.inProgress:
        return 'Islemde';
      case TaskStatus.completed:
        return 'Tamamlandi';
      case TaskStatus.cancelled:
        return 'Iptal';
    }
  }
}

extension MeterTypeLabel on MeterType {
  String get label {
    switch (this) {
      case MeterType.hotWater:
        return 'Sicak Su';
      case MeterType.coldWater:
        return 'Soguk Su';
      case MeterType.electricity:
        return 'Elektrik';
      case MeterType.heatShare:
        return 'Pay Olcer';
    }
  }
}

extension MeterStatusLabel on MeterReadingStatus {
  String get label {
    switch (this) {
      case MeterReadingStatus.draft:
        return 'Taslak';
      case MeterReadingStatus.approved:
        return 'Onayli';
      case MeterReadingStatus.billed:
        return 'Faturalandi';
    }
  }
}

extension StaffRoleLabel on StaffRoleType {
  String get label {
    switch (this) {
      case StaffRoleType.manager:
        return 'Yonetici';
      case StaffRoleType.accountant:
        return 'Muhasebe';
      case StaffRoleType.security:
        return 'Guvenlik';
      case StaffRoleType.cleaning:
        return 'Temizlik';
      case StaffRoleType.technical:
        return 'Teknik';
    }
  }
}

extension LegacyOccupancyTypeLabel on LegacyOccupancyType {
  String get label {
    switch (this) {
      case LegacyOccupancyType.owner:
        return 'Eski Malik';
      case LegacyOccupancyType.tenant:
        return 'Eski Kiraci';
    }
  }
}

extension SchedulerFrequencyLabel on SchedulerFrequency {
  String get label {
    switch (this) {
      case SchedulerFrequency.daily:
        return 'Gunluk';
      case SchedulerFrequency.weekly:
        return 'Haftalik';
      case SchedulerFrequency.monthly:
        return 'Aylik';
    }
  }
}

extension ImportRowStatusLabel on ImportRowStatus {
  String get label {
    switch (this) {
      case ImportRowStatus.valid:
        return 'Gecerli';
      case ImportRowStatus.warning:
        return 'Uyarili';
      case ImportRowStatus.error:
        return 'Hatali';
    }
  }

  Color get color {
    switch (this) {
      case ImportRowStatus.valid:
        return Colors.green;
      case ImportRowStatus.warning:
        return Colors.orange;
      case ImportRowStatus.error:
        return Colors.red;
    }
  }
}

extension ReportTypeKeyLabel on ReportTypeKey {
  String get label {
    switch (this) {
      case ReportTypeKey.cashStatus:
        return 'Kasa Durum Raporu';
      case ReportTypeKey.monthlyIncomeExpense:
        return 'Aylik Gelir Gider';
      case ReportTypeKey.accrualMovements:
        return 'Tahakkuk Hareketleri';
      case ReportTypeKey.collection:
        return 'Tahsilat Raporu';
      case ReportTypeKey.unitStatement:
        return 'Daire Hesap Ekstresi';
      case ReportTypeKey.vendorStatement:
        return 'Cari Hesap Ekstresi';
      case ReportTypeKey.auditor:
        return 'Denetci Raporu';
      case ReportTypeKey.warningLetter:
        return 'Ihtar Yazisi';
      case ReportTypeKey.noDebt:
        return 'Borcu Yoktur';
      case ReportTypeKey.posBank:
        return 'POS / Banka Hareket';
      case ReportTypeKey.budgetComparison:
        return 'Butce Tahmini Fiili';
    }
  }
}
