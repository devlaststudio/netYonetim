PRAGMA foreign_keys = ON;

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

INSERT OR IGNORE INTO user_roles (code, label, display_order) VALUES
  ('admin', 'Site Yoneticisi', 1),
  ('manager', 'Yonetici', 2),
  ('resident', 'Kat Maliki', 3),
  ('tenant', 'Kiraci', 4);

INSERT OR IGNORE INTO unit_relation_types (code, label, display_order) VALUES
  ('owner', 'Malik', 1),
  ('tenant', 'Kiraci', 2),
  ('representative', 'Vekil', 3),
  ('vacant', 'Bos Daire', 4);

INSERT OR IGNORE INTO unit_types (code, label, display_order) VALUES
  ('apartment', 'Daire', 1),
  ('shop', 'Dukkan', 2),
  ('office', 'Ofis', 3),
  ('storage', 'Depo', 4),
  ('parking', 'Otopark', 5),
  ('other', 'Diger', 6);

INSERT OR IGNORE INTO due_types (code, label, display_order) VALUES
  ('aidat', 'Aidat', 1),
  ('su', 'Su', 2),
  ('elektrik', 'Elektrik', 3),
  ('dogalgaz', 'Dogalgaz', 4),
  ('demirbas', 'Demirbas', 5),
  ('yakit', 'Yakit', 6),
  ('isitma', 'Isitma', 7),
  ('diger', 'Diger', 8);

INSERT OR IGNORE INTO due_statuses (code, label, display_order) VALUES
  ('pending', 'Bekliyor', 1),
  ('overdue', 'Gecikmis', 2),
  ('partially_paid', 'Kismi Odendi', 3),
  ('paid', 'Odendi', 4),
  ('cancelled', 'Iptal', 5);

INSERT OR IGNORE INTO payment_methods (code, label, display_order) VALUES
  ('cash', 'Nakit', 1),
  ('bank_transfer', 'Havale/EFT', 2),
  ('credit_card', 'Kredi Karti', 3),
  ('digital_wallet', 'Dijital Cuzdan', 4),
  ('check', 'Cek', 5),
  ('other', 'Diger', 6);

INSERT OR IGNORE INTO payment_statuses (code, label, display_order) VALUES
  ('pending', 'Bekliyor', 1),
  ('processing', 'Isleniyor', 2),
  ('completed', 'Tamamlandi', 3),
  ('failed', 'Basarisiz', 4),
  ('refunded', 'Iade Edildi', 5),
  ('cancelled', 'Iptal', 6);

INSERT OR IGNORE INTO ticket_categories (code, label, display_order) VALUES
  ('ariza', 'Ariza', 1),
  ('temizlik', 'Temizlik', 2),
  ('guvenlik', 'Guvenlik', 3),
  ('oneri', 'Oneri', 4),
  ('sikayet', 'Sikayet', 5),
  ('diger', 'Diger', 6);

INSERT OR IGNORE INTO ticket_priorities (code, label, display_order) VALUES
  ('low', 'Dusuk', 1),
  ('medium', 'Orta', 2),
  ('high', 'Yuksek', 3),
  ('urgent', 'Acil', 4);

INSERT OR IGNORE INTO ticket_statuses (code, label, display_order) VALUES
  ('open', 'Acik', 1),
  ('in_progress', 'Islemde', 2),
  ('resolved', 'Cozuldu', 3),
  ('closed', 'Kapatildi', 4);

INSERT OR IGNORE INTO announcement_priorities (code, label, display_order) VALUES
  ('normal', 'Normal', 1),
  ('important', 'Onemli', 2),
  ('urgent', 'Acil', 3);

INSERT OR IGNORE INTO visitor_statuses (code, label, display_order) VALUES
  ('expected', 'Bekleniyor', 1),
  ('inside', 'Iceride', 2),
  ('left', 'Ayrildi', 3),
  ('cancelled', 'Iptal', 4);

INSERT OR IGNORE INTO technician_categories (code, label, display_order) VALUES
  ('plumbing', 'Sihhi Tesisat', 1),
  ('electric', 'Elektrik', 2),
  ('cleaning', 'Temizlik', 3),
  ('security', 'Guvenlik', 4),
  ('painting', 'Boya', 5),
  ('furniture', 'Mobilya', 6),
  ('other', 'Diger', 7);

