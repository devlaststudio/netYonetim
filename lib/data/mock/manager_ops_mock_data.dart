import '../models/manager/manager_models.dart';

class ManagerOpsMockData {
  static List<NotificationTemplate> getNotificationTemplates() {
    return const [
      NotificationTemplate(
        id: 'nt-1',
        name: 'Aylik Aidat Hatirlatma',
        channel: NotificationChannel.whatsapp,
        title: 'Aidat Hatirlatma',
        body: 'Sayin {adsoyad}, {donem} aidat borcunuz {tutar} TL.',
        variables: ['adsoyad', 'donem', 'tutar'],
      ),
      NotificationTemplate(
        id: 'nt-2',
        name: 'Toplanti Duyurusu',
        channel: NotificationChannel.app,
        title: 'Genel Kurul Bilgilendirme',
        body: '{tarih} tarihinde toplanti vardir.',
        variables: ['tarih'],
      ),
      NotificationTemplate(
        id: 'nt-3',
        name: 'Gecikme Uyarisi',
        channel: NotificationChannel.sms,
        title: 'Gecikme Bildirimi',
        body: '{adsoyad} gecikmis borcunuz bulunmaktadir.',
        variables: ['adsoyad'],
      ),
      NotificationTemplate(
        id: 'nt-4',
        name: 'E-Posta Bilgilendirme',
        channel: NotificationChannel.email,
        title: 'Finans Ozeti',
        body: '{donem} finans ozetiniz ektedir.',
        variables: ['donem'],
      ),
    ];
  }

