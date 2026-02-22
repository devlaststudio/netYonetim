import 'package:flutter/material.dart';

import '../mock/manager_ops_mock_data.dart';
import '../models/manager/manager_models.dart';

class ManagerOpsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdatedAt;

  List<NotificationTemplate> _templates = [];
  List<NotificationDispatch> _dispatches = [];
  List<StaffRoleRecord> _staffRoles = [];
  List<TaskRecord> _tasks = [];
  List<DecisionRecord> _decisions = [];
  List<FileArchiveItem> _files = [];
  List<MeterReading> _meterReadings = [];
  List<CallLogRecord> _callLogs = [];
  List<AssetRecord> _assets = [];
  List<SiteUnitGroup> _unitGroups = [];
  List<LegacyMemberRecord> _legacyMembers = [];
  List<AutoNotificationRule> _autoNotificationRules = [];
  List<ImportPreviewRow> _importPreviewRows = [];
  String? _importSourceName;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdatedAt => _lastUpdatedAt;

  List<NotificationTemplate> get templates => _templates;
  List<NotificationDispatch> get dispatches => _dispatches;
  List<StaffRoleRecord> get staffRoles => _staffRoles;
  List<TaskRecord> get tasks => _tasks;
  List<DecisionRecord> get decisions => _decisions;
  List<FileArchiveItem> get files => _files;
  List<MeterReading> get meterReadings => _meterReadings;
  List<CallLogRecord> get callLogs => _callLogs;
  List<AssetRecord> get assets => _assets;
  List<SiteUnitGroup> get unitGroups => _unitGroups;
  List<LegacyMemberRecord> get legacyMembers => _legacyMembers;
  List<AutoNotificationRule> get autoNotificationRules =>
      _autoNotificationRules;
  List<ImportPreviewRow> get importPreviewRows => _importPreviewRows;
  String? get importSourceName => _importSourceName;
  int get importValidCount => _importPreviewRows
      .where((row) => row.status == ImportRowStatus.valid)
      .length;
  int get importWarningCount => _importPreviewRows
      .where((row) => row.status == ImportRowStatus.warning)
      .length;
  int get importErrorCount => _importPreviewRows
      .where((row) => row.status == ImportRowStatus.error)
      .length;

  Future<void> loadMockData() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 250));

    try {
      _templates = List<NotificationTemplate>.of(
        ManagerOpsMockData.getNotificationTemplates(),
      );
      _dispatches = List<NotificationDispatch>.of(
        ManagerOpsMockData.getNotificationDispatches(),
      );
      _staffRoles =
          List<StaffRoleRecord>.of(ManagerOpsMockData.getStaffRoles());
      _tasks = List<TaskRecord>.of(ManagerOpsMockData.getTasks());
      _decisions = List<DecisionRecord>.of(ManagerOpsMockData.getDecisions());
      _files = List<FileArchiveItem>.of(ManagerOpsMockData.getFileArchive());
      _meterReadings =
          List<MeterReading>.of(ManagerOpsMockData.getMeterReadings());
      _callLogs = List<CallLogRecord>.of(ManagerOpsMockData.getCallLogs());
      _assets = List<AssetRecord>.of(ManagerOpsMockData.getAssets());
      _unitGroups = List<SiteUnitGroup>.of(ManagerOpsMockData.getUnitGroups());
      _legacyMembers = List<LegacyMemberRecord>.of(
        ManagerOpsMockData.getLegacyMembers(),
      );
      _autoNotificationRules = List<AutoNotificationRule>.of(
        ManagerOpsMockData.getAutoNotificationRules(),
      );
      _importPreviewRows = [];
      _importSourceName = null;

      _errorMessage = null;
      _lastUpdatedAt = DateTime.now();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendNotification({
    required NotificationTemplate template,
    required String targetFilter,
    required int targetCount,
  }) async {
    final failedCount = targetCount > 0 ? (targetCount * 0.04).round() : 0;
    final sentCount = targetCount - failedCount;

    _dispatches.insert(
      0,
      NotificationDispatch(
        id: 'nd-${DateTime.now().millisecondsSinceEpoch}',
        templateId: template.id,
        templateName: template.name,
        targetFilter: targetFilter,
        targetCount: targetCount,
        sentCount: sentCount,
        failedCount: failedCount,
        createdAt: DateTime.now(),
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addAutoNotificationRule({
    required String name,
    required NotificationTemplate template,
    required String targetFilter,
    required SchedulerFrequency frequency,
  }) async {
    final now = DateTime.now();
    _autoNotificationRules.insert(
      0,
      AutoNotificationRule(
        id: 'anr-${now.millisecondsSinceEpoch}',
        name: name,
        templateId: template.id,
        templateName: template.name,
        channel: template.channel,
        targetFilter: targetFilter,
        frequency: frequency,
        isActive: true,
        nextRunAt: _nextRunFromFrequency(frequency, now),
      ),
    );

    _lastUpdatedAt = now;
    notifyListeners();
  }

  Future<void> toggleAutoNotificationRule(String ruleId, bool isActive) async {
    final index =
        _autoNotificationRules.indexWhere((rule) => rule.id == ruleId);
    if (index == -1) {
      return;
    }

    _autoNotificationRules[index] = _autoNotificationRules[index].copyWith(
      isActive: isActive,
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> runAutoNotificationRuleNow(String ruleId) async {
    final index =
        _autoNotificationRules.indexWhere((rule) => rule.id == ruleId);
    if (index == -1 || _templates.isEmpty) {
      return;
    }

    final rule = _autoNotificationRules[index];
    final template = _templates.firstWhere(
      (item) => item.id == rule.templateId,
      orElse: () => _templates.first,
    );
    final now = DateTime.now();

    await sendNotification(
      template: template,
      targetFilter: rule.targetFilter,
      targetCount: _estimateTargetCount(rule.targetFilter),
    );

    _autoNotificationRules[index] = rule.copyWith(
      templateName: template.name,
      channel: template.channel,
      lastRunAt: now,
      nextRunAt: _nextRunFromFrequency(rule.frequency, now),
    );

    _lastUpdatedAt = now;
    notifyListeners();
  }

  Future<void> addNotificationTemplate({
    required String name,
    required NotificationChannel channel,
    required String title,
    required String body,
  }) async {
    _templates.insert(
      0,
      NotificationTemplate(
        id: 'nt-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        channel: channel,
        title: title,
        body: body,
        variables: const ['adsoyad', 'tarih', 'tutar'],
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> updateStaffRole(StaffRoleRecord role) async {
    final index = _staffRoles.indexWhere((item) => item.id == role.id);
    if (index == -1) {
      return;
    }

    _staffRoles[index] = role;
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> createTask({
    required String title,
    required StaffRoleRecord assignee,
    required TaskPriority priority,
    required DateTime dueDate,
    required String notes,
  }) async {
    _tasks.insert(
      0,
      TaskRecord(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        assignedStaffId: assignee.id,
        assignedStaffName: assignee.fullName,
        priority: priority,
        status: TaskStatus.open,
        dueDate: dueDate,
        notes: notes,
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    _tasks[index] = _tasks[index].copyWith(status: status);
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addDecision({
    required String title,
    required String decisionNo,
    required String summary,
  }) async {
    _decisions.insert(
      0,
      DecisionRecord(
        id: 'dec-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        meetingDate: DateTime.now(),
        decisionNo: decisionNo,
        summary: summary,
        attachmentIds: const [],
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addFile({
    required String name,
    required String folder,
    required String uploadedBy,
  }) async {
    _files.insert(
      0,
      FileArchiveItem(
        id: 'file-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        folder: folder,
        uploadedAt: DateTime.now(),
        uploadedBy: uploadedBy,
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addMeterReading({
    required String unitId,
    required String unitLabel,
    required MeterType meterType,
    required String period,
    required double start,
    required double end,
  }) async {
    _meterReadings.insert(
      0,
      MeterReading(
        id: 'mr-${DateTime.now().millisecondsSinceEpoch}',
        unitId: unitId,
        unitLabel: unitLabel,
        meterType: meterType,
        period: period,
        startIndex: start,
        endIndex: end,
        consumption: end - start,
        status: MeterReadingStatus.approved,
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addCallLog({
    required String memberName,
    required String staffName,
    required String note,
  }) async {
    _callLogs.insert(
      0,
      CallLogRecord(
        id: 'call-${DateTime.now().millisecondsSinceEpoch}',
        memberId: 'member-manual',
        memberName: memberName,
        staffId: 'staff-manual',
        staffName: staffName,
        callDate: DateTime.now(),
        note: note,
        nextActionDate: DateTime.now().add(const Duration(days: 3)),
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addAsset({
    required String name,
    required String category,
    required String location,
  }) async {
    _assets.insert(
      0,
      AssetRecord(
        id: 'asset-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        category: category,
        location: location,
        status: 'Aktif',
        lastMaintenanceDate: DateTime.now(),
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> addUnitGroup(
      {required String name, required int unitCount}) async {
    _unitGroups.insert(
      0,
      SiteUnitGroup(
        id: 'grp-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        unitCount: unitCount,
      ),
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> prepareImportPreview({required String sourceName}) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 280));

    try {
      _importSourceName = sourceName;
      _importPreviewRows = List<ImportPreviewRow>.of(
        ManagerOpsMockData.getImportPreviewRows(),
      );
      _errorMessage = null;
      _lastUpdatedAt = DateTime.now();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateImportPreviewRow({
    required int rowNumber,
    required String block,
    required String unitNo,
    required String ownerName,
    required String? tenantName,
    required double sqm,
  }) async {
    final index =
        _importPreviewRows.indexWhere((row) => row.rowNumber == rowNumber);
    if (index == -1) {
      return;
    }

    _importPreviewRows[index] = _buildValidatedImportRow(
      rowNumber: rowNumber,
      block: block,
      unitNo: unitNo,
      ownerName: ownerName,
      tenantName: tenantName,
      sqm: sqm,
    );

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  void revalidateImportPreviewRows() {
    _importPreviewRows = _importPreviewRows
        .map(
          (row) => _buildValidatedImportRow(
            rowNumber: row.rowNumber,
            block: row.block,
            unitNo: row.unitNo,
            ownerName: row.ownerName,
            tenantName: row.tenantName,
            sqm: row.sqm,
          ),
        )
        .toList();

    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  Future<ImportCommitSummary> applyImportPreview({
    required bool includeWarnings,
  }) async {
    final validCount = importValidCount;
    final warningCount = importWarningCount;
    final errorCount = importErrorCount;

    final inserted = validCount + (includeWarnings ? warningCount : 0);
    final skipped = errorCount + (includeWarnings ? 0 : warningCount);
    final updated = inserted > 0 ? inserted ~/ 4 : 0;

    if (_unitGroups.isNotEmpty && inserted > 0) {
      final current = _unitGroups.first;
      _unitGroups[0] = SiteUnitGroup(
        id: current.id,
        name: current.name,
        unitCount: current.unitCount + inserted,
      );
    }

    _importPreviewRows = [];
    _importSourceName = null;
    _lastUpdatedAt = DateTime.now();
    notifyListeners();

    return ImportCommitSummary(
      inserted: inserted,
      updated: updated,
      skipped: skipped,
      errors: errorCount,
    );
  }

  void clearImportPreview() {
    _importPreviewRows = [];
    _importSourceName = null;
    _lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  DateTime _nextRunFromFrequency(
    SchedulerFrequency frequency,
    DateTime from,
  ) {
    switch (frequency) {
      case SchedulerFrequency.daily:
        return from.add(const Duration(days: 1));
      case SchedulerFrequency.weekly:
        return from.add(const Duration(days: 7));
      case SchedulerFrequency.monthly:
        return DateTime(from.year, from.month + 1, from.day);
    }
  }

  int _estimateTargetCount(String targetFilter) {
    switch (targetFilter) {
      case 'Tum Uyeler':
        return 180;
      case 'A Blok':
        return 60;
      case 'Kiracilar':
        return 72;
      case 'Borclu Uyeler':
      default:
        return 96;
    }
  }

  ImportPreviewRow _buildValidatedImportRow({
    required int rowNumber,
    required String block,
    required String unitNo,
    required String ownerName,
    required String? tenantName,
    required double sqm,
  }) {
    final cleanedBlock = block.trim();
    final cleanedUnitNo = unitNo.trim();
    final cleanedOwnerName = ownerName.trim();
    final cleanedTenantName = tenantName?.trim();

    final errorIssues = <String>[];
    final warningIssues = <String>[];

    if (cleanedBlock.isEmpty) {
      errorIssues.add('Blok alani zorunludur.');
    }
    if (cleanedUnitNo.isEmpty) {
      errorIssues.add('Daire numarasi zorunludur.');
    }
    if (cleanedOwnerName.isEmpty) {
      errorIssues.add('Malik adi zorunludur.');
    }
    if (sqm <= 0) {
      warningIssues
          .add('m2 alani bos veya sifir, varsayilan deger uygulanacak.');
    }
    if (cleanedTenantName == null || cleanedTenantName.isEmpty) {
      warningIssues.add('Kiraci bilgisi bos birakildi.');
    }

    if (errorIssues.isNotEmpty) {
      return ImportPreviewRow(
        rowNumber: rowNumber,
        block: cleanedBlock,
        unitNo: cleanedUnitNo,
        ownerName: cleanedOwnerName,
        tenantName: cleanedTenantName == null || cleanedTenantName.isEmpty
            ? null
            : cleanedTenantName,
        sqm: sqm,
        status: ImportRowStatus.error,
        issues: [...errorIssues, ...warningIssues],
      );
    }

    if (warningIssues.isNotEmpty) {
      return ImportPreviewRow(
        rowNumber: rowNumber,
        block: cleanedBlock,
        unitNo: cleanedUnitNo,
        ownerName: cleanedOwnerName,
        tenantName: cleanedTenantName == null || cleanedTenantName.isEmpty
            ? null
            : cleanedTenantName,
        sqm: sqm,
        status: ImportRowStatus.warning,
        issues: warningIssues,
      );
    }

    return ImportPreviewRow(
      rowNumber: rowNumber,
      block: cleanedBlock,
      unitNo: cleanedUnitNo,
      ownerName: cleanedOwnerName,
      tenantName: cleanedTenantName == null || cleanedTenantName.isEmpty
          ? null
          : cleanedTenantName,
      sqm: sqm,
      status: ImportRowStatus.valid,
      issues: const [],
    );
  }
}
