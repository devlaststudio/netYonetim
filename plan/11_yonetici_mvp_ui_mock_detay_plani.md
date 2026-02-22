# Yonetici MVP UI + Mock Detay Plani

## 1) Kapsam ve Tasarim Prensipleri
1. Bu plan, `Yonetici` paneli icin UI + mock odakli MVP kapsamidir.
2. Hedef: Konsiyon tanitim videosundaki yonetici finans-operasyon akislarini demo/staging seviyesinde calistirmak.
3. Tasarim prensibi: mevcut uygulamanin kart, form, liste, spacing, renk ve tipografi yapisina sadik kalmak.
4. Bu fazda dis entegrasyonlar (gercek banka, WhatsApp API, cihazlar) mock olarak ele alinir.
5. Mevcut sakin modulleri (dues, tickets, polls, visitors, reservation) kirilmadan korunur.

## 2) Kodda Acilan Temel Altyapi
1. Yeni model katmani: `lib/data/models/manager/manager_models.dart`
2. Yeni mock data katmani:
   1. `lib/data/mock/manager_finance_mock_data.dart`
   2. `lib/data/mock/manager_ops_mock_data.dart`
3. Yeni provider katmani:
   1. `lib/data/providers/manager_finance_provider.dart`
   2. `lib/data/providers/manager_ops_provider.dart`
   3. `lib/data/providers/manager_reports_provider.dart`
4. Export standardi: `lib/services/report_export_service.dart`
5. Yeni ortak yonetici widgetlari: `lib/screens/manager/shared/manager_common_widgets.dart`
6. Uygulama route + provider baglantisi: `lib/main.dart`
7. Sidebar + ekran esleme: `lib/screens/dashboard/widgets/collapsible_sidebar.dart`, `lib/screens/dashboard/manager_dashboard_screen.dart`

## 3) Route Envanteri ve Durum
1. `/manager/charges` - Tamamlandi (UI + mock create/cancel/regenerate)
2. `/manager/collections` - Tamamlandi (UI + mock tahsilat + allocation mode)
3. `/manager/cash-expenses` - Tamamlandi (UI + mock kasa gider kaydi)
4. `/manager/transfers` - Tamamlandi (UI + mock virman + bakiye kontrolu)
5. `/manager/bank-reconciliation` - Tamamlandi (UI + mock eslestirme/isaretleme)
6. `/manager/accrual-movements` - Tamamlandi (UI + toplu secim + yeniden olustur/sil)
7. `/manager/cash-movements` - Tamamlandi (UI + detay + iptal)
8. `/manager/statement-unit` - Tamamlandi (UI + daire bazli filtre)
9. `/manager/statement-vendor` - Tamamlandi (UI + cari bazli filtre)
10. `/manager/bulk-reports` - Tamamlandi (UI + rapor uretim + mock PDF/Excel)
11. `/manager/notifications` - Tamamlandi (UI + sablon + gonderim logu)
12. `/manager/site-settings` - Tamamlandi (UI + grup/demirbas + import mock adimi)
13. `/manager/staff-roles` - Tamamlandi (UI + rol/yetki guncelleme)
14. `/manager/task-tracking` - Tamamlandi (UI + gorev + arama notu)
15. `/manager/decision-book` - Tamamlandi (UI + karar kaydi)
16. `/manager/file-archive` - Tamamlandi (UI + klasor filtre + dosya ekleme)
17. `/manager/meter-reading` - Tamamlandi (UI + sayac kaydi)

## 4) Ekran Bazli Detay Spesifikasyon

### 4.1 Borclandirma Merkezi (`/manager/charges`)
1. UI bolumleri:
   1. KPI kartlari: batch sayisi, toplam borclandirma, aktif period, son guncelleme
   2. Yeni borclandirma formu
   3. Son batch listesi
2. Form alanlari: baslik, kapsam (`ChargeScope`), dagitim (`ChargeDistributionType`), donem, son odeme tarihi, tutar.
3. Mock data: `ChargeBatch`, `ChargeItem`, site unit listesi.
4. Aksiyonlar: yeni batch olustur, batch iptal et, yeniden olustur.
5. Validasyonlar: bos alan, negatif/sifir tutar, gecmis son odeme tarihi uyarisi.
6. Cikis artefakti: borclandirma hareketine yansiyacak batch kaydi.

