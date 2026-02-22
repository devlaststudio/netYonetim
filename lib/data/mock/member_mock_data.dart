/// Mock data for member list (Üye Listesi)
class MemberMockData {
  static List<MemberData> getMembers() {
    return [
      MemberData(
        id: 'member-001',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        block: 'A Blok',
        unitNo: '01',
        status: MemberStatus.malik,
        phone: '(532) 100-00-00',
        email: 'demo.a@yonetimcell.com',
        tcKimlik: '15713742864',
        gender: 'Erkek',
        education: 'Yüksek Lisans',
        profession: 'Avukat',
        plateNumber: '34 APS 6668',
        address: 'Altayçeşme Mah. Öz Sokak No:19...',
        balance: 0.00,
        aidatBalance: 500.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 2400.00,
        transactions: [
          MemberTransaction(
            date: DateTime(2017, 12, 12),
            dueDate: DateTime(2017, 12, 17),
            block: 'A Blok',
            unitNo: '01',
            description: 'Aidat',
            debit: 100.00,
            credit: 100.00,
            balance: 100.00,
          ),
        ],
        notes: [
          MemberNote(
            author: 'Mehmet Yılmaz',
            content: 'Professional lorem ipsum generator for typographers',
            date: DateTime(2017, 12, 20),
          ),
        ],
      ),
      MemberData(
        id: 'member-002',
        firstName: 'Murat',
        lastName: 'Kaya',
        block: 'A Blok',
        unitNo: '01',
        status: MemberStatus.kiraci,
        phone: '(533) 200-11-22',
        email: 'murat.kaya@email.com',
        tcKimlik: '28473651920',
        gender: 'Erkek',
        education: 'Lisans',
        profession: 'Mühendis',
        plateNumber: '34 MK 1234',
        address: 'Altayçeşme Mah. Öz Sokak No:19...',
        balance: 0.00,
        aidatBalance: 0.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 0.00,
        transactions: [],
        notes: [],
      ),
      MemberData(
        id: 'member-003',
        firstName: 'Zeynep',
        lastName: 'Demir',
        block: 'A Blok',
        unitNo: '02',
        status: MemberStatus.malik,
        phone: '(535) 333-44-55',
        email: 'zeynep.demir@email.com',
        tcKimlik: '39584762031',
        gender: 'Kadın',
        education: 'Lisans',
        profession: 'Doktor',
        plateNumber: '06 ZD 5678',
        address: 'Altayçeşme Mah. Gül Sokak No:5...',
        balance: 0.00,
        aidatBalance: 0.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 0.00,
        transactions: [],
        notes: [],
      ),
      MemberData(
        id: 'member-004',
        firstName: 'Mehmet',
        lastName: 'Şahin',
        block: 'A Blok',
        unitNo: '03',
        status: MemberStatus.malik,
        phone: '(536) 444-55-66',
        email: 'mehmet.sahin@email.com',
        tcKimlik: '40695873142',
        gender: 'Erkek',
        education: 'Doktora',
        profession: 'Akademisyen',
        plateNumber: '34 MS 9012',
        address: 'Altayçeşme Mah. Lale Sokak No:8...',
        balance: 0.00,
        aidatBalance: 0.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 0.00,
        transactions: [],
        notes: [],
      ),
      MemberData(
        id: 'member-005',
        firstName: 'Hüseyin',
        lastName: 'Yıldırım',
        block: 'A Blok',
        unitNo: '03',
        status: MemberStatus.kiraci,
        phone: '(537) 555-66-77',
        email: 'huseyin.y@email.com',
        tcKimlik: '51706984253',
        gender: 'Erkek',
        education: 'Lise',
        profession: 'Esnaf',
        plateNumber: '34 HY 3456',
        address: 'Altayçeşme Mah. Lale Sokak No:8...',
        balance: 0.00,
        aidatBalance: 0.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 0.00,
        transactions: [],
        notes: [],
      ),
      MemberData(
        id: 'member-006',
        firstName: 'Mustafa',
        lastName: 'Kılıç',
        block: 'A Blok',
        unitNo: '04',
        status: MemberStatus.malik,
        phone: '(538) 666-77-88',
        email: 'mustafa.kilic@email.com',
        tcKimlik: '62817095364',
        gender: 'Erkek',
        education: 'Lisans',
        profession: 'İşletmeci',
        plateNumber: '34 MK 7890',
        address: 'Altayçeşme Mah. Papatya Sokak No:3...',
        balance: 0.00,
        aidatBalance: 0.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 0.00,
        transactions: [],
        notes: [],
      ),
      MemberData(
        id: 'member-007',
        firstName: 'Fatma',
        lastName: 'Çelik',
        block: 'B Blok',
        unitNo: '01',
        status: MemberStatus.malik,
        phone: '(539) 777-88-99',
        email: 'fatma.celik@email.com',
        tcKimlik: '73928106475',
        gender: 'Kadın',
        education: 'Lisans',
        profession: 'Öğretmen',
        plateNumber: '34 FC 1122',
        address: 'Altayçeşme Mah. Menekşe Sokak No:12...',
        balance: 1250.00,
        aidatBalance: 850.00,
        yakitBalance: 200.00,
        demirbasBalance: 200.00,
        totalBalance: 1250.00,
        transactions: [
          MemberTransaction(
            date: DateTime(2026, 1, 10),
            dueDate: DateTime(2026, 1, 15),
            block: 'B Blok',
            unitNo: '01',
            description: 'Aidat',
            debit: 850.00,
            credit: 0.00,
            balance: 850.00,
          ),
          MemberTransaction(
            date: DateTime(2026, 1, 10),
            dueDate: DateTime(2026, 1, 20),
            block: 'B Blok',
            unitNo: '01',
            description: 'Yakıt Payı',
            debit: 200.00,
            credit: 0.00,
            balance: 200.00,
          ),
        ],
        notes: [],
      ),
      MemberData(
        id: 'member-008',
        firstName: 'Ali',
        lastName: 'Arslan',
        block: 'B Blok',
        unitNo: '02',
        status: MemberStatus.malik,
        phone: '(540) 888-99-00',
        email: 'ali.arslan@email.com',
        tcKimlik: '84039217586',
        gender: 'Erkek',
        education: 'Lisans',
        profession: 'Mimar',
        plateNumber: '34 AA 3344',
        address: 'Altayçeşme Mah. Menekşe Sokak No:14...',
        balance: 0.00,
        aidatBalance: 0.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 0.00,
        transactions: [],
        notes: [],
      ),
      MemberData(
        id: 'member-009',
        firstName: '',
        lastName: '',
        block: 'B Blok',
        unitNo: '03',
        status: MemberStatus.bosDaire,
        phone: '',
        email: '',
        tcKimlik: '',
        gender: '',
        education: '',
        profession: '',
        plateNumber: '',
        address: '',
        balance: 0.00,
        aidatBalance: 0.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 0.00,
        transactions: [],
        notes: [],
      ),
      MemberData(
        id: 'member-010',
        firstName: '',
        lastName: '',
        block: 'B Blok',
        unitNo: '04',
        status: MemberStatus.bosDaire,
        phone: '',
        email: '',
        tcKimlik: '',
        gender: '',
        education: '',
        profession: '',
        plateNumber: '',
        address: '',
        balance: 0.00,
        aidatBalance: 0.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 0.00,
        transactions: [],
        notes: [],
      ),
      // TEST DATA: Multi-property owner (Same TC as Ahmet Yılmaz)
      MemberData(
        id: 'member-011',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        block: 'D Blok',
        unitNo: '15',
        status: MemberStatus.malik,
        phone: '(532) 100-00-00',
        email: 'demo.a@yonetimcell.com',
        tcKimlik: '15713742864', // Same TC as member-001
        gender: 'Erkek',
        education: 'Yüksek Lisans',
        profession: 'Avukat',
        plateNumber: '34 APS 6668',
        address: 'Altayçeşme Mah. Öz Sokak No:19...',
        balance: 150.00,
        aidatBalance: 150.00,
        yakitBalance: 0.00,
        demirbasBalance: 0.00,
        totalBalance: 150.00,
        transactions: [],
        notes: [],
      ),
    ];
  }

