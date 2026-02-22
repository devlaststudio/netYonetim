# Finans ve Muhasebe Uygunluk Denetimi

## Sonuc (Kisa)

- Mevcut yapi **MVP icin uygun**.
- Ancak finans/muhasebe modulu canli ortama cikacaksa mevcut yapi **eksik**.
- En kritik eksikler: cift tarafli muhasebe (journal), donem kapama, banka mutabakati, gider-fatura akis, denetim izi.

## Mevcut Sema Uzerindeki Bulgular

1. **Kritik - Cift tarafli muhasebe zorlanamiyor**
- `accounting_entries` tek satir/tek hesap modeli kullaniyor; transfer/islem dengesi tablo seviyesinde garanti degil.
- Referans: `database/postgresql/schema.sql:735`

2. **Kritik - Donem kapama/kitlenme tablosu yok**
- Kapanmis ay/yil uzerinde geriye donuk degisikligi kontrol edecek `accounting_periods` benzeri yapi yok.
- Referans: `database/postgresql/schema.sql:754`

3. **Yuksek - Borc/odeme mutabakat butunlugu eksik**
- `payment_allocations` var ama odeme toplami = allocation toplami ve due toplami = paid tutar kurali DB katmaninda zorlanmiyor.
- Referans: `database/postgresql/schema.sql:464`, `database/postgresql/schema.sql:484`, `database/postgresql/schema.sql:500`

4. **Yuksek - Gider/fatura tedarikci akis tablolari yok**
- Finans planda yer alan gider/fatura islemleri icin `expenses`, `vendors`, `expense_documents` gibi tablolar eksik.
- Referans: `plan/05_finans_odeme_plani.md:24`

5. **Yuksek - Banka entegrasyon/mutabakat tablolari yok**
- MT940 import ve otomatik eslestirme icin statement/transaction/reconciliation tablolari yok.
- Referans: `plan/05_finans_odeme_plani.md:97`

6. **Yuksek - Finansal denetim izi tablosu yok**
- Finans islemlerinin regule audit trail kaydi icin ozel log tablosu yok.
- Referans: `plan/05_finans_odeme_plani.md:192`

7. **Orta - Otomatik odeme talimati tablosu yok**
- `RecurringPayment` icin kalici model eksik.
- Referans: `plan/05_finans_odeme_plani.md:83`

8. **Orta - Makbuz/evrak numaralandirma tablosu yok**
- Tahsilat makbuzu, iade makbuzu, seri-no takibi icin belge tablolari eksik.
- Referans: `plan/05_finans_odeme_plani.md:80`

9. **Orta - Hesap bakiyesi denormalize ama kontrolsuz**
- `accounts.balance_kurus` tutuluyor, fakat DB tarafinda tutarlilik garantisi (posting/trigger) tanimli degil.
- Referans: `database/postgresql/schema.sql:720`

## Gerekli Ek Tablolar (DB Katmani)

### A) Muhasebe Cekirdegi
- `accounting_periods`
- `journals`
- `journal_lines`
- `journal_links` (operasyonel kayit -> muhasebe fis iliskisi)

### B) Gider / Fatura
- `expense_vendors`
- `expenses`
- `expense_documents`

### C) Banka ve Mutabakat
- `bank_accounts`
- `bank_statement_imports`
- `bank_transactions`
- `bank_reconciliations`
- `bank_reconciliation_matches`

### D) Tahsilat ve Dokuman
- `collection_receipts`
- `collection_receipt_items`

### E) Otomasyon ve Kurallar
- `recurring_payment_instructions`
- `recurring_payment_runs`
- `due_generation_batches`
- `due_generation_batch_items`
- `delay_fee_policies`

### F) Guvenlik ve Izlenebilirlik
- `financial_audit_logs`

## Gerekli Ek Kod Tablolari

- `accounting_period_statuses`
- `journal_statuses`
- `journal_source_types`
- `expense_categories`
- `expense_statuses`
- `bank_transaction_types`
- `reconciliation_statuses`
- `recurring_payment_frequencies`
- `recurring_payment_statuses`
- `receipt_types`
- `receipt_statuses`
- `due_generation_statuses`
- `audit_action_types`

## Degerlendirme

- Simdiki yapi: mobil UI + temel tahsilat raporu icin yeterli.
- Hedeflenen finans/muhasebe kapsaminda: ek tablolarsiz canliya cikmasi riskli.
- Oneri: mevcut semayi koru, ekleri migration ile asamali ac.
