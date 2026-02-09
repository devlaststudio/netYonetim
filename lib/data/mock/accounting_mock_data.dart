import '../models/account_model.dart';
import '../models/accounting_entry_model.dart';
import '../models/budget_model.dart';
import '../models/financial_report_model.dart';

class AccountingMockData {
  /// KMK Uyumlu Hesap Planı
  static List<AccountModel> getChartOfAccounts() {
    final now = DateTime.now();

    return [
      // ==================== GELİRLER ====================
      AccountModel(
        id: 'acc-1',
        code: '1',
        name: 'GELİRLER',
        type: AccountType.income,
        balance: 0,
        createdAt: now,
      ),

      // 1.1 Aidat Gelirleri
      AccountModel(
        id: 'acc-1.1',
        code: '1.1',
        name: 'Aidat Gelirleri',
        type: AccountType.income,
        parentId: 'acc-1',
        parentCode: '1',
        balance: 0,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.1.1',
        code: '1.1.1',
        name: 'Normal Aidat',
        type: AccountType.income,
        parentId: 'acc-1.1',
        parentCode: '1.1',
        balance: 185000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.1.2',
        code: '1.1.2',
        name: 'Ek Aidat',
        type: AccountType.income,
        parentId: 'acc-1.1',
        parentCode: '1.1',
        balance: 25000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.1.3',
        code: '1.1.3',
        name: 'Demirbaş Aidatı',
        type: AccountType.income,
        parentId: 'acc-1.1',
        parentCode: '1.1',
        balance: 15000,
        createdAt: now,
      ),

      // 1.2 Tüketim Gelirleri
      AccountModel(
        id: 'acc-1.2',
        code: '1.2',
        name: 'Tüketim Gelirleri',
        type: AccountType.income,
        parentId: 'acc-1',
        parentCode: '1',
        balance: 0,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.2.1',
        code: '1.2.1',
        name: 'Su Bedeli',
        type: AccountType.income,
        parentId: 'acc-1.2',
        parentCode: '1.2',
        balance: 42000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.2.2',
        code: '1.2.2',
        name: 'Elektrik Bedeli',
        type: AccountType.income,
        parentId: 'acc-1.2',
        parentCode: '1.2',
        balance: 38000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.2.3',
        code: '1.2.3',
        name: 'Doğalgaz Bedeli',
        type: AccountType.income,
        parentId: 'acc-1.2',
        parentCode: '1.2',
        balance: 55000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.2.4',
        code: '1.2.4',
        name: 'Isıtma Bedeli',
        type: AccountType.income,
        parentId: 'acc-1.2',
        parentCode: '1.2',
        balance: 48000,
        createdAt: now,
      ),

      // 1.3 Diğer Gelirler
      AccountModel(
        id: 'acc-1.3',
        code: '1.3',
        name: 'Diğer Gelirler',
        type: AccountType.income,
        parentId: 'acc-1',
        parentCode: '1',
        balance: 0,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.3.1',
        code: '1.3.1',
        name: 'Kira Gelirleri',
        type: AccountType.income,
        parentId: 'acc-1.3',
        parentCode: '1.3',
        balance: 12000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.3.2',
        code: '1.3.2',
        name: 'Gecikme Tazminatları',
        type: AccountType.income,
        parentId: 'acc-1.3',
        parentCode: '1.3',
        balance: 8500,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.3.3',
        code: '1.3.3',
        name: 'Reklam Gelirleri',
        type: AccountType.income,
        parentId: 'acc-1.3',
        parentCode: '1.3',
        balance: 5000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-1.3.4',
        code: '1.3.4',
        name: 'Faiz Gelirleri',
        type: AccountType.income,
        parentId: 'acc-1.3',
        parentCode: '1.3',
        balance: 3200,
        createdAt: now,
      ),

      // ==================== GİDERLER ====================
      AccountModel(
        id: 'acc-2',
        code: '2',
        name: 'GİDERLER',
        type: AccountType.expense,
        balance: 0,
        createdAt: now,
      ),

      // 2.1 Personel Giderleri
      AccountModel(
        id: 'acc-2.1',
        code: '2.1',
        name: 'Personel Giderleri',
        type: AccountType.expense,
        parentId: 'acc-2',
        parentCode: '2',
        balance: 0,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.1.1',
        code: '2.1.1',
        name: 'Ücretler',
        type: AccountType.expense,
        parentId: 'acc-2.1',
        parentCode: '2.1',
        balance: 95000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.1.2',
        code: '2.1.2',
        name: 'SGK Primleri',
        type: AccountType.expense,
        parentId: 'acc-2.1',
        parentCode: '2.1',
        balance: 28500,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.1.3',
        code: '2.1.3',
        name: 'İşsizlik Sigortası',
        type: AccountType.expense,
        parentId: 'acc-2.1',
        parentCode: '2.1',
        balance: 3800,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.1.4',
        code: '2.1.4',
        name: 'Kıdem/İhbar Karşılıkları',
        type: AccountType.expense,
        parentId: 'acc-2.1',
        parentCode: '2.1',
        balance: 15000,
        createdAt: now,
      ),

      // 2.2 Bakım Onarım Giderleri
      AccountModel(
        id: 'acc-2.2',
        code: '2.2',
        name: 'Bakım Onarım Giderleri',
        type: AccountType.expense,
        parentId: 'acc-2',
        parentCode: '2',
        balance: 0,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.2.1',
        code: '2.2.1',
        name: 'Asansör Bakımı',
        type: AccountType.expense,
        parentId: 'acc-2.2',
        parentCode: '2.2',
        balance: 18000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.2.2',
        code: '2.2.2',
        name: 'Bahçe Bakımı',
        type: AccountType.expense,
        parentId: 'acc-2.2',
        parentCode: '2.2',
        balance: 12000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.2.3',
        code: '2.2.3',
        name: 'Temizlik Malzemeleri',
        type: AccountType.expense,
        parentId: 'acc-2.2',
        parentCode: '2.2',
        balance: 8500,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.2.4',
        code: '2.2.4',
        name: 'Genel Onarımlar',
        type: AccountType.expense,
        parentId: 'acc-2.2',
        parentCode: '2.2',
        balance: 25000,
        createdAt: now,
      ),

      // 2.3 Ortak Alan Giderleri
      AccountModel(
        id: 'acc-2.3',
        code: '2.3',
        name: 'Ortak Alan Giderleri',
        type: AccountType.expense,
        parentId: 'acc-2',
        parentCode: '2',
        balance: 0,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.3.1',
        code: '2.3.1',
        name: 'Elektrik',
        type: AccountType.expense,
        parentId: 'acc-2.3',
        parentCode: '2.3',
        balance: 35000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.3.2',
        code: '2.3.2',
        name: 'Su',
        type: AccountType.expense,
        parentId: 'acc-2.3',
        parentCode: '2.3',
        balance: 22000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.3.3',
        code: '2.3.3',
        name: 'Doğalgaz',
        type: AccountType.expense,
        parentId: 'acc-2.3',
        parentCode: '2.3',
        balance: 42000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.3.4',
        code: '2.3.4',
        name: 'İnternet',
        type: AccountType.expense,
        parentId: 'acc-2.3',
        parentCode: '2.3',
        balance: 4500,
        createdAt: now,
      ),

      // 2.4-2.7 Diğer Giderler
      AccountModel(
        id: 'acc-2.4',
        code: '2.4',
        name: 'Güvenlik Giderleri',
        type: AccountType.expense,
        parentId: 'acc-2',
        parentCode: '2',
        balance: 45000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.5',
        code: '2.5',
        name: 'Sigorta Giderleri',
        type: AccountType.expense,
        parentId: 'acc-2',
        parentCode: '2',
        balance: 28000,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.6',
        code: '2.6',
        name: 'Yönetim Giderleri',
        type: AccountType.expense,
        parentId: 'acc-2',
        parentCode: '2',
        balance: 18500,
        createdAt: now,
      ),
      AccountModel(
        id: 'acc-2.7',
        code: '2.7',
        name: 'Diğer Giderler',
        type: AccountType.expense,
        parentId: 'acc-2',
        parentCode: '2',
        balance: 12000,
        createdAt: now,
      ),
    ];
  }

