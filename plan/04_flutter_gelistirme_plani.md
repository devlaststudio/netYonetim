# 🔧 Flutter Geliştirme Planı

## 📦 Proje Kurulumu

### Flutter Sürümü
```yaml
Flutter: 3.19+ (Stable)
Dart: 3.3+
Minimum iOS: 12.0
Minimum Android: API 21 (Android 5.0)
```

### Proje Oluşturma
```bash
flutter create --org com.siteyonetpro --platforms=android,ios,web,windows,macos site_yonetimi_app
```

---

## 📚 Temel Paketler (pubspec.yaml)

### State Management
```yaml
flutter_riverpod: ^2.5.0       # State management
riverpod_annotation: ^2.3.0    # Code generation
```

### Navigasyon
```yaml
go_router: ^13.0.0             # Declarative routing
```

### Network
```yaml
dio: ^5.4.0                    # HTTP client
retrofit: ^4.0.0               # Type-safe API
pretty_dio_logger: ^1.3.0      # Debug logging
```

### Yerel Depolama
```yaml
hive: ^2.2.0                   # NoSQL local storage
hive_flutter: ^1.1.0           # Flutter bindings
shared_preferences: ^2.2.0     # Simple key-value
flutter_secure_storage: ^9.0.0 # Secure storage
```

### UI Bileşenleri
```yaml
flutter_svg: ^2.0.0            # SVG support
cached_network_image: ^3.3.0   # Image caching
shimmer: ^3.0.0                # Loading shimmer
lottie: ^3.0.0                 # Animations
fl_chart: ^0.66.0              # Charts
```

### Form ve Validasyon
```yaml
reactive_forms: ^17.0.0        # Form handling
intl: ^0.19.0                  # Internationalization
mask_text_input_formatter: ^2.0 # Input masking
```

### Ödeme
```yaml
iyzipay: (custom implementation)
pay: ^2.0.0                    # Apple/Google Pay
```

### Bildirimler
```yaml
firebase_messaging: ^14.0.0    # Push notifications
flutter_local_notifications: ^17.0.0
```

### Utilities
```yaml
freezed: ^2.4.0                # Immutable models
json_serializable: ^6.7.0      # JSON serialization
equatable: ^2.0.0              # Value equality
dartz: ^0.10.0                 # Functional programming
connectivity_plus: ^6.0.0      # Network status
```

---

## 📁 Proje Yapısı (Clean Architecture)

```
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp
│   ├── router.dart              # GoRouter config
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── typography.dart
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── dio_client.dart
│   │   └── network_info.dart
│   ├── usecases/
│   │   └── usecase.dart
│   └── utils/
│       ├── extensions.dart
│       └── validators.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── dashboard/
│   ├── dues/          # Borçlar
│   ├── payments/      # Ödemeler
│   ├── expenses/      # Giderler
│   ├── tickets/       # Talepler
│   ├── announcements/ # Duyurular
│   ├── reports/       # Raporlar
│   ├── residents/     # Sakinler
│   └── settings/      # Ayarlar
│
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   ├── inputs/
│   │   └── loading/
│   └── providers/
│
└── l10n/
    ├── app_tr.arb
    └── app_en.arb
```

---

## 🔐 Authentication Flow

```dart
// Auth Provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => AuthState.initial();
  
  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    final result = await ref.read(loginUseCaseProvider)(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }
  
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = AuthState.initial();
  }
}
```

---

## 💳 Ödeme Entegrasyonu

```dart
// iyzico Payment Service
class PaymentService {
  Future<PaymentResult> initiatePayment({
    required double amount,
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardHolderName,
  }) async {
    // 1. Backend'e ödeme isteği gönder
    // 2. 3D Secure için URL al
    // 3. WebView'da 3D Secure tamamla
    // 4. Callback'i işle
  }
  
  Future<PaymentResult> initiateRecurringPayment({
    required String cardToken,
    required double amount,
  }) async {
    // Kayıtlı kart ile otomatik ödeme
  }
}
```

---

## 📴 Offline Desteği

```dart
// Offline-first yaklaşım
class DuesRepository {
  Future<List<Due>> getDues() async {
    // 1. Önce local cache'e bak
    final cached = await _localDataSource.getCachedDues();
    if (cached.isNotEmpty && !_isStale(cached)) {
      return cached;
    }
    
    // 2. Network'ten çek
    try {
      final remote = await _remoteDataSource.getDues();
      await _localDataSource.cacheDues(remote);
      return remote;
    } catch (e) {
      // 3. Network hatası, cache dön
      return cached;
    }
  }
}

// Sync Queue
class SyncQueue {
  Future<void> addToQueue(SyncAction action) async {
    await _hiveBox.add(action);
  }
  
  Future<void> processQueue() async {
    final actions = _hiveBox.values.toList();
    for (final action in actions) {
      try {
        await _processAction(action);
        await action.delete();
      } catch (e) {
        // Retry later
      }
    }
  }
}
```

---

## 🧪 Test Stratejisi

### Unit Tests
```dart
// Domain layer tests
void main() {
  group('CalculateDelayFee UseCase', () {
    test('should calculate 5% monthly delay fee', () {
      final useCase = CalculateDelayFeeUseCase();
      final result = useCase(
        amount: 1000,
        dueDate: DateTime(2024, 1, 10),
        paymentDate: DateTime(2024, 2, 15),
      );
      expect(result, 50.0); // %5 gecikme
    });
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('DueCard shows correct amount', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DueCard(
          due: Due(amount: 850, type: 'Aidat'),
        ),
      ),
    );
    expect(find.text('₺850'), findsOneWidget);
    expect(find.text('Aidat'), findsOneWidget);
  });
}
```

### Integration Tests
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Payment flow test', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Login
    await tester.enterText(find.byKey(Key('email')), 'test@test.com');
    await tester.enterText(find.byKey(Key('password')), '123456');
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();
    
    // Navigate to dues
    await tester.tap(find.byIcon(Icons.payment));
    await tester.pumpAndSettle();
    
    // Select due and pay
    await tester.tap(find.text('Öde').first);
    await tester.pumpAndSettle();
    
    expect(find.text('Ödeme Başarılı'), findsOneWidget);
  });
}
```

---

## 🚀 Build ve Deploy

### Android
```bash
# Release build
flutter build appbundle --release

# APK
flutter build apk --release --split-per-abi
```

### iOS
```bash
flutter build ios --release
# Xcode'dan Archive ve App Store'a yükle
```

### Web
```bash
flutter build web --release --web-renderer canvaskit
```

### Windows/macOS
```bash
flutter build windows --release
flutter build macos --release
```

---

## 📋 CI/CD Pipeline (GitHub Actions)

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      
  build_android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build appbundle --release
      
  build_ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release --no-codesign
```
