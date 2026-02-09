# 🎨 UI/UX Tasarım Planı

## 📐 Tasarım Felsefesi

### Temel Prensipler
1. **Sadelik:** Karmaşık işlemleri basit adımlara bölme
2. **Tutarlılık:** Platform genelinde aynı tasarım dili
3. **Erişilebilirlik:** Her yaş grubuna uygun tasarım
4. **Performans:** Hızlı yüklenen, akıcı animasyonlar

---

## 🎨 Tasarım Sistemi

### Renk Paleti

```dart
// Ana Renkler
primaryColor: #2563EB     // Mavi - Güven
secondaryColor: #10B981   // Yeşil - Başarı
accentColor: #F59E0B      // Turuncu - Dikkat

// Nötr Renkler
backgroundColor: #F8FAFC
surfaceColor: #FFFFFF
textPrimary: #1E293B
textSecondary: #64748B

// Durum Renkleri
success: #22C55E
warning: #EAB308
error: #EF4444
info: #3B82F6

// Dark Mode
darkBackground: #0F172A
darkSurface: #1E293B
```

### Tipografi

```dart
fontFamily: 'Inter' // veya 'Poppins'

// Başlıklar
h1: 32px, bold | h2: 24px, bold | h3: 20px, w600

// Gövde
bodyLarge: 16px | bodyMedium: 14px | bodySmall: 12px
```

### Aralık (8px Grid)
```
xs: 4px | sm: 8px | md: 16px | lg: 24px | xl: 32px
```

---

## 📱 Ana Ekranlar

### 1. Login Ekranı
- Logo (animasyonlu)
- E-posta ve şifre alanları
- Google/Apple ile giriş
- Şifremi unuttum linki

### 2. Sakin Dashboard
- Hoş geldin mesajı
- Borç/Ödenen özet kartları
- Son duyurular
- Hızlı işlem butonları (Öde, Talep, Oyla, Rapor)
- Alt navigasyon: Ana, Borçlar, Duyuru, Profil

### 3. Yönetici Dashboard
- Kasa durumu ve tahsilat oranı
- Açık talep ve gecikmiş borç sayısı
- Aylık gelir/gider grafiği
- Hızlı işlemler
- Alt navigasyon: Ana, Finans, Rapor, Ayarlar

### 4. Borç Listesi
- Toplam borç özeti
- Detaylı borç kartları (tip, tutar, vade, durum)
- Tek tek veya toplu ödeme seçeneği

### 5. Ödeme Ekranı
- Ödenecek tutar
- Ödeme yöntemi seçimi (Kart, Havale, Dijital)
- Komisyon bilgisi
- Kart bilgileri formu
- Otomatik ödeme talimatı seçeneği

### 6. Talep/Şikayet
- Talep listesi (durum renk kodları)
- Yeni talep oluşturma
- Talep detay ve yorum sistemi

### 7. Raporlar
- Dönem seçici
- Gelir/gider grafiği
- Dağılım pie chart
- PDF export

---

## 📐 Responsive Breakpoints

```
Mobile: 0-599px (tek kolon, bottom nav)
Tablet: 600-1023px (2 kolon, drawer)
Desktop: 1024px+ (3-4 kolon, side nav)
```

---

## ♿ Erişilebilirlik
- Minimum dokunma: 48x48px
- Kontrast: 4.5:1 minimum
- Dinamik font ölçeklendirme
- Screen reader desteği

---

## 🛠️ Araçlar
- **Tasarım:** Figma
- **İkonlar:** Phosphor Icons
- **İllüstrasyon:** unDraw