INSERT OR IGNORE INTO service_request_statuses (code, label, display_order) VALUES
  ('pending', 'Bekliyor', 1),
  ('approved', 'Onaylandi', 2),
  ('in_progress', 'Islemde', 3),
  ('completed', 'Tamamlandi', 4),
  ('cancelled', 'Iptal', 5);

INSERT OR IGNORE INTO facility_types (code, label, display_order) VALUES
  ('facility', 'Tesis', 1),
  ('event', 'Etkinlik', 2);

INSERT OR IGNORE INTO reservation_statuses (code, label, display_order) VALUES
  ('active', 'Aktif', 1),
  ('completed', 'Tamamlandi', 2),
  ('cancelled', 'Iptal', 3),
  ('no_show', 'Gelmedi', 4);

INSERT OR IGNORE INTO account_types (code, label, display_order) VALUES
  ('income', 'Gelir', 1),
  ('expense', 'Gider', 2),
  ('asset', 'Varlik', 3),
  ('liability', 'Yukumluluk', 4),
  ('equity', 'Oz Sermaye', 5);

INSERT OR IGNORE INTO entry_types (code, label, display_order) VALUES
  ('income', 'Gelir', 1),
  ('expense', 'Gider', 2),
  ('transfer', 'Transfer', 3);

INSERT OR IGNORE INTO budget_periods (code, label, display_order) VALUES
  ('monthly', 'Aylik', 1),
  ('quarterly', 'Ceyreklik', 2),
  ('yearly', 'Yillik', 3);

INSERT OR IGNORE INTO budget_statuses (code, label, display_order) VALUES
  ('draft', 'Taslak', 1),
  ('active', 'Aktif', 2),
  ('completed', 'Tamamlandi', 3),
  ('cancelled', 'Iptal', 4);

INSERT OR IGNORE INTO report_types (code, label, display_order) VALUES
  ('balance_sheet', 'Mizan', 1),
  ('income_statement', 'Gelir-Gider Tablosu', 2),
  ('debt_status', 'Borc Durum Raporu', 3),
  ('collection_report', 'Tahsilat Raporu', 4),
  ('expense_analysis', 'Gider Analizi', 5),
  ('cash_flow', 'Kasa Raporu', 6),
  ('audit_report', 'Denetim Raporu', 7);

INSERT OR IGNORE INTO report_periods (code, label, display_order) VALUES
  ('daily', 'Gunluk', 1),
  ('weekly', 'Haftalik', 2),
  ('monthly', 'Aylik', 3),
  ('quarterly', 'Ceyreklik', 4),
  ('yearly', 'Yillik', 5),
  ('custom', 'Ozel', 6);

INSERT OR IGNORE INTO ledger_source_types (code, label, display_order) VALUES
  ('due_charge', 'Borclandirma', 1),
  ('payment', 'Odeme', 2),
  ('adjustment', 'Duzeltme', 3),
  ('manual_entry', 'Manuel Kayit', 4);

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
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT
);

