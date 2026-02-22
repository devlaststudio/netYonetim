# Database

## Dosyalar

- `sqlite/schema.sql`: Lokal SQLite semasi
- `postgresql/schema.sql`: PostgreSQL semasi
- `postgresql/finance_accounting_additions.sql`: Finans/muhasebe canliya gecis ek tablolari
- `analysis_and_migration_plan.md`: Analiz + DB karar notlari
- `er_overview.md`: Tablo iliski ozeti
- `finance_accounting_assessment.md`: Finans/muhasebe uygunluk denetimi

## Hizli Kurulum

### SQLite

```bash
sqlite3 local.db < database/sqlite/schema.sql
```

### PostgreSQL

```bash
psql "$DATABASE_URL" -f database/postgresql/schema.sql
```

### PostgreSQL (finans/muhasebe ekleri)

```bash
psql "$DATABASE_URL" -f database/postgresql/finance_accounting_additions.sql
```

## Not

- Sema para alanlarini `*_kurus` olarak tutar.
- Kod tablolari ilk calismada seed edilir (`INSERT OR IGNORE` / `ON CONFLICT DO NOTHING`).
