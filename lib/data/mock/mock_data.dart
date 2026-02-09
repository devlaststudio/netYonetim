import '../models/user_model.dart';
import '../models/due_model.dart';
import '../models/ticket_model.dart';
import '../models/announcement_model.dart';
import '../models/payment_model.dart';
import '../models/visitor_model.dart';
import '../models/technician_model.dart';
import '../models/service_request_model.dart';
import '../models/poll_model.dart';
import '../models/facility_model.dart';
import '../models/reservation_model.dart';
import '../models/site_model.dart';
import 'package:flutter/material.dart';

class MockData {
  // Demo kullanıcısı
  static final UserModel demoUser = UserModel(
    id: 'user-001',
    email: 'ahmet.yilmaz@email.com',
    firstName: 'Ahmet',
    lastName: 'Yılmaz',
    phone: '0532 123 45 67',
    role: UserRole.resident,
    siteId: 'site-001',
    unitId: 'unit-005',
    unitNo: '5',
    blockName: 'A',
  );

  // Demo yönetici
  static final UserModel demoManager = UserModel(
    id: 'user-002',
    email: 'mehmet.kaya@email.com',
    firstName: 'Mehmet',
    lastName: 'Kaya',
    phone: '0533 987 65 43',
    role: UserRole.manager,
    siteId: 'site-001',
  );

  // Demo admin (Site Yöneticisi)
  static final UserModel demoAdmin = UserModel(
    id: 'user-003',
    email: 'admin@siteyonet.com',
    firstName: 'Admin',
    lastName: 'User',
    phone: '0555 123 45 67',
    role: UserRole.admin,
    siteId: 'site-001',
  );

  // Site bilgisi
  static const String siteName = 'Yeşil Vadi Sitesi';
  static const int totalUnits = 120;
  static const int totalBlocks = 4;

  // Yöneticinin yetkili olduğu siteler (VT'den gelecekmiş gibi simüle)
  static List<SiteModel> getManagedSites() {
    return const [
      SiteModel(
        id: 'site-001',
        name: 'Yeşil Vadi Sitesi',
        address: 'Ataşehir, İstanbul',
        unitCount: 120,
        blockCount: 4,
      ),
      SiteModel(
        id: 'site-002',
        name: 'Mavi Koy Rezidans',
        address: 'Kadıköy, İstanbul',
        unitCount: 200,
        blockCount: 6,
      ),
      SiteModel(
        id: 'site-003',
        name: 'Güneş Evleri',
        address: 'Maltepe, İstanbul',
        unitCount: 80,
        blockCount: 2,
      ),
    ];
  }

  // Borçlar
  static List<DueModel> getDues() {
    return [
      DueModel(
        id: 'due-001',
        unitId: 'unit-005',
        type: DueType.aidat,
        amount: 850,
        paidAmount: 0,
        dueDate: DateTime(2026, 2, 10),
        description: 'Şubat 2026 Aidatı',
        periodMonth: 2,
        periodYear: 2026,
        status: DueStatus.pending,
      ),
      DueModel(
        id: 'due-002',
        unitId: 'unit-005',
        type: DueType.aidat,
        amount: 850,
        paidAmount: 0,
        dueDate: DateTime(2026, 1, 10),
        description: 'Ocak 2026 Aidatı',
        periodMonth: 1,
        periodYear: 2026,
        status: DueStatus.overdue,
        delayFee: 42.50,
      ),
      DueModel(
        id: 'due-003',
        unitId: 'unit-005',
        type: DueType.su,
        amount: 156,
        paidAmount: 0,
        dueDate: DateTime(2026, 2, 15),
        description: 'Ocak 2026 Su Tüketimi',
        periodMonth: 1,
        periodYear: 2026,
        status: DueStatus.pending,
      ),
      DueModel(
        id: 'due-004',
        unitId: 'unit-005',
        type: DueType.dogalgaz,
        amount: 320,
        paidAmount: 0,
        dueDate: DateTime(2026, 2, 20),
        description: 'Ocak 2026 Doğalgaz Payı',
        periodMonth: 1,
        periodYear: 2026,
        status: DueStatus.pending,
      ),
    ];
  }