### 4.2 Tahsilat Merkezi (`/manager/collections`)
1. UI bolumleri:
   1. KPI kartlari: toplam tahsilat, islem sayisi, kanal dagilimi, son tahsilat tarihi
   2. Tahsilat formu
   3. Tahsilat listesi + makbuz aksiyonu
2. Form alanlari: uye, kasa/banka hesabi, allocation mode (`oldest/newest/manual`), tahsilat tutari.
3. Mock data: `CollectionRecord`, `CollectionAllocationLine`.
4. Aksiyonlar: tahsilat olustur, makbuz onizleme, PDF/Excel akisina cikis.
5. Validasyonlar: tutar > 0, uye secili, kasa hesabi secili.
6. Cikis artefakti: tahsilat kaydi + kasa hareket kaydi.

### 4.3 Kasa Gideri + Cari Borc (`/manager/cash-expenses`)
1. UI bolumleri: KPI kartlari, gider giris formu, gider listesi.
2. Form alanlari: firma, kategori, odeme hesabi, belge no, tutar.
3. Mock data: `CashExpense`, `VendorLedgerEntry`.
4. Aksiyonlar: gider kaydi, listeleme, kategori bazli filtreleme.
5. Validasyonlar: firma secimi, tutar > 0, hesap secimi.
6. Cikis artefakti: gider kaydi + cari hareket + kasa cikisi.

### 4.4 Virman/Transfer (`/manager/transfers`)
1. UI bolumleri: hesap bakiyeleri, transfer formu, transfer listesi.
2. Form alanlari: kaynak hesap, hedef hesap, tutar, aciklama.
3. Mock data: `TransferRecord`, hesap bakiyeleri map.
4. Aksiyonlar: transfer olustur.
5. Validasyonlar: kaynak != hedef, tutar > 0, yetersiz bakiye engeli.
6. Cikis artefakti: cift tarafli kasa hareket satiri.

### 4.5 Banka Eslestirme (`/manager/bank-reconciliation`)
1. UI bolumleri: KPI kartlari, banka hareket listesi, kural listesi.
2. Form alanlari: kural adi, aciklama eslesme anahtari, hedef tip.
3. Mock data: `BankMovement`, `ReconciliationRule`, `MatchStatus`.
4. Aksiyonlar: hareketi eslestir, ignore et, kural ekle.
5. Validasyonlar: kural adi bos olamaz, duplicate kural uyarisi.
6. Cikis artefakti: eslesme statusu degisimi + ilgili kayda baglantilama.

### 4.6 Tahakkuk Hareketleri (`/manager/accrual-movements`)
1. UI bolumleri: secimli liste, toplu aksiyon bar.
2. Mock data: `ChargeBatch` kaynakli hareket satirlari.
3. Aksiyonlar: toplu sil, yeniden olustur.
4. Validasyonlar: secim yoksa aksiyon pasif.
5. Cikis artefakti: toplu islem logu.

### 4.7 Kasa Hareketleri (`/manager/cash-movements`)
1. UI bolumleri: filtre, hareket listesi, detay modal.
2. Mock data: `CashMovementRecord`.
3. Aksiyonlar: hareket iptali, belge aksiyonu (makbuz/PDF).
4. Validasyonlar: iptal edilmis kayit tekrar iptal edilemez.

### 4.8 Daire Hesap Ekstresi (`/manager/statement-unit`)
1. UI bolumleri: daire filtre dropdown, ozet kartlar, ekstre listesi.
2. Mock data: `UnitStatementLine`.
3. Aksiyonlar: daire bazli filtre, toplu export.
4. Validasyonlar: secili daire yoksa tum liste fallback.

### 4.9 Cari Hesap Ekstresi (`/manager/statement-vendor`)
1. UI bolumleri: cari filtre dropdown, borc/alacak kartlari, hareket listesi.
2. Mock data: `VendorLedgerEntry`.
3. Aksiyonlar: cari bazli filtre, export.
4. Validasyonlar: tarih araligi ters ise uyar.