  static List<NotificationDispatch> getNotificationDispatches() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      return NotificationDispatch(
        id: 'nd-$index',
        templateId: 'nt-${(index % 4) + 1}',
        templateName: getNotificationTemplates()[index % 4].name,
        targetFilter: index.isEven ? 'Borclu Uyeler' : 'A Blok',
        targetCount: 120 - index,
        sentCount: 115 - index,
        failedCount: 5,
        createdAt: now.subtract(Duration(hours: index * 5)),
      );
    });
  }

  static List<StaffRoleRecord> getStaffRoles() {
    return const [
      StaffRoleRecord(
        id: 'st-1',
        fullName: 'Ali Demir',
        role: StaffRoleType.manager,
        mobileVisible: true,
        permissions: ['dashboard', 'reports', 'collections', 'settings'],
      ),
      StaffRoleRecord(
        id: 'st-2',
        fullName: 'Seda Akin',
        role: StaffRoleType.accountant,
        mobileVisible: true,
        permissions: ['collections', 'expenses', 'statements'],
      ),
      StaffRoleRecord(
        id: 'st-3',
        fullName: 'Hasan Kara',
        role: StaffRoleType.security,
        mobileVisible: true,
        permissions: ['task-tracking', 'meter-reading'],
      ),
      StaffRoleRecord(
        id: 'st-4',
        fullName: 'Elif Yilmaz',
        role: StaffRoleType.cleaning,
        mobileVisible: false,
        permissions: ['task-tracking'],
      ),
      StaffRoleRecord(
        id: 'st-5',
        fullName: 'Murat Can',
        role: StaffRoleType.technical,
        mobileVisible: true,
        permissions: ['task-tracking', 'file-archive'],
      ),
    ];
  }

  static List<TaskRecord> getTasks() {
    final now = DateTime.now();
    final staff = getStaffRoles();
    return List.generate(15, (index) {
      final assignee = staff[index % staff.length];
      return TaskRecord(
        id: 'task-$index',
        title: index.isEven
            ? 'Asansor kontrolleri #${index + 1}'
            : 'Temizlik turu #${index + 1}',
        assignedStaffId: assignee.id,
        assignedStaffName: assignee.fullName,
        priority: TaskPriority.values[index % TaskPriority.values.length],
        status: TaskStatus.values[index % TaskStatus.values.length],
        dueDate: now.add(Duration(days: (index % 7) + 1)),
        notes: 'Saha notu $index',
      );
    });
  }

  static List<DecisionRecord> getDecisions() {
    final now = DateTime.now();
    return List.generate(10, (index) {
      return DecisionRecord(
        id: 'dec-$index',
        title: 'Yonetim Kurulu Karari ${index + 1}',
        meetingDate: now.subtract(Duration(days: index * 14)),
        decisionNo: 'YK-2026-${index + 1}',
        summary: 'Karar ozeti metni #${index + 1}',
        attachmentIds: ['file-${index + 1}', 'file-${index + 20}'],
      );
    });
  }

  static List<FileArchiveItem> getFileArchive() {
    final now = DateTime.now();
    const folders = ['Karar Defteri', 'Faturalar', 'Raporlar', 'Sozlesmeler'];
    return List.generate(18, (index) {
      return FileArchiveItem(
        id: 'file-$index',
        name: 'dokuman_${index + 1}.pdf',
        folder: folders[index % folders.length],
        uploadedAt: now.subtract(Duration(days: index * 2)),
        uploadedBy: index.isEven ? 'Ali Demir' : 'Seda Akin',
      );
    });
  }

  static List<MeterReading> getMeterReadings() {
    return List.generate(16, (index) {
      final start = 1000 + index * 24;
      final end = start + (20 + index % 8);
      return MeterReading(
        id: 'mr-$index',
        unitId: 'unit-${index % 8}',
        unitLabel: 'A Blok ${index % 8 + 1}',
        meterType: MeterType.values[index % MeterType.values.length],
        period: '2026-${((index % 12) + 1).toString().padLeft(2, '0')}',
        startIndex: start.toDouble(),
        endIndex: end.toDouble(),
        consumption: (end - start).toDouble(),
        status:
            MeterReadingStatus.values[index % MeterReadingStatus.values.length],
      );
    });
  }

  static List<CallLogRecord> getCallLogs() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      return CallLogRecord(
        id: 'call-$index',
        memberId: 'm-${index % 5}',
        memberName: index.isEven ? 'Ali Demir' : 'Ayse Yildiz',
        staffId: 'st-${(index % 4) + 1}',
        staffName: index.isEven ? 'Seda Akin' : 'Ali Demir',
        callDate: now.subtract(Duration(hours: index * 8)),
        note: 'Uyeye odeme hatirlatmasi yapildi. #$index',
        nextActionDate: now.add(Duration(days: index % 3)),
      );
    });
  }

  static List<AssetRecord> getAssets() {
    final now = DateTime.now();
    const categories = ['Asansor', 'Kamera', 'Jenerator', 'Pompa'];
    return List.generate(12, (index) {
      return AssetRecord(
        id: 'asset-$index',
        name: 'Demirbas ${index + 1}',
        category: categories[index % categories.length],
        location: index.isEven ? 'A Blok' : 'B Blok',
        status: index % 4 == 0 ? 'Bakimda' : 'Aktif',
        lastMaintenanceDate: now.subtract(Duration(days: index * 20)),
      );
    });
  }

  static List<SiteUnitGroup> getUnitGroups() {
    return const [
      SiteUnitGroup(id: 'grp-1', name: 'Tum Daireler', unitCount: 120),
      SiteUnitGroup(id: 'grp-2', name: 'Dukkanlar', unitCount: 14),
      SiteUnitGroup(id: 'grp-3', name: 'A Blok', unitCount: 30),
      SiteUnitGroup(id: 'grp-4', name: 'B Blok', unitCount: 30),
      SiteUnitGroup(id: 'grp-5', name: 'C Blok', unitCount: 30),
    ];
  }

  static List<AutoNotificationRule> getAutoNotificationRules() {
    final now = DateTime.now();
    return [
      AutoNotificationRule(
        id: 'anr-1',
        name: 'Aidat Vade Hatirlatma',
        templateId: 'nt-1',
        templateName: 'Aylik Aidat Hatirlatma',
        channel: NotificationChannel.whatsapp,
        targetFilter: 'Borclu Uyeler',
        frequency: SchedulerFrequency.weekly,
        isActive: true,
        lastRunAt: now.subtract(const Duration(days: 7)),
        nextRunAt: now.add(const Duration(days: 1)),
      ),
      AutoNotificationRule(
        id: 'anr-2',
        name: 'Toplanti Bilgilendirme',
        templateId: 'nt-2',
        templateName: 'Toplanti Duyurusu',
        channel: NotificationChannel.app,
        targetFilter: 'Tum Uyeler',
        frequency: SchedulerFrequency.monthly,
        isActive: true,
        lastRunAt: now.subtract(const Duration(days: 23)),
        nextRunAt: now.add(const Duration(days: 8)),
      ),
      AutoNotificationRule(
        id: 'anr-3',
        name: 'Gecikme Uyarisi',
        templateId: 'nt-3',
        templateName: 'Gecikme Uyarisi',
        channel: NotificationChannel.sms,
        targetFilter: 'Borclu Uyeler',
        frequency: SchedulerFrequency.daily,
        isActive: false,
        lastRunAt: now.subtract(const Duration(days: 2)),
        nextRunAt: now.add(const Duration(days: 1)),
      ),
    ];
  }

  static List<ImportPreviewRow> getImportPreviewRows() {
    return const [
      ImportPreviewRow(
        rowNumber: 2,
        block: 'A',
        unitNo: '1',
        ownerName: 'Ali Demir',
        tenantName: 'Ahmet Kaplan',
        sqm: 135.0,
        status: ImportRowStatus.valid,
        issues: [],
      ),
      ImportPreviewRow(
        rowNumber: 3,
        block: 'A',
        unitNo: '2',
        ownerName: 'Ayse Yildiz',
        tenantName: null,
        sqm: 128.0,
        status: ImportRowStatus.warning,
        issues: ['Kiraci adi bos, malik kaydi ile devam edilecek.'],
      ),
      ImportPreviewRow(
        rowNumber: 4,
        block: 'A',
        unitNo: '',
        ownerName: 'Mert Kaya',
        tenantName: null,
        sqm: 120.0,
        status: ImportRowStatus.error,
        issues: ['Daire numarasi zorunludur.'],
      ),
      ImportPreviewRow(
        rowNumber: 5,
        block: 'B',
        unitNo: '7',
        ownerName: 'Selin Acar',
        tenantName: 'Gizem Cakmak',
        sqm: 142.0,
        status: ImportRowStatus.valid,
        issues: [],
      ),
      ImportPreviewRow(
        rowNumber: 6,
        block: 'B',
        unitNo: '8',
        ownerName: '',
        tenantName: 'Burak Tezcan',
        sqm: 140.0,
        status: ImportRowStatus.error,
        issues: ['Malik adi zorunludur.'],
      ),
      ImportPreviewRow(
        rowNumber: 7,
        block: 'C',
        unitNo: '3',
        ownerName: 'Hasan Karaca',
        tenantName: null,
        sqm: 0,
        status: ImportRowStatus.warning,
        issues: ['m2 alani bos, varsayilan m2 kullanilacak.'],
      ),
      ImportPreviewRow(
        rowNumber: 8,
        block: 'C',
        unitNo: '4',
        ownerName: 'Derya Topal',
        tenantName: 'Cenk Er',
        sqm: 131.0,
        status: ImportRowStatus.valid,
        issues: [],
      ),
      ImportPreviewRow(
        rowNumber: 9,
        block: 'C',
        unitNo: '5',
        ownerName: 'Nihat Dogan',
        tenantName: null,
        sqm: 126.0,
        status: ImportRowStatus.valid,
        issues: [],
      ),
    ];
  }

  static List<LegacyMemberRecord> getLegacyMembers() {
    final now = DateTime.now();
    return [
      LegacyMemberRecord(
        id: 'lm-1',
        fullName: 'Sahin Ucar',
        occupancyType: LegacyOccupancyType.owner,
        unitLabel: 'A Blok 3',
        moveInDate: DateTime(now.year - 4, 3, 1),
        moveOutDate: DateTime(now.year - 1, 6, 14),
        reason: 'Daire satisi',
        phone: '0555 123 44 10',
        note: 'Aidat kapanis mutabakati tamamlandi.',
      ),
      LegacyMemberRecord(
        id: 'lm-2',
        fullName: 'Melek Duran',
        occupancyType: LegacyOccupancyType.tenant,
        unitLabel: 'A Blok 5',
        moveInDate: DateTime(now.year - 2, 9, 5),
        moveOutDate: DateTime(now.year - 1, 12, 2),
        reason: 'Kontrat bitisi',
        phone: '0532 987 11 67',
      ),
      LegacyMemberRecord(
        id: 'lm-3',
        fullName: 'Emre Yalin',
        occupancyType: LegacyOccupancyType.owner,
        unitLabel: 'B Blok 8',
        moveInDate: DateTime(now.year - 6, 2, 11),
        moveOutDate: DateTime(now.year - 2, 8, 27),
        reason: 'Tasima',
      ),
      LegacyMemberRecord(
        id: 'lm-4',
        fullName: 'Filiz Akkaya',
        occupancyType: LegacyOccupancyType.tenant,
        unitLabel: 'B Blok 9',
        moveInDate: DateTime(now.year - 1, 1, 10),
        moveOutDate: DateTime(now.year - 1, 11, 18),
        reason: 'Is degisikligi',
      ),
      LegacyMemberRecord(
        id: 'lm-5',
        fullName: 'Umit Yigit',
        occupancyType: LegacyOccupancyType.owner,
        unitLabel: 'C Blok 2',
        moveInDate: DateTime(now.year - 5, 7, 4),
        moveOutDate: DateTime(now.year - 3, 10, 30),
        reason: 'Miras devri',
      ),
      LegacyMemberRecord(
        id: 'lm-6',
        fullName: 'Pelin Keskin',
        occupancyType: LegacyOccupancyType.tenant,
        unitLabel: 'C Blok 6',
        moveInDate: DateTime(now.year - 2, 4, 22),
        moveOutDate: DateTime(now.year - 1, 5, 20),
        reason: 'Kontrat feshi',
      ),
      LegacyMemberRecord(
        id: 'lm-7',
        fullName: 'Halil Bas',
        occupancyType: LegacyOccupancyType.owner,
        unitLabel: 'A Blok 12',
        moveInDate: DateTime(now.year - 8, 6, 9),
        moveOutDate: DateTime(now.year - 4, 1, 15),
        reason: 'Portfoy degisimi',
      ),
      LegacyMemberRecord(
        id: 'lm-8',
        fullName: 'Asli Erim',
        occupancyType: LegacyOccupancyType.tenant,
        unitLabel: 'B Blok 4',
        moveInDate: DateTime(now.year - 3, 3, 3),
        moveOutDate: DateTime(now.year - 2, 2, 19),
        reason: 'Yurtdisi tasinma',
      ),
    ];
  }
}