  /// Örnek Muhasebe Kayıtları
  static List<AccountingEntryModel> getAccountingEntries() {
    final now = DateTime.now();

    return [
      // Gelir Kayıtları
      AccountingEntryModel(
        id: 'entry-1',
        accountId: 'acc-1.1.1',
        accountCode: '1.1.1',
        accountName: 'Normal Aidat',
        entryType: EntryType.income,
        amount: 185000,
        transactionDate: DateTime(now.year, now.month, 1),
        description: '${now.month}/${now.year} Aylık Aidat Tahsilatı',
        documentNumber:
            'MAK-${now.year}${now.month.toString().padLeft(2, '0')}-001',
        paymentMethod: PaymentMethodType.bankTransfer,
        createdBy: 'admin-1',
        createdAt: DateTime(now.year, now.month, 5),
      ),
      AccountingEntryModel(
        id: 'entry-2',
        accountId: 'acc-1.2.1',
        accountCode: '1.2.1',
        accountName: 'Su Bedeli',
        entryType: EntryType.income,
        amount: 42000,
        transactionDate: DateTime(now.year, now.month, 10),
        description: 'Su Faturası Tahsilatı',
        documentNumber:
            'MAK-${now.year}${now.month.toString().padLeft(2, '0')}-015',
        paymentMethod: PaymentMethodType.bankTransfer,
        createdBy: 'admin-1',
        createdAt: DateTime(now.year, now.month, 10),
      ),
      AccountingEntryModel(
        id: 'entry-3',
        accountId: 'acc-1.3.2',
        accountCode: '1.3.2',
        accountName: 'Gecikme Tazminatları',
        entryType: EntryType.income,
        amount: 8500,
        transactionDate: DateTime(now.year, now.month, 15),
        description: 'Geciken Aidat Gecikme Bedeli',
        documentNumber:
            'MAK-${now.year}${now.month.toString().padLeft(2, '0')}-022',
        reference: 'A-12, B-5, C-8',
        paymentMethod: PaymentMethodType.creditCard,
        createdBy: 'admin-1',
        createdAt: DateTime(now.year, now.month, 15),
      ),

      // Gider Kayıtları
      AccountingEntryModel(
        id: 'entry-4',
        accountId: 'acc-2.1.1',
        accountCode: '2.1.1',
        accountName: 'Ücretler',
        entryType: EntryType.expense,
        amount: 95000,
        transactionDate: DateTime(now.year, now.month, 1),
        description: 'Personel Maaş Ödemesi',
        documentNumber:
            'ODM-${now.year}${now.month.toString().padLeft(2, '0')}-001',
        paymentMethod: PaymentMethodType.bankTransfer,
        createdBy: 'admin-1',
        createdAt: DateTime(now.year, now.month, 1),
      ),
      AccountingEntryModel(
        id: 'entry-5',
        accountId: 'acc-2.2.1',
        accountCode: '2.2.1',
        accountName: 'Asansör Bakımı',
        entryType: EntryType.expense,
        amount: 18000,
        transactionDate: DateTime(now.year, now.month, 12),
        description: 'Asansör Bakım Hizmeti',
        documentNumber:
            'ODM-${now.year}${now.month.toString().padLeft(2, '0')}-008',
        reference: 'FATURA-AS-2024-123',
        paymentMethod: PaymentMethodType.bankTransfer,
        createdBy: 'admin-1',
        createdAt: DateTime(now.year, now.month, 12),
      ),
      AccountingEntryModel(
        id: 'entry-6',
        accountId: 'acc-2.3.1',
        accountCode: '2.3.1',
        accountName: 'Elektrik',
        entryType: EntryType.expense,
        amount: 35000,
        transactionDate: DateTime(now.year, now.month, 20),
        description: 'Ortak Alan Elektrik Faturası',
        documentNumber:
            'ODM-${now.year}${now.month.toString().padLeft(2, '0')}-015',
        reference: 'BEDAŞ-${now.year}${now.month}',
        paymentMethod: PaymentMethodType.bankTransfer,
        createdBy: 'admin-1',
        createdAt: DateTime(now.year, now.month, 20),
      ),
      AccountingEntryModel(
        id: 'entry-7',
        accountId: 'acc-2.4',
        accountCode: '2.4',
        accountName: 'Güvenlik Giderleri',
        entryType: EntryType.expense,
        amount: 45000,
        transactionDate: DateTime(now.year, now.month, 1),
        description: 'Güvenlik Firması Aylık Bedeli',
        documentNumber:
            'ODM-${now.year}${now.month.toString().padLeft(2, '0')}-002',
        reference: 'SÖZLEŞME-GÜV-2024',
        paymentMethod: PaymentMethodType.bankTransfer,
        createdBy: 'admin-1',
        createdAt: DateTime(now.year, now.month, 1),
      ),
    ];
  }

