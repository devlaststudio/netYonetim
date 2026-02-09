# ⚖️ Yasal Uyumluluk ve KVKK Planı

## 📋 Kat Mülkiyeti Kanunu (KMK) Uyumluluğu

### Zorunlu Defterler ve Dijital Karşılıkları

| Yasal Gereklilik | Dijital Çözüm | İlgili Madde |
|------------------|---------------|--------------|
| Karar Defteri | Dijital karar modülü + Noter formatı export | KMK Md. 32 |
| İşletme Defteri | Ön muhasebe modülü | KMK Md. 36 |
| Gelir-Gider Tablosu | Otomatik raporlama | KMK Md. 37 |
| İşletme Projesi | Bütçe planlama modülü | KMK Md. 37 |

### Karar Defteri Gereksinimleri

```dart
class DecisionBook {
  // Noter tasdiki için format
  String generateNotaryFormat(List<Decision> decisions) {
    final buffer = StringBuffer();
    
    buffer.writeln('KARAR DEFTERİ');
    buffer.writeln('Site Adı: ${siteName}');
    buffer.writeln('Defter Sıra No: ${defterId}');
    buffer.writeln('─' * 50);
    
    for (final decision in decisions) {
      buffer.writeln('Karar No: ${decision.number}');
      buffer.writeln('Tarih: ${decision.date.format("dd.MM.yyyy")}');
      buffer.writeln('Konu: ${decision.title}');
      buffer.writeln('Karar: ${decision.content}');
      buffer.writeln('Kabul: ${decision.votesFor}');
      buffer.writeln('Red: ${decision.votesAgainst}');
      buffer.writeln('Çekimser: ${decision.votesAbstain}');
      buffer.writeln('');
      buffer.writeln('İmzalar:');
      for (final signer in decision.signers) {
        buffer.writeln('  ${signer.name} - ${signer.role}');
      }
      buffer.writeln('─' * 50);
    }
    
    return buffer.toString();
  }
}
```

### Gecikme Tazminatı (KMK Md. 20)

```dart
// Yasal oran: Aylık %5
class LegalDelayCalculator {
  static const double MONTHLY_RATE = 0.05;
  
  double calculate(double principal, int daysLate) {
    // "Kat malikleri aidat borçlarını zamanında ödemez ise,
    //  gecikmeleri için aylık yüzde beş hesabıyla gecikme 
    //  tazminatı ödemekle yükümlüdürler."
    
    final monthsLate = (daysLate / 30).ceil();
    return principal * MONTHLY_RATE * monthsLate;
  }
}
```

---

## 🔒 KVKK (Kişisel Verilerin Korunması)

### Veri Kategorileri

| Kategori | Örnekler | Saklama Süresi |
|----------|----------|----------------|
| Kimlik Bilgisi | Ad, soyad, TC | Üyelik süresince |
| İletişim | Telefon, email | Üyelik süresince |
| Lokasyon | Adres, daire no | Üyelik süresince |
| Finansal | Borç, ödeme | 10 yıl (VUK) |
| Araç | Plaka | Üyelik süresince |
| Biyometrik | Yüz tanıma | 1 yıl |

### Açık Rıza Metni

```
"Site Yönetimi Uygulaması" tarafından;

□ Kimlik ve iletişim bilgilerimin site yönetimi hizmetleri 
  kapsamında işlenmesini,
  
□ Borç ve ödeme bilgilerimin tahsilat amacıyla işlenmesini,

□ Araç plaka bilgilerimin otopark giriş-çıkış işlemleri için 
  işlenmesini,
  
□ [Opsiyonel] Pazarlama iletişimi almayı

KABUL EDİYORUM.

Kişisel verilerin işlenmesine ilişkin aydınlatma metnini 
okudum ve anladım.

Tarih: ___________
İmza: ___________
```

### Veri Sahibi Hakları (KVKK Md. 11)

```dart
class DataSubjectRights {
  // 1. Kişisel verilerin işlenip işlenmediğini öğrenme
  Future<DataProcessingInfo> getProcessingInfo(String userId);
  
  // 2. İşlenmişse bilgi talep etme
  Future<PersonalDataReport> getPersonalData(String userId);
  
  // 3. İşlenme amacını öğrenme
  Future<ProcessingPurposes> getPurposes(String userId);
  
  // 4. Üçüncü kişileri bilme
  Future<List<ThirdParty>> getThirdParties(String userId);
  
  // 5. Düzeltme talep etme
  Future<void> requestCorrection(String userId, Map<String, dynamic> corrections);
  
  // 6. Silme talep etme
  Future<void> requestDeletion(String userId);
  
  // 7. Aktarılan üçüncü kişilere bildirim
  Future<void> notifyThirdParties(String userId, String action);
  
  // 8. İtiraz etme
  Future<void> fileObjection(String userId, String objection);
  
  // 9. Zararın giderilmesini talep etme
  Future<void> claimDamages(String userId, String claim);
}
```

### Veri Güvenliği Önlemleri