### 4.10 Finansal Rapor Merkezi (`/manager/bulk-reports`)
1. UI bolumleri: donem secici, rapor tipi chip listesi, uretilen rapor listesi.
2. Rapor tipleri: `ReportTypeKey` altinda 11 raporun tamami.
3. Mock data: `ManagerReportItem` + summary map.
4. Aksiyonlar: rapor uret, onizleme, PDF export, Excel export.
5. Validasyonlar: baslangic <= bitis tarihi.
6. Not: otomatik planlayici kurali bir sonraki iterasyonda UI olarak ayrica eklenecek.

### 4.11 Toplu Bildirim Merkezi (`/manager/notifications`)
1. UI bolumleri: hedef filtre, sablon listesi, gonderim logu.
2. Mock data: `NotificationTemplate`, `NotificationDispatch`.
3. Aksiyonlar: sablon ekle, secili filtreye gonder.
4. Validasyonlar: sablon adi ve icerik zorunlu.
5. Not: otomatik bildirim kurali (scheduler) bir sonraki iterasyonda eklenecek.

### 4.12 Site Ayarlari + Import (`/manager/site-settings`)
1. UI bolumleri: daire gruplari, toplu import kutusu, demirbas listesi.
2. Mock data: `SiteUnitGroup`, `AssetRecord`.
3. Aksiyonlar: grup ekle, demirbas ekle, sablon indir, dosya yukle (mock).
4. Validasyonlar: grup adi bos olamaz, daire sayisi numerik.
5. Sonraki iterasyon: satir bazli import hata tablosu ve eski uye gorunumu.

### 4.13 Personel Yetki (`/manager/staff-roles`)
1. UI bolumleri: personel kartlari, rol dropdown, izin checkbox listesi.
2. Mock data: `StaffRoleRecord`, `StaffRoleType`.
3. Aksiyonlar: rol/izin guncelle.
4. Validasyonlar: en az 1 zorunlu temel yetki korunur.

### 4.14 Is Takibi + Arama Notlari (`/manager/task-tracking`)
1. UI bolumleri: gorev listesi, yeni gorev diyaloğu, arama notlari listesi.
2. Mock data: `TaskRecord`, `CallLogRecord`.
3. Aksiyonlar: gorev ac, durum guncelle, arama notu ekle.
4. Validasyonlar: son tarih gecmis ise yuksek oncelik uyarisi.

### 4.15 Karar Defteri (`/manager/decision-book`)
1. UI bolumleri: karar listesi, yeni karar diyaloğu.
2. Mock data: `DecisionRecord`.
3. Aksiyonlar: karar ekle, karar no ile listele.
4. Validasyonlar: karar no tekrari uyarisi.

### 4.16 Dosya Arsivi (`/manager/file-archive`)
1. UI bolumleri: klasor filtresi, dosya listesi, dosya ekleme diyaloğu.
2. Mock data: `FileArchiveItem`.
3. Aksiyonlar: filtrele, dosya kaydi ekle.
4. Validasyonlar: dosya adi ve klasor zorunlu.

### 4.17 Sayac Okuma (`/manager/meter-reading`)
1. UI bolumleri: donem/daire/tip formu, okuma listesi, ozet.
2. Mock data: `MeterReading`, `MeterType`, `MeterReadingStatus`.
3. Aksiyonlar: yeni okuma kaydi.
4. Validasyonlar: bitis >= baslangic.

## 5) Rapor Seti (11 Tip) ve Mock Cikti Beklentisi
1. Kasa durum raporu: nakit, banka, bekleyen gelir/gider.
2. Aylik gelir-gider: gelir, gider, net.
3. Tahakkuk hareketi: tahakkuk, iptal, net.
4. Tahsilat raporu: tahsilat, gecikme tahsilati, iade.
5. Daire ekstresi: borc, odeme, bakiye.
6. Cari ekstresi: borc, odeme, acik.
7. Denetci raporu: tespit, tamamlanan, acik.
8. Ihtar yazisi: olusturulan, gonderilen, bekleyen.
9. Borcu yoktur: olusturulan, onaylanan, iptal.
10. POS/banka hareket: pos tahsilat, banka tahsilat, masraf.
11. Butce karsilastirma: tahmini, fiili, fark.