  /// Örnek Bütçe
  static List<BudgetModel> getBudgets() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1);
    final endDate = DateTime(now.year, 12, 31);

    return [
      BudgetModel(
        id: 'budget-2024',
        name: '2024 Yıllık Bütçe',
        period: BudgetPeriod.yearly,
        year: now.year,
        status: BudgetStatus.active,
        startDate: startDate,
        endDate: endDate,
        notes: 'Site işletme projesi kapsamında hazırlanmıştır.',
        createdBy: 'admin-1',
        createdAt: startDate,
        items: [
          // Gelir Kalemleri
          BudgetItem(
            id: 'bi-1',
            accountId: 'acc-1.1.1',
            accountCode: '1.1.1',
            accountName: 'Normal Aidat',
            plannedAmount: 2400000,
            actualAmount: 1850000,
          ),
          BudgetItem(
            id: 'bi-2',
            accountId: 'acc-1.2.1',
            accountCode: '1.2.1',
            accountName: 'Su Bedeli',
            plannedAmount: 480000,
            actualAmount: 420000,
          ),
          BudgetItem(
            id: 'bi-3',
            accountId: 'acc-1.2.2',
            accountCode: '1.2.2',
            accountName: 'Elektrik Bedeli',
            plannedAmount: 450000,
            actualAmount: 380000,
          ),

          // Gider Kalemleri
          BudgetItem(
            id: 'bi-4',
            accountId: 'acc-2.1.1',
            accountCode: '2.1.1',
            accountName: 'Ücretler',
            plannedAmount: 1200000,
            actualAmount: 950000,
          ),
          BudgetItem(
            id: 'bi-5',
            accountId: 'acc-2.2.1',
            accountCode: '2.2.1',
            accountName: 'Asansör Bakımı',
            plannedAmount: 240000,
            actualAmount: 180000,
          ),
          BudgetItem(
            id: 'bi-6',
            accountId: 'acc-2.3.1',
            accountCode: '2.3.1',
            accountName: 'Elektrik',
            plannedAmount: 420000,
            actualAmount: 350000,
          ),
          BudgetItem(
            id: 'bi-7',
            accountId: 'acc-2.4',
            accountCode: '2.4',
            accountName: 'Güvenlik Giderleri',
            plannedAmount: 600000,
            actualAmount: 450000,
          ),
        ],
      ),
    ];
  }

  /// Örnek Mali Raporlar
  static List<FinancialReportModel> getFinancialReports() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month, now.day);

    return [
      FinancialReportModel(
        id: 'report-1',
        type: ReportType.incomeStatement,
        period: ReportPeriod.monthly,
        startDate: startDate,
        endDate: endDate,
        generatedAt: now,
        generatedBy: 'admin-1',
        summary: ReportSummary(
          totalIncome: 436700,
          totalExpense: 386300,
          netIncome: 50400,
          transactionCount: 7,
          categoryBreakdown: {
            'Aidat Gelirleri': 225000,
            'Tüketim Gelirleri': 183000,
            'Diğer Gelirler': 28700,
            'Personel Giderleri': 142300,
            'Bakım Onarım': 63500,
            'Ortak Alan Giderleri': 103500,
            'Diğer': 77000,
          },
        ),
        data: {
          'title': '${now.month}/${now.year} Gelir-Gider Tablosu',
          'incomeItems': [
            {'name': 'Normal Aidat', 'amount': 185000},
            {'name': 'Ek Aidat', 'amount': 25000},
            {'name': 'Su Bedeli', 'amount': 42000},
            {'name': 'Elektrik Bedeli', 'amount': 38000},
            {'name': 'Gecikme Tazminatları', 'amount': 8500},
          ],
          'expenseItems': [
            {'name': 'Ücretler', 'amount': 95000},
            {'name': 'SGK Primleri', 'amount': 28500},
            {'name': 'Asansör Bakımı', 'amount': 18000},
            {'name': 'Elektrik', 'amount': 35000},
            {'name': 'Güvenlik', 'amount': 45000},
          ],
        },
      ),
    ];
  }
}