  static List<String> getBlocks() {
    return ['TÜM BLOKLAR', 'A Blok', 'B Blok', 'C Blok', 'D Blok'];
  }

  static List<String> getStatusFilters() {
    return ['Aktif Malik ve Kiracı', 'Malik', 'Kiracı', 'Boş Daire', 'Tümü'];
  }
}

enum MemberStatus { malik, kiraci, bosDaire }

extension MemberStatusExtension on MemberStatus {
  String get displayName {
    switch (this) {
      case MemberStatus.malik:
        return 'Malik';
      case MemberStatus.kiraci:
        return 'Kiracı';
      case MemberStatus.bosDaire:
        return 'Boş Daire';
    }
  }
}

class MemberData {
  final String id;
  final String firstName;
  final String lastName;
  final String block;
  final String unitNo;
  final MemberStatus status;
  final String phone;
  final String email;
  final String tcKimlik;
  final String gender;
  final String education;
  final String profession;
  final String plateNumber;
  final String address;
  final double balance;
  final double aidatBalance;
  final double yakitBalance;
  final double demirbasBalance;
  final double totalBalance;
  final List<MemberTransaction> transactions;
  final List<MemberNote> notes;

  String get fullName => '$firstName $lastName';

  const MemberData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.block,
    required this.unitNo,
    required this.status,
    required this.phone,
    required this.email,
    required this.tcKimlik,
    required this.gender,
    required this.education,
    required this.profession,
    required this.plateNumber,
    required this.address,
    required this.balance,
    required this.aidatBalance,
    required this.yakitBalance,
    required this.demirbasBalance,
    required this.totalBalance,
    required this.transactions,
    required this.notes,
  });
}

class MemberTransaction {
  final DateTime date;
  final DateTime dueDate;
  final String block;
  final String unitNo;
  final String description;
  final double debit;
  final double credit;
  final double balance;

  const MemberTransaction({
    required this.date,
    required this.dueDate,
    required this.block,
    required this.unitNo,
    required this.description,
    required this.debit,
    required this.credit,
    required this.balance,
  });
}

class MemberNote {
  final String author;
  final String content;
  final DateTime date;

  const MemberNote({
    required this.author,
    required this.content,
    required this.date,
  });
}