## 6) Kayit Turu Kapsama Matrisi
1. Borclandirma batch kaydi: var (`ChargeBatch`)
2. Tahsilat kaydi: var (`CollectionRecord`)
3. Tahsilat allocation satiri: var (`CollectionAllocationLine`)
4. Kasa gider kaydi: var (`CashExpense`)
5. Cari hesap hareket kaydi: var (`VendorLedgerEntry`)
6. Virman kaydi: var (`TransferRecord`)
7. Banka hareket kaydi: var (`BankMovement`)
8. Eslestirme kurali kaydi: var (`ReconciliationRule`)
9. Bildirim sablonu: var (`NotificationTemplate`)
10. Bildirim dispatch logu: var (`NotificationDispatch`)
11. Sayac okuma kaydi: var (`MeterReading`)
12. Karar defteri kaydi: var (`DecisionRecord`)
13. Arama notu kaydi: var (`CallLogRecord`)
14. Demirbas kaydi: var (`AssetRecord`)
15. Is takibi gorev kaydi: var (`TaskRecord`)

## 7) 8 Haftalik Takvim (Net Tarih Araliklari)
1. Faz 1 - Finans Cekirdegi: 23 Subat 2026 - 8 Mart 2026
   1. Borclandirma, tahsilat, gider, transfer ekranlari.
   2. Makbuz/export akisi standardizasyonu.
2. Faz 2 - Banka + Hareket + Ekstre: 9 Mart 2026 - 22 Mart 2026
   1. Banka eslestirme, tahakkuk hareketleri, kasa hareketleri.
   2. Daire/cari ekstre ekranlari.
3. Faz 3 - Rapor + Otomasyon + Bildirim: 23 Mart 2026 - 5 Nisan 2026
   1. Rapor merkezi tam kapsam.
   2. Otomatik borclandirma/bildirim kurali mock scheduler.
4. Faz 4 - Site Ayarlari + Ops Temel: 6 Nisan 2026 - 19 Nisan 2026
   1. Import wizard derinlestirme, personel/yetki, karar/arsiv/sayac.

## 8) Test Senaryolari (Detay)
1. Borclandirma dagitimi:
   1. equal/sqm/fixed/custom dagitim sonucu toplam tutar korunmali.
   2. hedef kisi/daire sayisi degisse bile batch toplam sapmamali.
2. Tahsilat allocation:
   1. oldest-first/newest-first ayni toplam tutari dagitmali.
   2. kismi tahsilatta kalan borc dogru kalmali.
3. Transfer:
   1. yetersiz bakiye engeli.
   2. basarili transferde cift tarafli kasa hareketi.
4. Banka eslestirme:
   1. unmatched -> matched gecisinde ozet kart guncellenmeli.
   2. ignore aksiyonu loga dusmeli.
5. Rapor tutarliligi:
   1. rapor summary toplamlari kaynak hareketlerle uyusmali.
6. Bildirim hedefleme:
   1. secili filtre disina cikilmamali.
   2. dispatch logu sent/failed toplam kontrolden gecmeli.
7. Import validasyonu:
   1. zorunlu kolon hatalari satir bazli gosterilmeli.
8. Export:
   1. PDF/Excel dosya adlandirma standardi.
   2. Turkce karakter stabilitesi.
9. Widget/navigation:
   1. sidebar ID -> route/ekran eslesmesi bozulmamali.

## 9) Acik Maddeler (Sonraki Iterasyon)
1. Otomatik planlayici kurali ekrani (borclandirma + bildirim scheduler).
2. Site import sihirbazinda satir bazli hata tablosu ve onizleme adimi.
3. Gecmis uye (eski uye) gorunumu.
4. Banka hareketlerinde kural bazli toplu otomatik eslestirme simule modu.
5. Raporlarda coklu secimle toplu tek tik export.

## 10) Definition of Done (UI + Mock)
1. Her route acilir, veri gosterir, en az bir create aksiyonu calisir.
2. Form validasyonlari kullaniciya gorunur geri bildirim verir.
3. Ana listeler bos-dolu-error durumlarini gosterir.
4. Export aksiyonlari dosya adi ureterek mock tamamlanma mesaji verir.
5. `flutter analyze --no-fatal-warnings --no-fatal-infos` hata vermeden gecer.
6. `flutter test` temel smoke testlerinden gecer.