  // Ödenmiş borçlar
  static List<DueModel> getPaidDues() {
    return [
      DueModel(
        id: 'due-010',
        unitId: 'unit-005',
        type: DueType.aidat,
        amount: 800,
        paidAmount: 800,
        dueDate: DateTime(2025, 12, 10),
        paidDate: DateTime(2025, 12, 8),
        description: 'Aralık 2025 Aidatı',
        periodMonth: 12,
        periodYear: 2025,
        status: DueStatus.paid,
      ),
      DueModel(
        id: 'due-011',
        unitId: 'unit-005',
        type: DueType.aidat,
        amount: 800,
        paidAmount: 800,
        dueDate: DateTime(2025, 11, 10),
        paidDate: DateTime(2025, 11, 5),
        description: 'Kasım 2025 Aidatı',
        periodMonth: 11,
        periodYear: 2025,
        status: DueStatus.paid,
      ),
      DueModel(
        id: 'due-012',
        unitId: 'unit-005',
        type: DueType.su,
        amount: 142,
        paidAmount: 142,
        dueDate: DateTime(2025, 12, 15),
        paidDate: DateTime(2025, 12, 12),
        description: 'Kasım 2025 Su Tüketimi',
        periodMonth: 11,
        periodYear: 2025,
        status: DueStatus.paid,
      ),
    ];
  }

  // Talepler
  static List<TicketModel> getTickets() {
    return [
      TicketModel(
        id: 'ticket-001',
        siteId: 'site-001',
        userId: 'user-001',
        userName: 'Ahmet Yılmaz',
        unitNo: 'A-5',
        category: TicketCategory.ariza,
        priority: TicketPriority.high,
        title: 'Asansör Arızası',
        description: 'A Blok asansörü 3. katta durdu ve açılmıyor.',
        status: TicketStatus.resolved,
        createdAt: DateTime(2026, 2, 2, 14, 30),
        resolvedAt: DateTime(2026, 2, 3, 10, 15),
        comments: [
          TicketComment(
            id: 'comment-001',
            ticketId: 'ticket-001',
            userId: 'user-002',
            userName: 'Yönetim',
            content: 'Asansör firması bilgilendirildi, yarın sabah gelecekler.',
            createdAt: DateTime(2026, 2, 2, 15, 0),
            isStaff: true,
          ),
          TicketComment(
            id: 'comment-002',
            ticketId: 'ticket-001',
            userId: 'user-002',
            userName: 'Yönetim',
            content: 'Arıza giderildi, asansör çalışır durumda.',
            createdAt: DateTime(2026, 2, 3, 10, 15),
            isStaff: true,
          ),
        ],
      ),
      TicketModel(
        id: 'ticket-002',
        siteId: 'site-001',
        userId: 'user-001',
        userName: 'Ahmet Yılmaz',
        unitNo: 'A-5',
        category: TicketCategory.temizlik,
        priority: TicketPriority.medium,
        title: 'Merdiven Temizliği',
        description: 'A Blok merdivenleri uzun süredir temizlenmedi.',
        status: TicketStatus.inProgress,
        createdAt: DateTime(2026, 2, 5, 9, 0),
        comments: [
          TicketComment(
            id: 'comment-003',
            ticketId: 'ticket-002',
            userId: 'user-002',
            userName: 'Yönetim',
            content: 'Temizlik ekibine iletildi, bugün içinde temizlenecek.',
            createdAt: DateTime(2026, 2, 5, 10, 30),
            isStaff: true,
          ),
        ],
      ),
      TicketModel(
        id: 'ticket-003',
        siteId: 'site-001',
        userId: 'user-001',
        userName: 'Ahmet Yılmaz',
        unitNo: 'A-5',
        category: TicketCategory.guvenlik,
        priority: TicketPriority.high,
        title: 'Otopark Aydınlatma',
        description: 'B Blok önündeki otopark aydınlatması yanmıyor.',
        status: TicketStatus.open,
        createdAt: DateTime(2026, 2, 6, 8, 0),
        comments: [],
      ),
    ];
  }

