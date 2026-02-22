-- =====================================================
-- CODE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS user_roles (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS unit_relation_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS unit_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS due_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS due_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS payment_methods (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS payment_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS ticket_categories (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS ticket_priorities (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS ticket_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS announcement_priorities (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS visitor_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS technician_categories (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS service_request_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS facility_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS reservation_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS account_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS entry_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS budget_periods (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS budget_statuses (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS report_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS report_periods (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS ledger_source_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);

-- =====================================================
-- CODE TABLE SEED DATA
-- =====================================================

INSERT INTO user_roles (code, label, display_order) VALUES
  ('admin', 'Site Yoneticisi', 1),
  ('manager', 'Yonetici', 2),
  ('resident', 'Kat Maliki', 3),
  ('tenant', 'Kiraci', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO unit_relation_types (code, label, display_order) VALUES
  ('owner', 'Malik', 1),
  ('tenant', 'Kiraci', 2),
  ('representative', 'Vekil', 3),
  ('vacant', 'Bos Daire', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO unit_types (code, label, display_order) VALUES
  ('apartment', 'Daire', 1),
  ('shop', 'Dukkan', 2),
  ('office', 'Ofis', 3),
  ('storage', 'Depo', 4),
  ('parking', 'Otopark', 5),
  ('other', 'Diger', 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO due_types (code, label, display_order) VALUES
  ('aidat', 'Aidat', 1),
  ('su', 'Su', 2),
  ('elektrik', 'Elektrik', 3),
  ('dogalgaz', 'Dogalgaz', 4),
  ('demirbas', 'Demirbas', 5),
  ('yakit', 'Yakit', 6),
  ('isitma', 'Isitma', 7),
  ('diger', 'Diger', 8)
ON CONFLICT (code) DO NOTHING;

INSERT INTO due_statuses (code, label, display_order) VALUES
  ('pending', 'Bekliyor', 1),
  ('overdue', 'Gecikmis', 2),
  ('partially_paid', 'Kismi Odendi', 3),
  ('paid', 'Odendi', 4),
  ('cancelled', 'Iptal', 5)
ON CONFLICT (code) DO NOTHING;

INSERT INTO payment_methods (code, label, display_order) VALUES
  ('cash', 'Nakit', 1),
  ('bank_transfer', 'Havale/EFT', 2),
  ('credit_card', 'Kredi Karti', 3),
  ('digital_wallet', 'Dijital Cuzdan', 4),
  ('check', 'Cek', 5),
  ('other', 'Diger', 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO payment_statuses (code, label, display_order) VALUES
  ('pending', 'Bekliyor', 1),
  ('processing', 'Isleniyor', 2),
  ('completed', 'Tamamlandi', 3),
  ('failed', 'Basarisiz', 4),
  ('refunded', 'Iade Edildi', 5),
  ('cancelled', 'Iptal', 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO ticket_categories (code, label, display_order) VALUES
  ('ariza', 'Ariza', 1),
  ('temizlik', 'Temizlik', 2),
  ('guvenlik', 'Guvenlik', 3),
  ('oneri', 'Oneri', 4),
  ('sikayet', 'Sikayet', 5),
  ('diger', 'Diger', 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO ticket_priorities (code, label, display_order) VALUES
  ('low', 'Dusuk', 1),
  ('medium', 'Orta', 2),
  ('high', 'Yuksek', 3),
  ('urgent', 'Acil', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO ticket_statuses (code, label, display_order) VALUES
  ('open', 'Acik', 1),
  ('in_progress', 'Islemde', 2),
  ('resolved', 'Cozuldu', 3),
  ('closed', 'Kapatildi', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO announcement_priorities (code, label, display_order) VALUES
  ('normal', 'Normal', 1),
  ('important', 'Onemli', 2),
  ('urgent', 'Acil', 3)
ON CONFLICT (code) DO NOTHING;

INSERT INTO visitor_statuses (code, label, display_order) VALUES
  ('expected', 'Bekleniyor', 1),
  ('inside', 'Iceride', 2),
  ('left', 'Ayrildi', 3),
  ('cancelled', 'Iptal', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO technician_categories (code, label, display_order) VALUES
  ('plumbing', 'Sihhi Tesisat', 1),
  ('electric', 'Elektrik', 2),
  ('cleaning', 'Temizlik', 3),
  ('security', 'Guvenlik', 4),
  ('painting', 'Boya', 5),
  ('furniture', 'Mobilya', 6),
  ('other', 'Diger', 7)
ON CONFLICT (code) DO NOTHING;

INSERT INTO service_request_statuses (code, label, display_order) VALUES
  ('pending', 'Bekliyor', 1),
  ('approved', 'Onaylandi', 2),
  ('in_progress', 'Islemde', 3),
  ('completed', 'Tamamlandi', 4),
  ('cancelled', 'Iptal', 5)
ON CONFLICT (code) DO NOTHING;

INSERT INTO facility_types (code, label, display_order) VALUES
  ('facility', 'Tesis', 1),
  ('event', 'Etkinlik', 2)
ON CONFLICT (code) DO NOTHING;

INSERT INTO reservation_statuses (code, label, display_order) VALUES
  ('active', 'Aktif', 1),
  ('completed', 'Tamamlandi', 2),
  ('cancelled', 'Iptal', 3),
  ('no_show', 'Gelmedi', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO account_types (code, label, display_order) VALUES
  ('income', 'Gelir', 1),
  ('expense', 'Gider', 2),
  ('asset', 'Varlik', 3),
  ('liability', 'Yukumluluk', 4),
  ('equity', 'Oz Sermaye', 5)
ON CONFLICT (code) DO NOTHING;

INSERT INTO entry_types (code, label, display_order) VALUES
  ('income', 'Gelir', 1),
  ('expense', 'Gider', 2),
  ('transfer', 'Transfer', 3)
ON CONFLICT (code) DO NOTHING;

INSERT INTO budget_periods (code, label, display_order) VALUES
  ('monthly', 'Aylik', 1),
  ('quarterly', 'Ceyreklik', 2),
  ('yearly', 'Yillik', 3)
ON CONFLICT (code) DO NOTHING;

INSERT INTO budget_statuses (code, label, display_order) VALUES
  ('draft', 'Taslak', 1),
  ('active', 'Aktif', 2),
  ('completed', 'Tamamlandi', 3),
  ('cancelled', 'Iptal', 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO report_types (code, label, display_order) VALUES
  ('balance_sheet', 'Mizan', 1),
  ('income_statement', 'Gelir-Gider Tablosu', 2),
  ('debt_status', 'Borc Durum Raporu', 3),
  ('collection_report', 'Tahsilat Raporu', 4),
  ('expense_analysis', 'Gider Analizi', 5),
  ('cash_flow', 'Kasa Raporu', 6),
  ('audit_report', 'Denetim Raporu', 7)
ON CONFLICT (code) DO NOTHING;

INSERT INTO report_periods (code, label, display_order) VALUES
  ('daily', 'Gunluk', 1),
  ('weekly', 'Haftalik', 2),
  ('monthly', 'Aylik', 3),
  ('quarterly', 'Ceyreklik', 4),
  ('yearly', 'Yillik', 5),
  ('custom', 'Ozel', 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO ledger_source_types (code, label, display_order) VALUES
  ('due_charge', 'Borclandirma', 1),
  ('payment', 'Odeme', 2),
  ('adjustment', 'Duzeltme', 3),
  ('manual_entry', 'Manuel Kayit', 4)
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- CORE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS sites (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT,
  district TEXT,
  unit_count INTEGER NOT NULL DEFAULT 0 CHECK (unit_count >= 0),
  block_count INTEGER NOT NULL DEFAULT 0 CHECK (block_count >= 0),
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS blocks (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  name TEXT NOT NULL,
  floor_count INTEGER NOT NULL DEFAULT 0 CHECK (floor_count >= 0),
  unit_count INTEGER NOT NULL DEFAULT 0 CHECK (unit_count >= 0),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, name)
);

CREATE TABLE IF NOT EXISTS units (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  block_id TEXT NOT NULL REFERENCES blocks(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_no TEXT NOT NULL,
  floor INTEGER,
  area_sqm NUMERIC(10,2),
  unit_type_code TEXT NOT NULL DEFAULT 'apartment' REFERENCES unit_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  arsa_payi NUMERIC(10,6),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, block_id, unit_no)
);

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  tc_kimlik TEXT UNIQUE,
  password_hash TEXT,
  avatar_url TEXT,
  gender TEXT,
  education TEXT,
  profession TEXT,
  address TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS site_memberships (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  role_code TEXT NOT NULL REFERENCES user_roles(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  started_at DATE,
  ended_at DATE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, user_id, role_code)
);

CREATE TABLE IF NOT EXISTS unit_residents (
  id TEXT PRIMARY KEY,
  unit_id TEXT NOT NULL REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  relation_type_code TEXT NOT NULL REFERENCES unit_relation_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  start_date DATE NOT NULL,
  end_date DATE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  owner_share_pct NUMERIC(5,2) CHECK (owner_share_pct BETWEEN 0 AND 100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (unit_id, user_id, relation_type_code, start_date)
);

CREATE TABLE IF NOT EXISTS vehicles (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_id TEXT NOT NULL REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  plate_number TEXT NOT NULL,
  vehicle_type TEXT,
  brand TEXT,
  model TEXT,
  color TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, plate_number)
);

CREATE TABLE IF NOT EXISTS member_notes (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_id TEXT NOT NULL REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  resident_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  author_user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS unit_ledger_entries (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_id TEXT NOT NULL REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  resident_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  source_type_code TEXT NOT NULL DEFAULT 'manual_entry' REFERENCES ledger_source_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  source_id TEXT,
  transaction_date DATE NOT NULL,
  due_date DATE,
  description TEXT NOT NULL,
  debit_kurus BIGINT NOT NULL DEFAULT 0 CHECK (debit_kurus >= 0),
  credit_kurus BIGINT NOT NULL DEFAULT 0 CHECK (credit_kurus >= 0),
  running_balance_kurus BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (debit_kurus = 0 OR credit_kurus = 0)
);

-- =====================================================
-- FINANCE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS dues (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_id TEXT NOT NULL REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  due_type_code TEXT NOT NULL REFERENCES due_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  amount_kurus BIGINT NOT NULL CHECK (amount_kurus >= 0),
  paid_amount_kurus BIGINT NOT NULL DEFAULT 0 CHECK (paid_amount_kurus >= 0),
  delay_fee_kurus BIGINT NOT NULL DEFAULT 0 CHECK (delay_fee_kurus >= 0),
  due_date DATE NOT NULL,
  paid_date TIMESTAMPTZ,
  description TEXT NOT NULL,
  period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
  period_year INTEGER NOT NULL CHECK (period_year >= 2000),
  status_code TEXT NOT NULL DEFAULT 'pending' REFERENCES due_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  created_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  CHECK (paid_amount_kurus <= amount_kurus + delay_fee_kurus)
);

CREATE TABLE IF NOT EXISTS payments (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  payer_user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  total_amount_kurus BIGINT NOT NULL CHECK (total_amount_kurus >= 0),
  payment_method_code TEXT NOT NULL REFERENCES payment_methods(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  status_code TEXT NOT NULL REFERENCES payment_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  payment_date TIMESTAMPTZ NOT NULL,
  transaction_id TEXT UNIQUE,
  commission_amount_kurus BIGINT NOT NULL DEFAULT 0 CHECK (commission_amount_kurus >= 0),
  description TEXT,
  gateway_response_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS payment_allocations (
  id TEXT PRIMARY KEY,
  payment_id TEXT NOT NULL REFERENCES payments(id) ON UPDATE CASCADE ON DELETE CASCADE,
  due_id TEXT NOT NULL REFERENCES dues(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  allocated_amount_kurus BIGINT NOT NULL CHECK (allocated_amount_kurus >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (payment_id, due_id)
);

-- =====================================================
-- TICKET / ANNOUNCEMENT / VISITOR TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS tickets (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  unit_id TEXT REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  category_code TEXT NOT NULL REFERENCES ticket_categories(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  priority_code TEXT NOT NULL REFERENCES ticket_priorities(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status_code TEXT NOT NULL DEFAULT 'open' REFERENCES ticket_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  assigned_to_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS ticket_comments (
  id TEXT PRIMARY KEY,
  ticket_id TEXT NOT NULL REFERENCES tickets(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  content TEXT NOT NULL,
  is_staff BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS announcements (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  priority_code TEXT NOT NULL DEFAULT 'normal' REFERENCES announcement_priorities(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  publish_date TIMESTAMPTZ NOT NULL,
  expire_date TIMESTAMPTZ,
  created_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  send_push BOOLEAN NOT NULL DEFAULT FALSE,
  send_sms BOOLEAN NOT NULL DEFAULT FALSE,
  send_email BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS announcement_reads (
  id TEXT PRIMARY KEY,
  announcement_id TEXT NOT NULL REFERENCES announcements(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (announcement_id, user_id)
);

CREATE TABLE IF NOT EXISTS visitors (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_id TEXT REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  resident_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  guest_name TEXT NOT NULL,
  guest_phone TEXT,
  plate_number TEXT,
  expected_date TIMESTAMPTZ NOT NULL,
  status_code TEXT NOT NULL DEFAULT 'expected' REFERENCES visitor_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  note TEXT,
  entry_time TIMESTAMPTZ,
  exit_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- =====================================================
-- SERVICE / POLL / RESERVATION TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS technicians (
  id TEXT PRIMARY KEY,
  site_id TEXT REFERENCES sites(id) ON UPDATE CASCADE ON DELETE SET NULL,
  name TEXT NOT NULL,
  category_code TEXT NOT NULL REFERENCES technician_categories(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  photo_url TEXT,
  phone_number TEXT,
  biography TEXT,
  rating_avg NUMERIC(3,2) NOT NULL DEFAULT 0 CHECK (rating_avg BETWEEN 0 AND 5),
  review_count INTEGER NOT NULL DEFAULT 0 CHECK (review_count >= 0),
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS technician_skills (
  id TEXT PRIMARY KEY,
  technician_id TEXT NOT NULL REFERENCES technicians(id) ON UPDATE CASCADE ON DELETE CASCADE,
  skill_name TEXT NOT NULL,
  UNIQUE (technician_id, skill_name)
);

CREATE TABLE IF NOT EXISTS service_requests (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  unit_id TEXT REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  resident_user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  technician_id TEXT NOT NULL REFERENCES technicians(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  category_code TEXT NOT NULL REFERENCES technician_categories(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  description TEXT NOT NULL,
  status_code TEXT NOT NULL DEFAULT 'pending' REFERENCES service_request_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  request_date TIMESTAMPTZ NOT NULL,
  appointment_date TIMESTAMPTZ NOT NULL,
  rating NUMERIC(3,2) CHECK (rating BETWEEN 0 AND 5),
  review_comment TEXT,
  completed_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS service_request_photos (
  id TEXT PRIMARY KEY,
  service_request_id TEXT NOT NULL REFERENCES service_requests(id) ON UPDATE CASCADE ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (service_request_id, sort_order)
);

CREATE TABLE IF NOT EXISTS technician_reviews (
  id TEXT PRIMARY KEY,
  technician_id TEXT NOT NULL REFERENCES technicians(id) ON UPDATE CASCADE ON DELETE CASCADE,
  service_request_id TEXT UNIQUE REFERENCES service_requests(id) ON UPDATE CASCADE ON DELETE SET NULL,
  user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  rating NUMERIC(3,2) NOT NULL CHECK (rating BETWEEN 0 AND 5),
  comment TEXT,
  review_date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS polls (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  end_date TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS poll_options (
  id TEXT PRIMARY KEY,
  poll_id TEXT NOT NULL REFERENCES polls(id) ON UPDATE CASCADE ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  vote_count INTEGER NOT NULL DEFAULT 0 CHECK (vote_count >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (poll_id, sort_order)
);

CREATE TABLE IF NOT EXISTS poll_votes (
  id TEXT PRIMARY KEY,
  poll_id TEXT NOT NULL REFERENCES polls(id) ON UPDATE CASCADE ON DELETE CASCADE,
  option_id TEXT NOT NULL REFERENCES poll_options(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  voted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (poll_id, user_id)
);

CREATE TABLE IF NOT EXISTS facilities (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  name TEXT NOT NULL,
  facility_type_code TEXT NOT NULL REFERENCES facility_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  capacity INTEGER NOT NULL DEFAULT 1 CHECK (capacity > 0),
  photo_url TEXT,
  description TEXT,
  open_time TIME NOT NULL,
  close_time TIME NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS facility_schedules (
  id TEXT PRIMARY KEY,
  facility_id TEXT NOT NULL REFERENCES facilities(id) ON UPDATE CASCADE ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
  open_time TIME NOT NULL,
  close_time TIME NOT NULL,
  is_closed BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (facility_id, day_of_week)
);

CREATE TABLE IF NOT EXISTS reservations (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  facility_id TEXT NOT NULL REFERENCES facilities(id) ON UPDATE CASCADE ON DELETE CASCADE,
  resident_user_id TEXT NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  unit_id TEXT REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  start_time TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
  end_time TIMESTAMPTZ NOT NULL,
  status_code TEXT NOT NULL DEFAULT 'active' REFERENCES reservation_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (facility_id, start_time, resident_user_id)
);

-- =====================================================
-- ACCOUNTING TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS accounts (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  account_type_code TEXT NOT NULL REFERENCES account_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  parent_account_id TEXT REFERENCES accounts(id) ON UPDATE CASCADE ON DELETE SET NULL,
  balance_kurus BIGINT NOT NULL DEFAULT 0,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, code)
);

CREATE TABLE IF NOT EXISTS accounting_entries (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  account_code_snapshot TEXT,
  account_name_snapshot TEXT,
  entry_type_code TEXT NOT NULL REFERENCES entry_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  amount_kurus BIGINT NOT NULL CHECK (amount_kurus >= 0),
  transaction_date TIMESTAMPTZ NOT NULL,
  description TEXT NOT NULL,
  document_number TEXT,
  reference TEXT,
  payment_method_code TEXT REFERENCES payment_methods(code) ON UPDATE CASCADE ON DELETE SET NULL,
  unit_id TEXT REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS budgets (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  name TEXT NOT NULL,
  period_code TEXT NOT NULL REFERENCES budget_periods(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  year INTEGER NOT NULL CHECK (year >= 2000),
  month INTEGER CHECK (month BETWEEN 1 AND 12),
  quarter INTEGER CHECK (quarter BETWEEN 1 AND 4),
  status_code TEXT NOT NULL DEFAULT 'draft' REFERENCES budget_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  notes TEXT,
  created_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE (site_id, name, year, period_code, month, quarter)
);

CREATE TABLE IF NOT EXISTS budget_items (
  id TEXT PRIMARY KEY,
  budget_id TEXT NOT NULL REFERENCES budgets(id) ON UPDATE CASCADE ON DELETE CASCADE,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  account_code_snapshot TEXT,
  account_name_snapshot TEXT,
  planned_amount_kurus BIGINT NOT NULL CHECK (planned_amount_kurus >= 0),
  actual_amount_kurus BIGINT NOT NULL DEFAULT 0 CHECK (actual_amount_kurus >= 0),
  notes TEXT,
  UNIQUE (budget_id, account_id)
);

CREATE TABLE IF NOT EXISTS financial_reports (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  report_type_code TEXT NOT NULL REFERENCES report_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  report_period_code TEXT NOT NULL REFERENCES report_periods(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  generated_at TIMESTAMPTZ NOT NULL,
  generated_by_user_id TEXT REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  total_income_kurus BIGINT NOT NULL DEFAULT 0,
  total_expense_kurus BIGINT NOT NULL DEFAULT 0,
  net_income_kurus BIGINT NOT NULL DEFAULT 0,
  total_debt_kurus BIGINT NOT NULL DEFAULT 0,
  total_collection_kurus BIGINT NOT NULL DEFAULT 0,
  transaction_count INTEGER NOT NULL DEFAULT 0 CHECK (transaction_count >= 0),
  category_breakdown_json JSONB,
  report_data_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_blocks_site_id ON blocks(site_id);
CREATE INDEX IF NOT EXISTS idx_units_site_block ON units(site_id, block_id);
CREATE INDEX IF NOT EXISTS idx_units_unit_no ON units(unit_no);

CREATE INDEX IF NOT EXISTS idx_site_memberships_user_site ON site_memberships(user_id, site_id, is_active);
CREATE INDEX IF NOT EXISTS idx_unit_residents_unit_active ON unit_residents(unit_id, is_active, start_date);
CREATE INDEX IF NOT EXISTS idx_unit_residents_user_active ON unit_residents(user_id, is_active);

CREATE INDEX IF NOT EXISTS idx_vehicles_site_plate ON vehicles(site_id, plate_number);
CREATE INDEX IF NOT EXISTS idx_member_notes_unit_created ON member_notes(unit_id, created_at);
CREATE INDEX IF NOT EXISTS idx_ledger_unit_tx_date ON unit_ledger_entries(unit_id, transaction_date);

CREATE INDEX IF NOT EXISTS idx_dues_site_status_due_date ON dues(site_id, status_code, due_date);
CREATE INDEX IF NOT EXISTS idx_dues_unit_status ON dues(unit_id, status_code);
CREATE INDEX IF NOT EXISTS idx_dues_period ON dues(period_year, period_month);

CREATE INDEX IF NOT EXISTS idx_payments_site_payment_date ON payments(site_id, payment_date);
CREATE INDEX IF NOT EXISTS idx_payments_payer_payment_date ON payments(payer_user_id, payment_date);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status_code);

CREATE INDEX IF NOT EXISTS idx_payment_alloc_due ON payment_allocations(due_id);
CREATE INDEX IF NOT EXISTS idx_payment_alloc_payment ON payment_allocations(payment_id);

CREATE INDEX IF NOT EXISTS idx_tickets_site_status_created ON tickets(site_id, status_code, created_at);
CREATE INDEX IF NOT EXISTS idx_tickets_user_status ON tickets(user_id, status_code);
CREATE INDEX IF NOT EXISTS idx_tickets_assignee_status ON tickets(assigned_to_user_id, status_code);
CREATE INDEX IF NOT EXISTS idx_ticket_comments_ticket_created ON ticket_comments(ticket_id, created_at);

CREATE INDEX IF NOT EXISTS idx_announcements_site_publish ON announcements(site_id, publish_date);
CREATE INDEX IF NOT EXISTS idx_announcements_expire ON announcements(expire_date);
CREATE INDEX IF NOT EXISTS idx_announcement_reads_user ON announcement_reads(user_id, read_at);

CREATE INDEX IF NOT EXISTS idx_visitors_site_status_expected ON visitors(site_id, status_code, expected_date);
CREATE INDEX IF NOT EXISTS idx_visitors_resident_status ON visitors(resident_user_id, status_code);

CREATE INDEX IF NOT EXISTS idx_service_requests_site_status_appt ON service_requests(site_id, status_code, appointment_date);
CREATE INDEX IF NOT EXISTS idx_service_requests_resident_status ON service_requests(resident_user_id, status_code);
CREATE INDEX IF NOT EXISTS idx_service_requests_technician_status ON service_requests(technician_id, status_code);

CREATE INDEX IF NOT EXISTS idx_poll_votes_user_poll ON poll_votes(user_id, poll_id);

CREATE INDEX IF NOT EXISTS idx_reservations_facility_start_status ON reservations(facility_id, start_time, status_code);
CREATE INDEX IF NOT EXISTS idx_reservations_resident_start ON reservations(resident_user_id, start_time);

CREATE INDEX IF NOT EXISTS idx_accounts_site_parent ON accounts(site_id, parent_account_id);
CREATE INDEX IF NOT EXISTS idx_accounting_entries_site_tx_date ON accounting_entries(site_id, transaction_date);
CREATE INDEX IF NOT EXISTS idx_accounting_entries_account_tx_date ON accounting_entries(account_id, transaction_date);
CREATE INDEX IF NOT EXISTS idx_accounting_entries_unit ON accounting_entries(unit_id);

CREATE INDEX IF NOT EXISTS idx_budgets_site_year_status ON budgets(site_id, year, status_code);
CREATE INDEX IF NOT EXISTS idx_fin_reports_site_generated_type ON financial_reports(site_id, generated_at, report_type_code);

-- =====================================================
-- HELPER VIEWS
-- =====================================================

CREATE OR REPLACE VIEW v_due_open_amounts AS
SELECT
  d.id,
  d.site_id,
  d.unit_id,
  d.due_type_code,
  d.status_code,
  d.amount_kurus,
  d.paid_amount_kurus,
  d.delay_fee_kurus,
  (d.amount_kurus + d.delay_fee_kurus - d.paid_amount_kurus) AS remaining_kurus,
  d.due_date
FROM dues d;

CREATE OR REPLACE VIEW v_poll_results AS
SELECT
  po.poll_id,
  po.id AS option_id,
  po.option_text,
  po.vote_count,
  COALESCE(t.total_votes, 0) AS total_votes
FROM poll_options po
LEFT JOIN (
  SELECT poll_id, SUM(vote_count) AS total_votes
  FROM poll_options
  GROUP BY poll_id
) t ON t.poll_id = po.poll_id;
