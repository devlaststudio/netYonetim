# 💰 Finans ve Ödeme Sistemleri Planı

## 📊 Ön Muhasebe Modülü

### Hesap Planı (KMK Uyumlu)

```
1. GELİRLER
├── 1.1 Aidat Gelirleri
│   ├── 1.1.1 Normal Aidat
│   ├── 1.1.2 Ek Aidat
│   └── 1.1.3 Demirbaş Aidatı
├── 1.2 Tüketim Gelirleri
│   ├── 1.2.1 Su Bedeli
│   ├── 1.2.2 Elektrik Bedeli
│   ├── 1.2.3 Doğalgaz Bedeli
│   └── 1.2.4 Isıtma Bedeli
├── 1.3 Diğer Gelirler
│   ├── 1.3.1 Kira Gelirleri
│   ├── 1.3.2 Gecikme Tazminatları
│   ├── 1.3.3 Reklam Gelirleri
│   └── 1.3.4 Faiz Gelirleri

2. GİDERLER
├── 2.1 Personel Giderleri
│   ├── 2.1.1 Ücretler
│   ├── 2.1.2 SGK Primleri
│   ├── 2.1.3 İşsizlik Sigortası
│   └── 2.1.4 Kıdem/İhbar Karşılıkları
├── 2.2 Bakım Onarım Giderleri
│   ├── 2.2.1 Asansör Bakımı
│   ├── 2.2.2 Bahçe Bakımı
│   ├── 2.2.3 Temizlik Malzemeleri
│   └── 2.2.4 Genel Onarımlar
├── 2.3 Ortak Alan Giderleri
│   ├── 2.3.1 Elektrik
│   ├── 2.3.2 Su
│   ├── 2.3.3 Doğalgaz
│   └── 2.3.4 İnternet
├── 2.4 Güvenlik Giderleri
├── 2.5 Sigorta Giderleri
├── 2.6 Yönetim Giderleri
└── 2.7 Diğer Giderler
```

---

## 💳 Ödeme Sistemi Entegrasyonu

### Desteklenen Ödeme Yöntemleri

| Yöntem | Sağlayıcı | Komisyon | Özellikler |
|--------|-----------|----------|------------|
| Kredi Kartı | iyzico/PayTR | %1.89-2.5 | Taksit, 3D Secure |
| Banka Kartı | iyzico/PayTR | %0.99-1.5 | Anında onay |
| Havale/EFT | Banka API | Ücretsiz | MT940 otomatik eşleştirme |
| BKM Express | BKM | %1.5 | Hızlı ödeme |
| Dijital Cüzdan | Apple/Google Pay | %1.5 | Biyometrik onay |
| QR Kod | TR Karekod | %1.2 | FAST ile anlık |

### Ödeme Akışı

```
1. Sakin ödeme başlatır
   ↓
2. Borç seçimi (tek/çoklu)
   ↓
3. Ödeme yöntemi seçimi
   ↓
4. Komisyon hesaplama ve gösterme
   ↓
5. Kart bilgileri / 3D Secure
   ↓
6. Ödeme işleme
   ↓
7. Sonuç (Başarılı/Başarısız)
   ↓
8. Borç otomatik kapanış
   ↓
9. Dekont oluşturma ve SMS/Email
```

### Otomatik Ödeme Talimatı

```dart
class RecurringPayment {
  String cardToken;      // Tokenize edilmiş kart
  int dayOfMonth;        // Her ayın kaçında
  double? fixedAmount;   // Sabit tutar
  bool payFullDebt;      // Tüm borcu öde
  bool isActive;
}
```

---

## 🏦 Banka Entegrasyonu

### MT940 Parsing (Hesap Ekstresi)

```dart
class MT940Parser {
  List<BankTransaction> parse(String mt940Content) {
    // :20: Transaction Reference
    // :25: Account Identification
    // :60F: Opening Balance
    // :61: Statement Line
    // :86: Information to Account Owner
    // :62F: Closing Balance
  }
}

class BankTransaction {
  DateTime valueDate;
  String reference;
  double amount;
  bool isCredit;
  String description;
  String? senderName;
  String? senderIban;
}
```

### Otomatik Eşleştirme Algoritması

```dart
class PaymentMatcher {
  Due? findMatchingDue(BankTransaction tx, List<Due> openDues) {
    // 1. Açıklama içinde daire no ara
    // 2. Gönderen ismi ile sakin eşleştir
    // 3. Tutar ile borç eşleştir
    // 4. Birden fazla eşleşme: en eski borç
    // 5. Eşleşme yok: manuel onay kuyruğu
  }
}
```

---

## 📈 Gecikme Tazminatı Hesaplama (KMK Md. 20)

```dart
class DelayFeeCalculator {
  // Aylık %5 gecikme tazminatı (yasal oran)
  static const double monthlyRate = 0.05;
  
  double calculate({
    required double principal,
    required DateTime dueDate,
    required DateTime paymentDate,
  }) {
    if (paymentDate.isBefore(dueDate)) return 0;
    
    final daysLate = paymentDate.difference(dueDate).inDays;
    final monthsLate = (daysLate / 30).ceil();
    
    // Basit faiz hesabı
    return principal * monthlyRate * monthsLate;
  }
}
```

---

## 📊 Raporlama Modülü

### Standart Raporlar

1. **Mizan:** Hesap bakiyeleri listesi
2. **Gelir-Gider Tablosu:** Dönemsel özet
3. **Borç Durum Raporu:** Açık borçlar listesi
4. **Tahsilat Raporu:** Dönemsel tahsilat analizi
5. **Gider Analizi:** Kategori bazlı dağılım
6. **Kasa Raporu:** Nakit akış takibi
7. **Denetim Raporu:** KMK uyumlu format

### Rapor Export Formatları
- PDF (dekontlar, resmi raporlar)
- Excel (detaylı analiz)
- CSV (veri aktarımı)

---

## 🔐 Finansal Güvenlik

### PCI-DSS Uyumluluğu
- Kart bilgileri sistemde saklanmaz
- Token bazlı kart kaydetme
- SSL/TLS 1.3 zorunlu
- Düzenli güvenlik denetimleri

### İşlem Logları
```dart
class FinancialAuditLog {
  String id;
  String action;    // payment, refund, due_created
  String userId;
  double amount;
  Map<String, dynamic> details;
  DateTime timestamp;
  String ipAddress;
  String deviceInfo;
}
```

---

## 💡 Akıllı Finans Özellikleri

### Nakit Akış Tahmini
- Geçmiş verilere dayalı tahmin
- Mevsimsel düzeltmeler
- Beklenen gider uyarıları

### Otomatik İşletme Projesi
```dart
class BudgetWizard {
  BudgetPlan generate(Site site) {
    // 1. Geçmiş 12 ay giderlerini analiz et
    // 2. Enflasyon oranını uygula
    // 3. Planlı bakımları ekle
    // 4. Yedek akçe hesapla
    // 5. Daire başı aidat öner
  }
}
```

### Ödeme Hatırlatma Sistemi
- Vade öncesi 7 gün: İlk hatırlatma
- Vade günü: Son hatırlatma
- Vade sonrası 7 gün: Gecikme uyarısı
- 30 gün sonra: Hukuki süreç uyarısı
