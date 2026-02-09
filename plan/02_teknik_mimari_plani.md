# 🏗️ Teknik Mimari Planı

## 📱 Platform ve Teknoloji Yığını

### Frontend - Flutter
```
Framework: Flutter 3.x (Stable)
Dart SDK: 3.x
State Management: Riverpod 2.x / Bloc
Navigation: go_router
```

### Backend Seçenekleri

#### Seçenek 1: Firebase + Cloud Functions (Hızlı Başlangıç)
```
Authentication: Firebase Auth
Database: Cloud Firestore
Storage: Firebase Storage
Functions: Cloud Functions (Node.js/TypeScript)
Hosting: Firebase Hosting
```

#### Seçenek 2: Custom Backend (Ölçeklenebilir) ✅ ÖNERİLEN
```
Framework: NestJS (Node.js) veya FastAPI (Python)
Database: PostgreSQL + Redis
ORM: Prisma / TypeORM
API: REST + GraphQL
Queue: Bull / RabbitMQ
Search: Elasticsearch
Storage: AWS S3 / MinIO
```

### DevOps & Altyapı
```
Container: Docker
Orchestration: Kubernetes (K8s)
CI/CD: GitHub Actions / GitLab CI
Monitoring: Prometheus + Grafana
Logging: ELK Stack
CDN: Cloudflare
```

---

## 🗄️ Veritabanı Mimarisi

### Ana Tablolar

```sql
-- Siteler
CREATE TABLE sites (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    district VARCHAR(100),
    total_units INTEGER,
    subscription_plan VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

-- Bloklar
CREATE TABLE blocks (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    name VARCHAR(100),
    floor_count INTEGER,
    unit_count INTEGER
);

-- Daireler/Birimler
CREATE TABLE units (
    id UUID PRIMARY KEY,
    block_id UUID REFERENCES blocks(id),
    unit_no VARCHAR(20),
    floor INTEGER,
    area_sqm DECIMAL(10,2),
    unit_type VARCHAR(50), -- daire, dükkan, ofis
    arsa_payi DECIMAL(10,6)
);

-- Kullanıcılar
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    password_hash TEXT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    tc_kimlik VARCHAR(11),
    user_type VARCHAR(20), -- admin, manager, resident, tenant
    created_at TIMESTAMP DEFAULT NOW()
);

-- Daire-Kullanıcı İlişkisi
CREATE TABLE unit_residents (
    id UUID PRIMARY KEY,
    unit_id UUID REFERENCES units(id),
    user_id UUID REFERENCES users(id),
    relation_type VARCHAR(20), -- owner, tenant, representative
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true
);

-- Borçlandırmalar
CREATE TABLE dues (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    unit_id UUID REFERENCES units(id),
    due_type VARCHAR(50), -- aidat, yakıt, su, elektrik, demirbaş
    amount DECIMAL(12,2),
    due_date DATE,
    description TEXT,
    period_month INTEGER,
    period_year INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Ödemeler
CREATE TABLE payments (
    id UUID PRIMARY KEY,
    due_id UUID REFERENCES dues(id),
    user_id UUID REFERENCES users(id),
    amount DECIMAL(12,2),
    payment_method VARCHAR(50), -- credit_card, bank_transfer, cash
    payment_date TIMESTAMP,
    transaction_id VARCHAR(255),
    status VARCHAR(20), -- pending, completed, failed, refunded
    commission_amount DECIMAL(10,2)
);

-- Giderler
CREATE TABLE expenses (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    category VARCHAR(100),
    vendor_name VARCHAR(255),
    amount DECIMAL(12,2),
    expense_date DATE,
    invoice_no VARCHAR(100),
    invoice_file_url TEXT,
    description TEXT,
    payment_status VARCHAR(20),
    blockchain_hash VARCHAR(255) -- Şeffaflık için
);

-- Kararlar
CREATE TABLE decisions (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    decision_no INTEGER,
    decision_date DATE,
    title VARCHAR(500),
    content TEXT,
    participants TEXT[], -- Katılımcılar
    votes_for INTEGER,
    votes_against INTEGER,
    votes_abstain INTEGER,
    blockchain_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Talepler/Şikayetler
CREATE TABLE tickets (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    user_id UUID REFERENCES users(id),
    category VARCHAR(100),
    priority VARCHAR(20),
    title VARCHAR(255),
    description TEXT,
    status VARCHAR(20), -- open, in_progress, resolved, closed
    assigned_to UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP
);

-- Duyurular
CREATE TABLE announcements (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    title VARCHAR(255),
    content TEXT,
    priority VARCHAR(20),
    publish_date TIMESTAMP,
    expire_date TIMESTAMP,
    send_push BOOLEAN DEFAULT false,
    send_sms BOOLEAN DEFAULT false,
    send_email BOOLEAN DEFAULT false,
    created_by UUID REFERENCES users(id)
);

-- Sayaç Okumaları
CREATE TABLE meter_readings (
    id UUID PRIMARY KEY,
    unit_id UUID REFERENCES units(id),
    meter_type VARCHAR(50), -- water, electricity, gas, heating
    previous_reading DECIMAL(12,3),
    current_reading DECIMAL(12,3),
    reading_date DATE,
    consumption DECIMAL(12,3),
    unit_price DECIMAL(10,4),
    total_amount DECIMAL(12,2)
);

-- Araçlar
CREATE TABLE vehicles (
    id UUID PRIMARY KEY,
    unit_id UUID REFERENCES units(id),
    plate_number VARCHAR(20),
    vehicle_type VARCHAR(50),
    brand VARCHAR(100),
    model VARCHAR(100),
    color VARCHAR(50),
    is_active BOOLEAN DEFAULT true
);

-- Ziyaretçiler
CREATE TABLE visitors (
    id UUID PRIMARY KEY,
    site_id UUID REFERENCES sites(id),
    unit_id UUID REFERENCES units(id),
    visitor_name VARCHAR(255),
    visitor_phone VARCHAR(20),
    plate_number VARCHAR(20),
    visit_date DATE,
    entry_time TIMESTAMP,
    exit_time TIMESTAMP,
    purpose VARCHAR(255),
    approved_by UUID REFERENCES users(id)
);
```