CREATE TABLE IF NOT EXISTS blocks (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  name TEXT NOT NULL,
  floor_count INTEGER NOT NULL DEFAULT 0 CHECK (floor_count >= 0),
  unit_count INTEGER NOT NULL DEFAULT 0 CHECK (unit_count >= 0),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  UNIQUE (site_id, name),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS units (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  block_id TEXT NOT NULL,
  unit_no TEXT NOT NULL,
  floor INTEGER,
  area_sqm REAL,
  unit_type_code TEXT NOT NULL DEFAULT 'apartment',
  arsa_payi REAL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  UNIQUE (site_id, block_id, unit_no),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (block_id) REFERENCES blocks(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (unit_type_code) REFERENCES unit_types(code) ON UPDATE CASCADE ON DELETE RESTRICT
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
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT
);

CREATE TABLE IF NOT EXISTS site_memberships (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  role_code TEXT NOT NULL,
  is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1)),
  started_at TEXT,
  ended_at TEXT,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  UNIQUE (site_id, user_id, role_code),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (role_code) REFERENCES user_roles(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS unit_residents (
  id TEXT PRIMARY KEY,
  unit_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  relation_type_code TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  owner_share_pct REAL CHECK (owner_share_pct BETWEEN 0 AND 100),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  UNIQUE (unit_id, user_id, relation_type_code, start_date),
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (relation_type_code) REFERENCES unit_relation_types(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS vehicles (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  unit_id TEXT NOT NULL,
  user_id TEXT,
  plate_number TEXT NOT NULL,
  vehicle_type TEXT,
  brand TEXT,
  model TEXT,
  color TEXT,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  UNIQUE (site_id, plate_number),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS member_notes (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  unit_id TEXT NOT NULL,
  resident_user_id TEXT,
  author_user_id TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (resident_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (author_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS unit_ledger_entries (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  unit_id TEXT NOT NULL,
  resident_user_id TEXT,
  source_type_code TEXT NOT NULL DEFAULT 'manual_entry',
  source_id TEXT,
  transaction_date TEXT NOT NULL,
  due_date TEXT,
  description TEXT NOT NULL,
  debit_kurus INTEGER NOT NULL DEFAULT 0 CHECK (debit_kurus >= 0),
  credit_kurus INTEGER NOT NULL DEFAULT 0 CHECK (credit_kurus >= 0),
  running_balance_kurus INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (debit_kurus = 0 OR credit_kurus = 0),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (resident_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (source_type_code) REFERENCES ledger_source_types(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =====================================================
-- FINANCE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS dues (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  unit_id TEXT NOT NULL,
  due_type_code TEXT NOT NULL,
  amount_kurus INTEGER NOT NULL CHECK (amount_kurus >= 0),
  paid_amount_kurus INTEGER NOT NULL DEFAULT 0 CHECK (paid_amount_kurus >= 0),
  delay_fee_kurus INTEGER NOT NULL DEFAULT 0 CHECK (delay_fee_kurus >= 0),
  due_date TEXT NOT NULL,
  paid_date TEXT,
  description TEXT NOT NULL,
  period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
  period_year INTEGER NOT NULL CHECK (period_year >= 2000),
  status_code TEXT NOT NULL DEFAULT 'pending',
  created_by_user_id TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  CHECK (paid_amount_kurus <= amount_kurus + delay_fee_kurus),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (due_type_code) REFERENCES due_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (status_code) REFERENCES due_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS payments (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  payer_user_id TEXT NOT NULL,
  total_amount_kurus INTEGER NOT NULL CHECK (total_amount_kurus >= 0),
  payment_method_code TEXT NOT NULL,
  status_code TEXT NOT NULL,
  payment_date TEXT NOT NULL,
  transaction_id TEXT UNIQUE,
  commission_amount_kurus INTEGER NOT NULL DEFAULT 0 CHECK (commission_amount_kurus >= 0),
  description TEXT,
  gateway_response_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (payer_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (payment_method_code) REFERENCES payment_methods(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (status_code) REFERENCES payment_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS payment_allocations (
  id TEXT PRIMARY KEY,
  payment_id TEXT NOT NULL,
  due_id TEXT NOT NULL,
  allocated_amount_kurus INTEGER NOT NULL CHECK (allocated_amount_kurus >= 0),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (payment_id, due_id),
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (due_id) REFERENCES dues(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =====================================================
-- TICKET / ANNOUNCEMENT / VISITOR TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS tickets (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  unit_id TEXT,
  category_code TEXT NOT NULL,
  priority_code TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status_code TEXT NOT NULL DEFAULT 'open',
  assigned_to_user_id TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at TEXT,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (category_code) REFERENCES ticket_categories(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (priority_code) REFERENCES ticket_priorities(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (status_code) REFERENCES ticket_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (assigned_to_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS ticket_comments (
  id TEXT PRIMARY KEY,
  ticket_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  content TEXT NOT NULL,
  is_staff INTEGER NOT NULL DEFAULT 0 CHECK (is_staff IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS announcements (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  priority_code TEXT NOT NULL DEFAULT 'normal',
  publish_date TEXT NOT NULL,
  expire_date TEXT,
  created_by_user_id TEXT,
  send_push INTEGER NOT NULL DEFAULT 0 CHECK (send_push IN (0, 1)),
  send_sms INTEGER NOT NULL DEFAULT 0 CHECK (send_sms IN (0, 1)),
  send_email INTEGER NOT NULL DEFAULT 0 CHECK (send_email IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (priority_code) REFERENCES announcement_priorities(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS announcement_reads (
  id TEXT PRIMARY KEY,
  announcement_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  read_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (announcement_id, user_id),
  FOREIGN KEY (announcement_id) REFERENCES announcements(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS visitors (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  unit_id TEXT,
  resident_user_id TEXT,
  guest_name TEXT NOT NULL,
  guest_phone TEXT,
  plate_number TEXT,
  expected_date TEXT NOT NULL,
  status_code TEXT NOT NULL DEFAULT 'expected',
  note TEXT,
  entry_time TEXT,
  exit_time TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (resident_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (status_code) REFERENCES visitor_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =====================================================
-- SERVICE / POLL / RESERVATION TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS technicians (
  id TEXT PRIMARY KEY,
  site_id TEXT,
  name TEXT NOT NULL,
  category_code TEXT NOT NULL,
  photo_url TEXT,
  phone_number TEXT,
  biography TEXT,
  rating_avg REAL NOT NULL DEFAULT 0 CHECK (rating_avg BETWEEN 0 AND 5),
  review_count INTEGER NOT NULL DEFAULT 0 CHECK (review_count >= 0),
  is_available INTEGER NOT NULL DEFAULT 1 CHECK (is_available IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (category_code) REFERENCES technician_categories(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS technician_skills (
  id TEXT PRIMARY KEY,
  technician_id TEXT NOT NULL,
  skill_name TEXT NOT NULL,
  UNIQUE (technician_id, skill_name),
  FOREIGN KEY (technician_id) REFERENCES technicians(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS service_requests (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  unit_id TEXT,
  resident_user_id TEXT NOT NULL,
  technician_id TEXT NOT NULL,
  category_code TEXT NOT NULL,
  description TEXT NOT NULL,
  status_code TEXT NOT NULL DEFAULT 'pending',
  request_date TEXT NOT NULL,
  appointment_date TEXT NOT NULL,
  rating REAL CHECK (rating BETWEEN 0 AND 5),
  review_comment TEXT,
  completed_at TEXT,
  cancelled_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (resident_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (technician_id) REFERENCES technicians(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (category_code) REFERENCES technician_categories(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (status_code) REFERENCES service_request_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS service_request_photos (
  id TEXT PRIMARY KEY,
  service_request_id TEXT NOT NULL,
  photo_url TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (service_request_id, sort_order),
  FOREIGN KEY (service_request_id) REFERENCES service_requests(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS technician_reviews (
  id TEXT PRIMARY KEY,
  technician_id TEXT NOT NULL,
  service_request_id TEXT,
  user_id TEXT NOT NULL,
  rating REAL NOT NULL CHECK (rating BETWEEN 0 AND 5),
  comment TEXT,
  review_date TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (service_request_id),
  FOREIGN KEY (technician_id) REFERENCES technicians(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (service_request_id) REFERENCES service_requests(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS polls (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  end_date TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_by_user_id TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS poll_options (
  id TEXT PRIMARY KEY,
  poll_id TEXT NOT NULL,
  option_text TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  vote_count INTEGER NOT NULL DEFAULT 0 CHECK (vote_count >= 0),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (poll_id, sort_order),
  FOREIGN KEY (poll_id) REFERENCES polls(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS poll_votes (
  id TEXT PRIMARY KEY,
  poll_id TEXT NOT NULL,
  option_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  voted_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (poll_id, user_id),
  FOREIGN KEY (poll_id) REFERENCES polls(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (option_id) REFERENCES poll_options(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS facilities (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  name TEXT NOT NULL,
  facility_type_code TEXT NOT NULL,
  capacity INTEGER NOT NULL DEFAULT 1 CHECK (capacity > 0),
  photo_url TEXT,
  description TEXT,
  open_time TEXT NOT NULL,
  close_time TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (facility_type_code) REFERENCES facility_types(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS facility_schedules (
  id TEXT PRIMARY KEY,
  facility_id TEXT NOT NULL,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
  open_time TEXT NOT NULL,
  close_time TEXT NOT NULL,
  is_closed INTEGER NOT NULL DEFAULT 0 CHECK (is_closed IN (0, 1)),
  UNIQUE (facility_id, day_of_week),
  FOREIGN KEY (facility_id) REFERENCES facilities(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reservations (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  facility_id TEXT NOT NULL,
  resident_user_id TEXT NOT NULL,
  unit_id TEXT,
  start_time TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
  end_time TEXT NOT NULL,
  status_code TEXT NOT NULL DEFAULT 'active',
  note TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  UNIQUE (facility_id, start_time, resident_user_id),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (facility_id) REFERENCES facilities(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (resident_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (status_code) REFERENCES reservation_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =====================================================
-- ACCOUNTING TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS accounts (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  account_type_code TEXT NOT NULL,
  parent_account_id TEXT,
  balance_kurus INTEGER NOT NULL DEFAULT 0,
  description TEXT,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  UNIQUE (site_id, code),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (account_type_code) REFERENCES account_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (parent_account_id) REFERENCES accounts(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS accounting_entries (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  account_id TEXT NOT NULL,
  account_code_snapshot TEXT,
  account_name_snapshot TEXT,
  entry_type_code TEXT NOT NULL,
  amount_kurus INTEGER NOT NULL CHECK (amount_kurus >= 0),
  transaction_date TEXT NOT NULL,
  description TEXT NOT NULL,
  document_number TEXT,
  reference TEXT,
  payment_method_code TEXT,
  unit_id TEXT,
  created_by_user_id TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (entry_type_code) REFERENCES entry_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (payment_method_code) REFERENCES payment_methods(code) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (unit_id) REFERENCES units(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS budgets (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  name TEXT NOT NULL,
  period_code TEXT NOT NULL,
  year INTEGER NOT NULL CHECK (year >= 2000),
  month INTEGER CHECK (month BETWEEN 1 AND 12),
  quarter INTEGER CHECK (quarter BETWEEN 1 AND 4),
  status_code TEXT NOT NULL DEFAULT 'draft',
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  notes TEXT,
  created_by_user_id TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT,
  UNIQUE (site_id, name, year, period_code, month, quarter),
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (period_code) REFERENCES budget_periods(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (status_code) REFERENCES budget_statuses(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS budget_items (
  id TEXT PRIMARY KEY,
  budget_id TEXT NOT NULL,
  account_id TEXT NOT NULL,
  account_code_snapshot TEXT,
  account_name_snapshot TEXT,
  planned_amount_kurus INTEGER NOT NULL CHECK (planned_amount_kurus >= 0),
  actual_amount_kurus INTEGER NOT NULL DEFAULT 0 CHECK (actual_amount_kurus >= 0),
  notes TEXT,
  UNIQUE (budget_id, account_id),
  FOREIGN KEY (budget_id) REFERENCES budgets(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (account_id) REFERENCES accounts(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS financial_reports (
  id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  report_type_code TEXT NOT NULL,
  report_period_code TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  generated_at TEXT NOT NULL,
  generated_by_user_id TEXT,
  total_income_kurus INTEGER NOT NULL DEFAULT 0,
  total_expense_kurus INTEGER NOT NULL DEFAULT 0,
  net_income_kurus INTEGER NOT NULL DEFAULT 0,
  total_debt_kurus INTEGER NOT NULL DEFAULT 0,
  total_collection_kurus INTEGER NOT NULL DEFAULT 0,
  transaction_count INTEGER NOT NULL DEFAULT 0 CHECK (transaction_count >= 0),
  category_breakdown_json TEXT,
  report_data_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (site_id) REFERENCES sites(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (report_type_code) REFERENCES report_types(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (report_period_code) REFERENCES report_periods(code) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (generated_by_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
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

CREATE VIEW IF NOT EXISTS v_due_open_amounts AS
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

CREATE VIEW IF NOT EXISTS v_poll_results AS
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