  // Duyurular
  static List<AnnouncementModel> getAnnouncements() {
    return [
      AnnouncementModel(
        id: 'ann-001',
        siteId: 'site-001',
        title: '🚰 Su Kesintisi Duyurusu',
        content: '''Sayın Site Sakinleri,

15 Şubat 2026 Cumartesi günü saat 09:00-17:00 arasında planlı su bakım çalışması nedeniyle sitemizde su kesintisi yaşanacaktır.

Lütfen gerekli tedbirlerinizi alınız.

Anlayışınız için teşekkür ederiz.

Site Yönetimi''',
        priority: AnnouncementPriority.important,
        publishDate: DateTime(2026, 2, 5, 10, 0),
        expireDate: DateTime(2026, 2, 16),
        createdBy: 'Yönetim',
      ),
      AnnouncementModel(
        id: 'ann-002',
        siteId: 'site-001',
        title: '🗳️ Olağan Genel Kurul Toplantısı',
        content: '''Değerli Kat Malikleri,

2026 yılı Olağan Genel Kurul Toplantımız aşağıdaki tarihte gerçekleştirilecektir:

📅 Tarih: 20 Şubat 2026, Cumartesi
🕐 Saat: 14:00
📍 Yer: Site Sosyal Tesisi

Gündem:
1. Açılış ve yoklama
2. 2025 yılı faaliyet raporu
3. 2025 yılı mali rapor
4. 2026 yılı bütçe görüşmesi
5. Yönetim kurulu seçimi
6. Dilek ve temenniler

Katılımınızı rica ederiz.

Site Yönetimi''',
        priority: AnnouncementPriority.urgent,
        publishDate: DateTime(2026, 2, 1, 9, 0),
        expireDate: DateTime(2026, 2, 21),
        createdBy: 'Yönetim',
      ),
      AnnouncementModel(
        id: 'ann-003',
        siteId: 'site-001',
        title: '🌳 Bahçe Düzenleme Çalışması',
        content: '''Sayın Sakinlerimiz,

Sitemizin ortak alanlarında bahçe düzenleme ve peyzaj çalışması başlamıştır. 

Çalışmalar 10-25 Şubat tarihleri arasında devam edecektir.

Bu süre zarfında oluşabilecek gürültü için anlayışınızı rica ederiz.

Site Yönetimi''',
        priority: AnnouncementPriority.normal,
        publishDate: DateTime(2026, 2, 4, 11, 0),
        createdBy: 'Yönetim',
      ),
    ];
  }

  // Ödeme geçmişi
  static List<PaymentModel> getPayments() {
    return [
      PaymentModel(
        id: 'pay-001',
        dueId: 'due-010',
        userId: 'user-001',
        amount: 800,
        method: PaymentMethod.creditCard,
        status: PaymentStatus.completed,
        paymentDate: DateTime(2025, 12, 8, 14, 30),
        transactionId: 'TRX-2025120801234',
        commissionAmount: 15.12,
        description: 'Aralık 2025 Aidatı',
      ),
      PaymentModel(
        id: 'pay-002',
        dueId: 'due-011',
        userId: 'user-001',
        amount: 800,
        method: PaymentMethod.bankTransfer,
        status: PaymentStatus.completed,
        paymentDate: DateTime(2025, 11, 5, 10, 15),
        transactionId: 'EFT-2025110512345',
        description: 'Kasım 2025 Aidatı',
      ),
      PaymentModel(
        id: 'pay-003',
        dueId: 'due-012',
        userId: 'user-001',
        amount: 142,
        method: PaymentMethod.creditCard,
        status: PaymentStatus.completed,
        paymentDate: DateTime(2025, 12, 12, 16, 45),
        transactionId: 'TRX-2025121256789',
        commissionAmount: 2.68,
        description: 'Kasım 2025 Su Tüketimi',
      ),
    ];
  }

  // Ziyaretçiler
  static List<VisitorModel> getVisitors() {
    return [
      VisitorModel(
        id: 'vis-001',
        residentId: 'user-001',
        guestName: 'Mehmet Yılmaz',
        plateNumber: '34 XYZ 78',
        expectedDate: DateTime.now().add(const Duration(hours: 4)),
        status: VisitorStatus.expected,
        note: 'Kargo getirecek',
      ),
      VisitorModel(
        id: 'vis-002',
        residentId: 'user-001',
        guestName: 'Ayşe Demir',
        plateNumber: null,
        expectedDate: DateTime.now().subtract(const Duration(days: 1)),
        status: VisitorStatus.left,
        entryTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        exitTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      ),
      VisitorModel(
        id: 'vis-003',
        residentId: 'user-001',
        guestName: 'mobilya tasimaciligi',
        plateNumber: '06 ABC 123',
        expectedDate: DateTime.now().add(const Duration(days: 1)),
        status: VisitorStatus.expected,
        note: 'Yeni koltuk takimi gelecek',
      ),
    ];
  }

