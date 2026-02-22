-- Finance & Accounting hardening additions
-- This file extends database/postgresql/schema.sql without breaking current tables.

-- =====================================================
-- EXTRA CODE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS accounting_period_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS journal_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS journal_source_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS expense_categories (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS expense_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS bank_transaction_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS reconciliation_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS recurring_payment_frequencies (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS recurring_payment_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS receipt_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS receipt_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS due_generation_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS audit_action_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO accounting_period_statuses (code, label, display_order) VALUES
  ('open', 'Acik', 1),
  ('closed', 'Kapali', 2),
  ('locked', 'Kilitli', 3)
ON CONFLICT (code) DO NOTHING;

INSERT INTO journal_statuses (code, label, display_order) VALUES
  ('draft', 'Taslak', 1),
  ('posted', 'Onayli', 2),
  ('reversed', 'Ters Kayit', 3),
  ('void', 'Iptal', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO journal_source_types (code, label, display_order) VALUES
  ('due', 'Borclandirma', 1),
  ('payment', 'Odeme', 2),
  ('expense', 'Gider', 3),
  ('refund', 'Iade', 4),
  ('manual', 'Manuel', 5),
  ('opening_balance', 'Acilis', 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO expense_categories (code, label, display_order) VALUES
  ('personel', 'Personel', 1),
  ('bakim_onarim', 'Bakim Onarim', 2),
  ('ortak_alan', 'Ortak Alan', 3),
  ('guvenlik', 'Guvenlik', 4),
  ('sigorta', 'Sigorta', 5),
  ('yonetim', 'Yonetim', 6),
  ('diger', 'Diger', 7)
ON CONFLICT (code) DO NOTHING;

INSERT INTO expense_statuses (code, label, display_order) VALUES
  ('draft', 'Taslak', 1),
  ('approved', 'Onaylandi', 2),
  ('posted', 'Muhasebelesti', 3),
  ('paid', 'Odendi', 4),
  ('cancelled', 'Iptal', 5)
ON CONFLICT (code) DO NOTHING;

INSERT INTO bank_transaction_types (code, label, display_order) VALUES
  ('credit', 'Alacak', 1),
  ('debit', 'Borc', 2),
  ('fee', 'Masraf', 3),
  ('interest', 'Faiz', 4),
  ('chargeback', 'Ters Islem', 5),
  ('other', 'Diger', 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO reconciliation_statuses (code, label, display_order) VALUES
  ('unmatched', 'Eslesmedi', 1),
  ('matched', 'Eslesti', 2),
  ('partially_matched', 'Kismi Eslesme', 3),
  ('ignored', 'Yok Sayildi', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO recurring_payment_frequencies (code, label, display_order) VALUES
  ('monthly', 'Aylik', 1),
  ('weekly', 'Haftalik', 2),
  ('custom', 'Ozel', 3)
ON CONFLICT (code) DO NOTHING;

INSERT INTO recurring_payment_statuses (code, label, display_order) VALUES
  ('active', 'Aktif', 1),
  ('paused', 'Duraklatildi', 2),
  ('cancelled', 'Iptal', 3),
  ('failed', 'Hata', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO receipt_types (code, label, display_order) VALUES
  ('collection', 'Tahsilat', 1),
  ('refund', 'Iade', 2),
  ('expense_payment', 'Gider Odemesi', 3),
  ('transfer', 'Transfer', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO receipt_statuses (code, label, display_order) VALUES
  ('draft', 'Taslak', 1),
  ('issued', 'Kesildi', 2),
  ('cancelled', 'Iptal', 3)
ON CONFLICT (code) DO NOTHING;

INSERT INTO due_generation_statuses (code, label, display_order) VALUES
  ('draft', 'Taslak', 1),
  ('processing', 'Isleniyor', 2),
  ('completed', 'Tamamlandi', 3),
  ('failed', 'Basarisiz', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO audit_action_types (code, label, display_order) VALUES
  ('due_created', 'Borc Olusturma', 1),
  ('due_updated', 'Borc Guncelleme', 2),
  ('payment_created', 'Odeme Olusturma', 3),
  ('payment_refunded', 'Odeme Iade', 4),
  ('expense_created', 'Gider Olusturma', 5),
  ('journal_posted', 'Fis Onaylama', 6),
  ('period_closed', 'Donem Kapama', 7)
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- ACCOUNTING CONTROL TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS accounting_periods (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  fiscal_year INTEGER NOT NULL CHECK (fiscal_year >= 2000),
  period_no INTEGER NOT NULL CHECK (period_no BETWEEN 1 AND 12),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status_code TEXT NOT NULL REFERENCES accounting_period_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  closed_at TIMESTAMPTZ,
  closed_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, fiscal_year, period_no)
);

CREATE TABLE IF NOT EXISTS journals (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  period_id TEXT REFERENCES accounting_periods(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  journal_no TEXT NOT NULL,
  journal_date DATE NOT NULL,
  description TEXT NOT NULL,
  source_type_code TEXT NOT NULL REFERENCES journal_source_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  source_id TEXT,
  status_code TEXT NOT NULL DEFAULT 'draft' REFERENCES journal_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  posted_at TIMESTAMPTZ,
  posted_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, journal_no)
);

CREATE TABLE IF NOT EXISTS journal_lines (
  id TEXT PRIMARY KEY,
  journal_id TEXT NOT NULL REFERENCES journals(id) ON UPDATE CASCADE ON DELETE CASCADE,
  line_no INTEGER NOT NULL CHECK (line_no > 0),
  account_id TEXT NOT NULL REFERENCES accounts(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  unit_id TEXT REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  description TEXT,
  debit_kurus BIGINT NOT NULL DEFAULT 0 CHECK (debit_kurus >= 0),
  credit_kurus BIGINT NOT NULL DEFAULT 0 CHECK (credit_kurus >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK ((debit_kurus > 0 AND credit_kurus = 0) OR (credit_kurus > 0 AND debit_kurus = 0)),
  UNIQUE (journal_id, line_no)
);

CREATE TABLE IF NOT EXISTS journal_links (
  id TEXT PRIMARY KEY,
  journal_id TEXT NOT NULL REFERENCES journals(id) ON UPDATE CASCADE ON DELETE CASCADE,
  source_type_code TEXT NOT NULL REFERENCES journal_source_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  source_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (source_type_code, source_id)
);

-- =====================================================
-- EXPENSE & INVOICE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS expense_vendors (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  name TEXT NOT NULL,
  tax_no TEXT,
  iban TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, name)
);

CREATE TABLE IF NOT EXISTS expenses (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  category_code TEXT NOT NULL REFERENCES expense_categories(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  vendor_id TEXT REFERENCES expense_vendors(id) ON UPDATE CASCADE ON DELETE SET NULL,
  expense_date DATE NOT NULL,
  due_date DATE,
  amount_kurus BIGINT NOT NULL CHECK (amount_kurus >= 0),
  vat_kurus BIGINT NOT NULL DEFAULT 0 CHECK (vat_kurus >= 0),
  withholding_kurus BIGINT NOT NULL DEFAULT 0 CHECK (withholding_kurus >= 0),
  total_kurus BIGINT NOT NULL CHECK (total_kurus >= 0),
  description TEXT NOT NULL,
  invoice_no TEXT,
  invoice_date DATE,
  status_code TEXT NOT NULL DEFAULT 'draft' REFERENCES expense_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  accounting_entry_id TEXT REFERENCES accounting_entries(id) ON UPDATE CASCADE ON DELETE SET NULL,
  payment_id TEXT REFERENCES payments(id) ON UPDATE CASCADE ON DELETE SET NULL,
  approved_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  approved_at TIMESTAMPTZ,
  created_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS expense_documents (
  id TEXT PRIMARY KEY,
  expense_id TEXT NOT NULL REFERENCES expenses(id) ON UPDATE CASCADE ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_name TEXT,
  mime_type TEXT,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  uploaded_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

-- =====================================================
-- BANKING & RECONCILIATION TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS bank_accounts (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  bank_name TEXT NOT NULL,
  branch_name TEXT,
  iban TEXT NOT NULL,
  account_no TEXT,
  currency_code TEXT NOT NULL DEFAULT 'TRY',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, iban)
);

CREATE TABLE IF NOT EXISTS bank_statement_imports (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  bank_account_id TEXT NOT NULL REFERENCES bank_accounts(id) ON UPDATE CASCADE ON DELETE CASCADE,
  source_type TEXT NOT NULL,
  source_file_name TEXT,
  imported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  imported_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  line_count INTEGER NOT NULL DEFAULT 0,
  success_count INTEGER NOT NULL DEFAULT 0,
  failure_count INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS bank_transactions (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  bank_account_id TEXT NOT NULL REFERENCES bank_accounts(id) ON UPDATE CASCADE ON DELETE CASCADE,
  import_id TEXT REFERENCES bank_statement_imports(id) ON UPDATE CASCADE ON DELETE SET NULL,
  value_date DATE NOT NULL,
  booking_date DATE,
  reference_no TEXT,
  tx_type_code TEXT NOT NULL REFERENCES bank_transaction_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  amount_kurus BIGINT NOT NULL CHECK (amount_kurus >= 0),
  is_credit BOOLEAN NOT NULL,
  counterparty_name TEXT,
  counterparty_iban TEXT,
  description TEXT,
  raw_data_json JSONB,
  reconciliation_status_code TEXT NOT NULL DEFAULT 'unmatched' REFERENCES reconciliation_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (bank_account_id, reference_no, value_date, amount_kurus, is_credit)
);

CREATE TABLE IF NOT EXISTS bank_reconciliations (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  bank_transaction_id TEXT NOT NULL REFERENCES bank_transactions(id) ON UPDATE CASCADE ON DELETE CASCADE,
  reconciliation_status_code TEXT NOT NULL REFERENCES reconciliation_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  matched_amount_kurus BIGINT NOT NULL DEFAULT 0 CHECK (matched_amount_kurus >= 0),
  note TEXT,
  reconciled_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  reconciled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bank_reconciliation_matches (
  id TEXT PRIMARY KEY,
  reconciliation_id TEXT NOT NULL REFERENCES bank_reconciliations(id) ON UPDATE CASCADE ON DELETE CASCADE,
  payment_id TEXT REFERENCES payments(id) ON UPDATE CASCADE ON DELETE CASCADE,
  accounting_entry_id TEXT REFERENCES accounting_entries(id) ON UPDATE CASCADE ON DELETE CASCADE,
  matched_amount_kurus BIGINT NOT NULL CHECK (matched_amount_kurus >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (payment_id IS NOT NULL OR accounting_entry_id IS NOT NULL)
);

-- =====================================================
-- COLLECTION DOCUMENT TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS collection_receipts (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  receipt_type_code TEXT NOT NULL REFERENCES receipt_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  status_code TEXT NOT NULL DEFAULT 'issued' REFERENCES receipt_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  receipt_no TEXT NOT NULL,
  issue_date TIMESTAMPTZ NOT NULL,
  payer_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  unit_id TEXT REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  payment_id TEXT REFERENCES payments(id) ON UPDATE CASCADE ON DELETE SET NULL,
  total_amount_kurus BIGINT NOT NULL CHECK (total_amount_kurus >= 0),
  description TEXT,
  issued_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (site_id, receipt_no)
);

CREATE TABLE IF NOT EXISTS collection_receipt_items (
  id TEXT PRIMARY KEY,
  receipt_id TEXT NOT NULL REFERENCES collection_receipts(id) ON UPDATE CASCADE ON DELETE CASCADE,
  due_id TEXT REFERENCES dues(id) ON UPDATE CASCADE ON DELETE SET NULL,
  payment_allocation_id TEXT REFERENCES payment_allocations(id) ON UPDATE CASCADE ON DELETE SET NULL,
  line_description TEXT,
  amount_kurus BIGINT NOT NULL CHECK (amount_kurus >= 0),
  delay_fee_kurus BIGINT NOT NULL DEFAULT 0 CHECK (delay_fee_kurus >= 0),
  total_kurus BIGINT NOT NULL CHECK (total_kurus >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (due_id IS NOT NULL OR payment_allocation_id IS NOT NULL)
);

-- =====================================================
-- AUTOMATION / RULE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS due_generation_batches (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  due_type_code TEXT NOT NULL REFERENCES due_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
  period_year INTEGER NOT NULL CHECK (period_year >= 2000),
  status_code TEXT NOT NULL REFERENCES due_generation_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  total_units INTEGER NOT NULL DEFAULT 0 CHECK (total_units >= 0),
  generated_count INTEGER NOT NULL DEFAULT 0 CHECK (generated_count >= 0),
  failed_count INTEGER NOT NULL DEFAULT 0 CHECK (failed_count >= 0),
  run_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (site_id, due_type_code, period_month, period_year)
);

CREATE TABLE IF NOT EXISTS due_generation_batch_items (
  id TEXT PRIMARY KEY,
  batch_id TEXT NOT NULL REFERENCES due_generation_batches(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_id TEXT NOT NULL REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  due_id TEXT REFERENCES dues(id) ON UPDATE CASCADE ON DELETE SET NULL,
  amount_kurus BIGINT NOT NULL CHECK (amount_kurus >= 0),
  status_code TEXT NOT NULL,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (batch_id, unit_id)
);

CREATE TABLE IF NOT EXISTS delay_fee_policies (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  due_type_code TEXT REFERENCES due_types(code) ON UPDATE CASCADE ON DELETE SET NULL,
  monthly_rate NUMERIC(8,6) NOT NULL CHECK (monthly_rate >= 0),
  grace_days INTEGER NOT NULL DEFAULT 0 CHECK (grace_days >= 0),
  is_compound BOOLEAN NOT NULL DEFAULT FALSE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  effective_from DATE NOT NULL,
  effective_to DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS recurring_payment_instructions (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_id TEXT REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  frequency_code TEXT NOT NULL REFERENCES recurring_payment_frequencies(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  status_code TEXT NOT NULL REFERENCES recurring_payment_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  day_of_month INTEGER CHECK (day_of_month BETWEEN 1 AND 31),
  fixed_amount_kurus BIGINT,
  pay_full_debt BOOLEAN NOT NULL DEFAULT TRUE,
  payment_method_code TEXT REFERENCES payment_methods(code) ON UPDATE CASCADE ON DELETE SET NULL,
  card_token_ref TEXT,
  start_date DATE NOT NULL,
  end_date DATE,
  last_run_at TIMESTAMPTZ,
  next_run_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  CHECK (fixed_amount_kurus IS NULL OR fixed_amount_kurus >= 0)
);

CREATE TABLE IF NOT EXISTS recurring_payment_runs (
  id TEXT PRIMARY KEY,
  instruction_id TEXT NOT NULL REFERENCES recurring_payment_instructions(id) ON UPDATE CASCADE ON DELETE CASCADE,
  run_at TIMESTAMPTZ NOT NULL,
  status_code TEXT NOT NULL,
  amount_kurus BIGINT NOT NULL DEFAULT 0 CHECK (amount_kurus >= 0),
  payment_id TEXT REFERENCES payments(id) ON UPDATE CASCADE ON DELETE SET NULL,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- AUDIT TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS financial_audit_logs (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  action_type_code TEXT NOT NULL REFERENCES audit_action_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  actor_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  amount_kurus BIGINT,
  before_data_json JSONB,
  after_data_json JSONB,
  ip_address INET,
  device_info TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_accounting_periods_site_year_period ON accounting_periods(site_id, fiscal_year, period_no);
CREATE INDEX IF NOT EXISTS idx_journals_site_date_status ON journals(site_id, journal_date, status_code);
CREATE INDEX IF NOT EXISTS idx_journal_lines_journal_account ON journal_lines(journal_id, account_id);

CREATE INDEX IF NOT EXISTS idx_expenses_site_date_status ON expenses(site_id, expense_date, status_code);
CREATE INDEX IF NOT EXISTS idx_expenses_vendor ON expenses(vendor_id);

CREATE INDEX IF NOT EXISTS idx_bank_tx_account_value_date ON bank_transactions(bank_account_id, value_date);
CREATE INDEX IF NOT EXISTS idx_bank_tx_reconciliation_status ON bank_transactions(reconciliation_status_code);
CREATE INDEX IF NOT EXISTS idx_bank_reconciliations_tx ON bank_reconciliations(bank_transaction_id);

CREATE INDEX IF NOT EXISTS idx_receipts_site_issue_date ON collection_receipts(site_id, issue_date);
CREATE INDEX IF NOT EXISTS idx_receipt_items_receipt ON collection_receipt_items(receipt_id);

CREATE INDEX IF NOT EXISTS idx_due_batches_site_period ON due_generation_batches(site_id, period_year, period_month);
CREATE INDEX IF NOT EXISTS idx_recurring_instructions_user_status ON recurring_payment_instructions(user_id, status_code);
CREATE INDEX IF NOT EXISTS idx_recurring_runs_instruction_run_at ON recurring_payment_runs(instruction_id, run_at);

CREATE INDEX IF NOT EXISTS idx_fin_audit_site_created ON financial_audit_logs(site_id, created_at);
CREATE INDEX IF NOT EXISTS idx_fin_audit_entity ON financial_audit_logs(entity_type, entity_id);
