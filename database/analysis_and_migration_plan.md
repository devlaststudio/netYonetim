# Proje Analizi ve Veritabani Karari

## 1) Kod Tabanindan Cikarilan Durum

- Uygulama Flutter + `provider` kullaniyor, kalici iliskisel DB katmani henuz yok.
- Veri su anda agirlikla `lib/data/mock/*` ve kisitli olarak `SharedPreferences` ile tutuluyor.
- Iliskisel modele dogrudan karsilik gelen domainler:
  - Cekirdek: site, blok, daire, kullanici, rol, daire oturum/uyelik
  - Finans: borclandirma, odeme, aidat/borc tipleri, muhasebe hesap plani, fisler, butce, rapor
  - Operasyon: talepler (ticket), yorumlar, duyuru, okundu bilgisi, ziyaretci
  - Hizmet: teknisyen, servis talepleri, puan/yorum
  - Topluluk: anketler, anket secenekleri, oylar
  - Rezervasyon: tesis/etkinlik, zaman plani, rezervasyonlar
- Enum/deger listeleri kodda daginik; bunlar DB tarafinda kod tablolari ile normalize edildi.

## 2) Bu Klasorde Sunulan Cikti

- `database/sqlite/schema.sql`
  - Lokal gelistirme ve offline senaryo icin SQLite DDL
- `database/postgresql/schema.sql`
  - Uretim ve cok kullanicili senaryo icin PostgreSQL DDL

Iki sema bilincli olarak ayni domain modelini paylasir; farklar sadece DB motoruna ozgu tiplerdedir.

## 3) Veri Tipi Stratejisi

- Para alanlari: `*_kurus` (INTEGER/BIGINT)
  - Neden: SQLite `REAL` kaynakli hassasiyet hatalarini engeller.
  - Uygulama katmaninda `double` <-> `kurus` cevirimi yapilir.
- Tarih/saat:
  - SQLite: `TEXT` (ISO-8601)
  - PostgreSQL: `DATE`, `TIME`, `TIMESTAMPTZ`
- Kod alanlari:
  - Enum yerine FK ile kod tablolari (or. `due_statuses`, `ticket_priorities`).

## 4) Neden Once SQLite, Sonra PostgreSQL?

### SQLite (Simdi)
- Hizli kurulum, sifir operasyonel maliyet
- Offline/mobil gelistirme icin ideal
- MVP ve UI akislarini hizla dogrulama

### PostgreSQL (Sonraki Asama)
- Cok kullanicili eszamanlilik ve veri butunlugu
- Guclu sorgu/raporlama performansi
- Sunucu tarafi yetkilendirme + denetim izi icin uygun temel

## 5) Onerilen Gecis Plani (SQLite -> PostgreSQL)

1. SQLite semasini uygulamaya entegre et (`sqflite` repository katmani).
2. SharedPreferences ile tutulan alanlari tabloya tasi:
   - `service_requests`
   - `polls`
3. ID formatini sabitle (UUID/ULID string) ve tum tablolarda ayni kullan.
4. API katmani eklendiginde PostgreSQL semasini ac.
5. ETL/migration script:
   - SQLite export
   - PostgreSQL import
   - referential integrity kontrolu
6. Son adimda tek kaynak PostgreSQL, SQLite ise cache/offline copy olarak kalabilir.

## 6) Kritik Notlar

- Duyuruda `is_read` kullaniciya ozel oldugu icin `announcement_reads` tablosuna ayrildi.
- Ankette `hasVoted/selectedOptionId` kullaniciya ozel oldugu icin `poll_votes` tablosuna ayrildi.
- Bir odemenin birden fazla borca dagitilabilmesi icin `payment_allocations` eklendi.
- Uye ekranlarindaki not/hareket ihtiyaci icin `member_notes` ve `unit_ledger_entries` eklendi.