  // Dashboard özet verileri
  static Map<String, dynamic> getDashboardSummary() {
    final dues = getDues();
    final totalDebt = dues.fold<double>(
      0,
      (sum, due) => sum + due.remainingAmount,
    );
    final overdueCount = dues.where((d) => d.isOverdue).length;
    final paidDues = getPaidDues();
    final totalPaid = paidDues.fold<double>(0, (sum, due) => sum + due.amount);

    return {
      'totalDebt': totalDebt,
      'overdueCount': overdueCount,
      'totalPaid': totalPaid,
      'pendingDuesCount': dues.length,
      'unreadAnnouncements': 2,
      'openTickets': getTickets()
          .where((t) => t.status == TicketStatus.open)
          .length,
    };
  }

  // Yönetici için özet veriler
  static Map<String, dynamic> getManagerDashboardSummary() {
    return {
      'totalCash': 145250.00,
      'collectionRate': 78,
      'openTickets': 12,
      'overdueUnits': 23,
      'monthlyIncome': 102450.00,
      'monthlyExpense': 87230.00,
      'totalUnits': 120,
      'occupiedUnits': 112,
    };
  }

  static List<TechnicianModel> getTechnicians() {
    return [
      TechnicianModel(
        id: 'tech-001',
        name: 'Ahmet Yılmaz',
        category: TechnicianCategory.plumbing,
        photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        rating: 4.8,
        reviewCount: 124,
        phoneNumber: '0532 111 2233',
        biography:
            '20 yıllık deneyimli su tesisatçısı. Patlak boru, tıkalı gider, musluk montajı konularında uzman.',
        skills: ['Sıhhi Tesisat', 'Kalorifer Tesisatı', 'Su Kaçağı Tespiti'],
        reviews: [
          ReviewModel(
            id: 'rev-001',
            userId: 'usr-99',
            userName: 'Mehmet K.',
            rating: 5.0,
            comment: 'Çok hızlı geldi, sorunu hemen çözdü. Teşekkürler.',
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ReviewModel(
            id: 'rev-002',
            userId: 'usr-98',
            userName: 'Ayşe T.',
            rating: 4.5,
            comment: 'İşçiliği temiz, ancak biraz geç kaldı.',
            date: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
      ),
      TechnicianModel(
        id: 'tech-002',
        name: 'Mustafa Demir',
        category: TechnicianCategory.electric,
        photoUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
        rating: 4.2,
        reviewCount: 56,
        phoneNumber: '0533 444 5566',
        biography:
            'Elektrik tesisatı, avize montajı, sigorta değişimi itina ile yapılır.',
        skills: ['Elektrik Tesisatı', 'Aydınlatma', 'Sigorta Arızası'],
        reviews: [
          ReviewModel(
            id: 'rev-003',
            userId: 'usr-97',
            userName: 'Canan B.',
            rating: 4.0,
            comment: 'Sorunu çözdü ellerine sağlık.',
            date: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      ),
      TechnicianModel(
        id: 'tech-003',
        name: 'Ayten Çelik',
        category: TechnicianCategory.cleaning,
        photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        rating: 4.9,
        reviewCount: 200,
        phoneNumber: '0555 777 8899',
        biography:
            'Ev temizliği, inşaat sonrası temizlik, ofis temizliği hizmetleri.',
        skills: ['Genel Temizlik', 'Cam Temizliği', 'İnşaat Sonrası'],
        reviews: [
          ReviewModel(
            id: 'rev-004',
            userId: 'usr-96',
            userName: 'Selin Y.',
            rating: 5.0,
            comment: 'Evim mis gibi oldu, Ayten hanım harika.',
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      TechnicianModel(
        id: 'tech-004',
        name: 'Kemal Usta',
        category: TechnicianCategory.painting,
        photoUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
        rating: 4.7,
        reviewCount: 45,
        phoneNumber: '0544 333 2211',
        biography:
            'Boya, badana, alçı, kartonpiyer işleriniz itina ile yapılır.',
        skills: ['Boya Badana', 'Alçıpan', 'Duvar Kağıdı'],
        reviews: [],
      ),
    ];
  }

  static List<ServiceRequestModel> getServiceRequests() {
    return [
      ServiceRequestModel(
        id: 'sr-001',
        residentId: 'user-001',
        technicianId: 'tech-001',
        categoryId: 'plumbing',
        description: 'Mutfak musluğu damlatıyor, contası değişmeli.',
        status: ServiceRequestStatus.completed,
        requestDate: DateTime.now().subtract(const Duration(days: 15)),
        appointmentDate: DateTime.now().subtract(const Duration(days: 14)),
        rating: 5.0,
        reviewComment: 'Teşekkürler usta.',
      ),
    ];
  }

  static List<PollModel> getPolls() {
    return [
      PollModel(
        id: 'poll-001',
        title: 'Site Bahçesi Düzenlemesi',
        description:
            'Site bahçesinin daha kullanışlı hale getirilmesi için hangisine öncelik verilmeli?',
        endDate: DateTime.now().add(const Duration(days: 5)),
        options: [
          PollOption(
            id: 'opt-1',
            text: 'Çocuk Parkı Genişletilsin',
            voteCount: 15,
          ),
          PollOption(
            id: 'opt-2',
            text: 'Kamelya Sayısı Arttırılsın',
            voteCount: 42,
          ),
          PollOption(
            id: 'opt-3',
            text: 'Spor Aletleri Eklensin',
            voteCount: 28,
          ),
          PollOption(id: 'opt-4', text: 'Mevcut Durum Korunsun', voteCount: 5),
        ],
      ),
      PollModel(
        id: 'poll-002',
        title: 'Havuz Kapanış Saati',
        description: 'Yaz sezonunda havuzun kapanış saati kaç olmalı?',
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        isActive: false,
        hasVoted: true,
        selectedOptionId: 'opt-22',
        options: [
          PollOption(id: 'opt-21', text: '20:00', voteCount: 10),
          PollOption(id: 'opt-22', text: '21:00', voteCount: 55),
          PollOption(id: 'opt-23', text: '22:00', voteCount: 35),
        ],
      ),
    ];
  }

  static List<FacilityModel> getFacilities() {
    return [
      const FacilityModel(
        id: 'fac-1',
        name: 'Spor Salonu',
        type: FacilityType.facility,
        capacity: 20,
        photoUrl:
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
        description: 'Modern ekipmanlarla donatılmış fitness merkezi.',
        openTime: TimeOfDay(hour: 7, minute: 0),
        closeTime: TimeOfDay(hour: 23, minute: 0),
      ),
      const FacilityModel(
        id: 'fac-2',
        name: 'Tenis Kortu',
        type: FacilityType.facility,
        capacity: 4,
        photoUrl:
            'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?q=80&w=1470&auto=format&fit=crop',
        description: 'Profesyonel zeminli açık hava tenis kortu.',
        openTime: TimeOfDay(hour: 8, minute: 0),
        closeTime: TimeOfDay(hour: 22, minute: 0),
      ),
      const FacilityModel(
        id: 'evt-1',
        name: 'Film Gecesi: Inception',
        type: FacilityType.event,
        capacity: 30,
        photoUrl:
            'https://images.unsplash.com/photo-1517604931442-710e8e9993ec?q=80&w=1336&auto=format&fit=crop',
        description: 'Sinema odasında patlamış mısır eşliğinde film keyfi.',
        openTime: TimeOfDay(hour: 21, minute: 0),
        closeTime: TimeOfDay(hour: 23, minute: 30),
      ),
      const FacilityModel(
        id: 'evt-2',
        name: 'Akşam Yoga Dersi',
        type: FacilityType.event,
        capacity: 15,
        photoUrl:
            'https://images.unsplash.com/photo-1599447421405-0c325d2a9f46?q=80&w=1470&auto=format&fit=crop',
        description: 'Profesyonel eğitmen eşliğinde rahatlama seansı.',
        openTime: TimeOfDay(hour: 19, minute: 0),
        closeTime: TimeOfDay(hour: 20, minute: 0),
      ),
    ];
  }

  static List<ReservationModel> getReservations() {
    return [
      ReservationModel(
        id: 'res-001',
        facilityId: 'fac-1',
        facilityName: 'Spor Salonu',
        residentId: demoUser.id,
        startTime: DateTime.now().subtract(
          const Duration(days: 2, hours: 4),
        ), // Past
        durationMinutes: 60,
        status: ReservationStatus.completed,
      ),
    ];
  }
}