---

## 🔐 Güvenlik Mimarisi

### Kimlik Doğrulama
```
- JWT (JSON Web Tokens) tabanlı authentication
- Refresh token mekanizması
- Multi-factor authentication (SMS/Email OTP)
- Biometric authentication (fingerprint, face ID)
- Session yönetimi ve timeout
```

### Yetkilendirme (RBAC)
```yaml
roles:
  super_admin:
    - Tüm sistem yönetimi
    
  site_admin:
    - Site ayarları
    - Kullanıcı yönetimi
    - Tüm finansal işlemler
    - Raporlama
    
  manager:
    - Borçlandırma
    - Gider girişi
    - Talep yönetimi
    - Duyuru
    
  auditor:
    - Salt okunur finansal erişim
    - Denetim raporları
    
  resident:
    - Kendi borç/ödeme görüntüleme
    - Talep açma
    - Oylama katılımı
    
  tenant:
    - Sınırlı erişim
    - Talep açma
```

### Veri Güvenliği
```
- HTTPS/TLS 1.3 zorunlu
- Veritabanı şifreleme (AES-256)
- PII verileri için özel şifreleme
- KVKK uyumlu veri saklama
- Düzenli güvenlik denetimi
- Penetrasyon testleri
```

---

## 📡 API Tasarımı

### RESTful API Endpoints