```yaml
Teknik Önlemler:
  - Veritabanı şifreleme (AES-256)
  - İletişim şifreleme (TLS 1.3)
  - Erişim logları
  - Güvenlik duvarı
  - Sızma testleri (yıllık)
  - Yedekleme ve felaket kurtarma

İdari Önlemler:
  - Veri işleme politikası
  - Çalışan eğitimleri
  - Gizlilik sözleşmeleri
  - Veri ihlali prosedürü
  - Düzenli denetimler
```

---

## 📊 VUK (Vergi Usul Kanunu) Uyumluluğu

### Belge Saklama

```dart
class DocumentRetention {
  static const Map<String, int> retentionYears = {
    'fatura': 10,
    'makbuz': 10,
    'banka_ekstresi': 10,
    'bordro': 10,
    'sgk_bildirge': 10,
    'karar_defteri': 10,
    'isletme_defteri': 10,
  };
  
  Future<void> archiveDocument(Document doc) async {
    final expiryDate = DateTime.now().add(
      Duration(days: retentionYears[doc.type]! * 365)
    );
    
    await _archiveService.store(
      document: doc,
      expiryDate: expiryDate,
      encrypted: true,
    );
  }
}
```

### e-Fatura Entegrasyonu

```dart
class EInvoiceService {
  // GİB (Gelir İdaresi Başkanlığı) entegrasyonu
  
  Future<void> processIncomingInvoice(String invoiceXml) async {
    final invoice = EInvoice.fromXml(invoiceXml);
    
    // 1. Faturayı veritabanına kaydet
    await _repository.saveInvoice(invoice);
    
    // 2. Gider kaydı oluştur
    await _expenseService.createFromInvoice(invoice);
    
    // 3. Otomatik muhasebe kaydı
    await _accountingService.recordExpense(invoice);
  }
}
```

---

## 👷 SGK ve İşçi Hakları

### Personel Bordro Modülü

```dart
class PayrollCalculator {
  PayrollResult calculate(Employee employee, int month, int year) {
    final grossSalary = employee.grossSalary;
    
    // SGK kesintileri
    final sgkEmployee = grossSalary * 0.14;      // İşçi payı
    final sgkEmployer = grossSalary * 0.205;     // İşveren payı
    final unemploymentEmployee = grossSalary * 0.01;
    final unemploymentEmployer = grossSalary * 0.02;
    
    // Gelir vergisi (kümülatif matrah üzerinden)
    final incomeTax = _calculateIncomeTax(grossSalary, employee.cumulativeBase);
    
    // Damga vergisi
    final stampTax = grossSalary * 0.00759;
    
    final netSalary = grossSalary - sgkEmployee - unemploymentEmployee 
                      - incomeTax - stampTax;
    
    return PayrollResult(
      grossSalary: grossSalary,
      sgkEmployee: sgkEmployee,
      sgkEmployer: sgkEmployer,
      incomeTax: incomeTax,
      stampTax: stampTax,
      netSalary: netSalary,
      totalEmployerCost: grossSalary + sgkEmployer + unemploymentEmployer,
    );
  }
}
```

### SGK Bildirge Entegrasyonu

```dart
class SGKService {
  // Aylık prim bildirge oluşturma
  Future<String> generateMonthlyDeclaration(
    List<Employee> employees,
    int month,
    int year,
  ) async {
    // MUHSGK formatında XML oluştur
    return _xmlBuilder.buildDeclaration(employees, month, year);
  }
  
  // e-Bildirge gönderimi
  Future<void> submitDeclaration(String declarationXml) async {
    await _sgkApi.submit(declarationXml);
  }
}
```

---

## 📝 Sözleşme Yönetimi

### Tedarikçi Sözleşmeleri

```dart
class ContractManagement {
  Future<void> createContract(Contract contract) async {
    // 1. Sözleşme şablonu doldur
    final filledContract = await _templateService.fill(
      template: contract.template,
      data: contract.data,
    );
    
    // 2. E-imza için gönder
    await _eSignatureService.sendForSignature(
      document: filledContract,
      signers: contract.signers,
    );
    
    // 3. Hatırlatıcılar oluştur
    await _reminderService.create(
      relatedTo: contract.id,
      reminders: [
        Reminder(
          date: contract.endDate.subtract(Duration(days: 30)),
          message: 'Sözleşme bitişine 30 gün kaldı',
        ),
      ],
    );
  }
}
```

---

## ⚠️ Risk ve Uyumluluk Kontrol Listesi

```
□ KVKK Aydınlatma Metni hazırlandı mı?
□ Açık Rıza formu oluşturuldu mu?
□ VERBİS kaydı yapıldı mı?
□ Veri işleme envanteri çıkarıldı mı?
□ Çalışan gizlilik sözleşmeleri imzalandı mı?
□ Veri ihlali prosedürü belirlendi mi?
□ Yedekleme politikası oluşturuldu mu?
□ Erişim yetkileri tanımlandı mı?
□ Log tutma mekanizması aktif mi?
□ Şifreleme uygulandı mı?
```