```yaml
# Authentication
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/verify-otp

# Sites
GET    /api/v1/sites
POST   /api/v1/sites
GET    /api/v1/sites/:id
PUT    /api/v1/sites/:id
DELETE /api/v1/sites/:id
GET    /api/v1/sites/:id/dashboard

# Units
GET    /api/v1/sites/:siteId/units
POST   /api/v1/sites/:siteId/units
GET    /api/v1/units/:id
PUT    /api/v1/units/:id
GET    /api/v1/units/:id/dues
GET    /api/v1/units/:id/payments

# Dues (Borçlandırma)
GET    /api/v1/sites/:siteId/dues
POST   /api/v1/sites/:siteId/dues
POST   /api/v1/sites/:siteId/dues/bulk
GET    /api/v1/dues/:id
PUT    /api/v1/dues/:id
DELETE /api/v1/dues/:id

# Payments
GET    /api/v1/payments
POST   /api/v1/payments
GET    /api/v1/payments/:id
POST   /api/v1/payments/initiate
POST   /api/v1/payments/callback

# Expenses
GET    /api/v1/sites/:siteId/expenses
POST   /api/v1/sites/:siteId/expenses
GET    /api/v1/expenses/:id
PUT    /api/v1/expenses/:id

# Tickets
GET    /api/v1/sites/:siteId/tickets
POST   /api/v1/sites/:siteId/tickets
GET    /api/v1/tickets/:id
PUT    /api/v1/tickets/:id
POST   /api/v1/tickets/:id/comments

# Announcements
GET    /api/v1/sites/:siteId/announcements
POST   /api/v1/sites/:siteId/announcements
GET    /api/v1/announcements/:id
PUT    /api/v1/announcements/:id
DELETE /api/v1/announcements/:id

# Reports
GET    /api/v1/sites/:siteId/reports/income-expense
GET    /api/v1/sites/:siteId/reports/balance
GET    /api/v1/sites/:siteId/reports/dues-status
GET    /api/v1/sites/:siteId/reports/collection-rate
```

---

## 🔗 Entegrasyonlar

### Ödeme Sistemleri
```
- iyzico / PayTR / Param (Sanal POS)
- Stripe (Uluslararası)
- Banka API'leri (MT940)
  - Garanti BBVA
  - İş Bankası
  - Yapı Kredi
  - Akbank
  - Ziraat Bankası
```

### Bildirim Servisleri
```
- Firebase Cloud Messaging (Push)
- Twilio / Netgsm (SMS)
- SendGrid / AWS SES (Email)
```

### E-Fatura/E-Arşiv
```
- GİB Entegrasyonu
- Kolaysoft / Paraşüt / Logo
```

### Harici Sistemler
```
- Plaka Tanıma Kameraları (ONVIF)
- Akıllı Sayaç Sistemleri (Modbus/M-Bus)
- Geçiş Kontrol Sistemleri
```

---

## 📱 Flutter Proje Yapısı

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── dio_client.dart
│   │   └── interceptors/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── blocs/ (or providers/)
│   ├── pages/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── dues/
│   │   ├── payments/
│   │   ├── tickets/
│   │   ├── announcements/
│   │   ├── reports/
│   │   └── settings/
│   └── widgets/
└── l10n/
    ├── app_tr.arb
    └── app_en.arb
```

---

## 🔄 Offline Desteği

```dart
// Hive veya Isar kullanarak offline veri saklama
- Sayaç okumaları offline kaydedilebilir
- Talep oluşturma offline yapılabilir
- Son görüntülenen veriler cache'lenir
- İnternet bağlantısı gelince senkronizasyon
- Conflict resolution stratejisi
```

---

## 📊 Monitoring ve Logging

```yaml
Application Monitoring:
  - Sentry (Error tracking)
  - Firebase Crashlytics
  - Custom analytics

Server Monitoring:
  - Prometheus metrics
  - Grafana dashboards
  - AlertManager

Logging:
  - ELK Stack (Elasticsearch, Logstash, Kibana)
  - Centralized logging
  - Log retention policy
```

---

## 🚀 Deployment Stratejisi

### Development
```
- Local Flutter development
- Firebase Emulator Suite
- Local PostgreSQL
```

### Staging
```
- Firebase/GCP staging environment
- Separate database
- Limited access
```

### Production
```
- Multi-region deployment
- Auto-scaling
- Blue-green deployment
- Database replication
- CDN for static assets
```
