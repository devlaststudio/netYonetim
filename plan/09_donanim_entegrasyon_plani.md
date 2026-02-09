# 🔌 Donanım Entegrasyonu Planı

## 🎯 Entegrasyon Alanları

1. Plaka Tanıma Sistemi (PTS)
2. Akıllı Sayaçlar
3. Geçiş Kontrol Sistemleri
4. Güvenlik Kameraları
5. Asansör Sistemleri

---

## 🚗 Plaka Tanıma Sistemi (PTS)

### Desteklenen Kamera Markaları

| Marka | Protokol | SDK |
|-------|----------|-----|
| Hikvision | ISAPI, ONVIF | HCNetSDK |
| Dahua | HTTP API, ONVIF | - |
| Axis | VAPIX, ONVIF | - |
| Uniview | HTTP API | - |

### Entegrasyon Akışı

```
Araç Kapıya Yaklaşır
       ↓
Kamera Plakayı Okur
       ↓
API'ye Plaka Gönderilir
       ↓
Veritabanında Kontrol
       ↓
┌─────────────┬─────────────┐
│ Sakin Aracı │  Ziyaretçi  │
│   ✅ Aç     │  ❓ Bekle   │
└─────────────┴─────────────┘
```

### API Tasarımı

```dart
class LicensePlateService {
  // Kameradan webhook
  Future<GateAction> processPlateRecognition(PlateEvent event) async {
    // 1. Plakayı normalize et
    final normalizedPlate = _normalizePlate(event.plateNumber);
    
    // 2. Veritabanında ara
    final vehicle = await _vehicleRepository.findByPlate(normalizedPlate);
    
    if (vehicle != null && vehicle.isActive) {
      // 3. Sakin aracı - kapıyı aç
      await _gateController.open(event.gateId);
      
      // 4. Giriş/çıkış kaydı
      await _accessLogRepository.log(AccessLog(
        vehicleId: vehicle.id,
        plateNumber: normalizedPlate,
        direction: event.direction,
        timestamp: DateTime.now(),
        gateId: event.gateId,
      ));
      
      return GateAction.open;
    } else {
      // 4. Ziyaretçi - güvenliğe bildir
      await _securityService.notifyVisitor(event);
      return GateAction.waitForApproval;
    }
  }
  
  // Kapı kontrol
  Future<void> openGate(String gateId) async {
    await _gateController.sendCommand(gateId, GateCommand.open);
  }
}
```

### Kamera SDK Entegrasyonu (Hikvision Örneği)

```dart
class HikvisionIntegration {
  late final HCNetSDK _sdk;
  
  Future<void> connect(String ip, String user, String pass) async {
    _sdk = HCNetSDK();
    await _sdk.init();
    
    final loginInfo = NET_DVR_USER_LOGIN_INFO(
      sDeviceAddress: ip,
      sUserName: user,
      sPassword: pass,
    );
    
    _userId = await _sdk.login_V40(loginInfo);
  }
  
  void setupPlateCallback(Function(PlateEvent) onPlate) {
    _sdk.setCallback((alarm) {
      if (alarm.type == AlarmType.ANPR) {
        final event = PlateEvent(
          plateNumber: alarm.plateNumber,
          confidence: alarm.confidence,
          imageUrl: alarm.pictureUrl,
          timestamp: DateTime.now(),
        );
        onPlate(event);
      }
    });
  }
}
```

---

## 📊 Akıllı Sayaç Entegrasyonu

### Desteklenen Protokoller

| Protokol | Kullanım | Özellik |
|----------|----------|---------|
| M-Bus (Meter Bus) | Su, Isı sayaçları | Kablolu |
| Wireless M-Bus | Uzaktan okuma | Kablosuz |
| Modbus RTU/TCP | Elektrik sayaçları | Endüstriyel |
| DLMS/COSEM | Akıllı sayaçlar | Uluslararası standart |
| LoRaWAN | IoT sayaçlar | Uzun menzil |

### Sayaç Okuma Servisi

```dart
class MeterReadingService {
  final Map<MeterProtocol, MeterReader> _readers = {
    MeterProtocol.modbusTcp: ModbusTcpReader(),
    MeterProtocol.mbus: MBusReader(),
    MeterProtocol.lorawan: LoRaWANReader(),
  };
  
  Future<MeterReading> readMeter(Meter meter) async {
    final reader = _readers[meter.protocol];
    if (reader == null) throw UnsupportedProtocolException();
    
    final rawValue = await reader.read(
      address: meter.address,
      register: meter.register,
    );
    
    return MeterReading(
      meterId: meter.id,
      unitId: meter.unitId,
      previousReading: meter.lastReading,
      currentReading: rawValue,
      consumption: rawValue - meter.lastReading,
      readingDate: DateTime.now(),
      isAutomatic: true,
    );
  }
  
  // Toplu okuma (zamanlı)
  Future<void> readAllMeters() async {
    final meters = await _meterRepository.getAll();
    
    for (final meter in meters) {
      try {
        final reading = await readMeter(meter);
        await _meterReadingRepository.save(reading);
        
        // Otomatik borçlandırma
        if (meter.autoBilling) {
          await _billingService.createFromReading(reading);
        }
      } catch (e) {
        await _errorLogRepository.log(
          MeterReadError(meterId: meter.id, error: e.toString()),
        );
      }
    }
  }
}
```

### Modbus TCP Reader

```dart
class ModbusTcpReader implements MeterReader {
  Future<double> read({
    required String address,
    required int register,
  }) async {
    final parts = address.split(':');
    final host = parts[0];
    final port = int.parse(parts[1]);
    
    final client = ModbusClient(host, port);
    await client.connect();
    
    try {
      // Holding register okuma
      final response = await client.readHoldingRegisters(
        register,
        2, // 32-bit için 2 register
      );
      
      // Raw değeri float'a çevir
      return _bytesToFloat(response);
    } finally {
      await client.disconnect();
    }
  }
}
```

---

## 🚪 Geçiş Kontrol Sistemi

### Desteklenen Teknolojiler

| Teknoloji | Protokol | Kullanım |
|-----------|----------|----------|
| NFC/RFID | Wiegand, OSDP | Kartlı geçiş |
| QR Kod | HTTP | Ziyaretçi geçiş |
| Yüz Tanıma | RTSP + AI | Biyometrik |
| Bluetooth | BLE | Mobil uygulama |

### Ziyaretçi Geçiş Akışı

```dart
class VisitorAccessService {
  // 1. Sakin ziyaretçi davet eder
  Future<VisitorPass> createVisitorPass({
    required String unitId,
    required String visitorName,
    required String visitorPhone,
    required DateTime visitDate,
    String? plateNumber,
  }) async {
    final pass = VisitorPass(
      id: Uuid().v4(),
      unitId: unitId,
      visitorName: visitorName,
      visitorPhone: visitorPhone,
      visitDate: visitDate,
      plateNumber: plateNumber,
      qrCode: _generateQRCode(),
      status: VisitorStatus.pending,
    );
    
    await _visitorRepository.save(pass);
    
    // 2. Ziyaretçiye SMS ile QR gönder
    await _smsService.send(
      to: visitorPhone,
      message: 'Ziyaret kodunuz: ${pass.qrCode}\n'
               'QR görüntülemek için: ${pass.qrUrl}',
    );
    
    // 3. Güvenliğe bildir
    await _securityNotificationService.notifyUpcomingVisitor(pass);
    
    return pass;
  }
  
  // Kapıda QR doğrulama
  Future<AccessResult> validateVisitorQR(String qrCode) async {
    final pass = await _visitorRepository.findByQR(qrCode);
    
    if (pass == null) return AccessResult.denied('Geçersiz kod');
    
    if (pass.visitDate.isAfter(DateTime.now().add(Duration(hours: 1)))) {
      return AccessResult.denied('Henüz ziyaret saati gelmedi');
    }
    
    if (pass.isUsed) return AccessResult.denied('Kod zaten kullanıldı');
    
    // Geçişi kaydet
    pass.entryTime = DateTime.now();
    pass.status = VisitorStatus.entered;
    await _visitorRepository.update(pass);
    
    return AccessResult.granted;
  }
}
```

---

## 📹 Güvenlik Kamera Entegrasyonu

### RTSP Akış Erişimi

```dart
class CameraStreamService {
  // Canlı izleme için RTSP URL oluştur
  String getStreamUrl(Camera camera, {StreamQuality quality = StreamQuality.main}) {
    return 'rtsp://${camera.username}:${camera.password}@'
           '${camera.ip}:${camera.rtspPort}/'
           '${quality == StreamQuality.main ? 'stream1' : 'stream2'}';
  }
  
  // HLS streaming (web için)
  Future<String> startHLSStream(Camera camera) async {
    final hlsUrl = await _streamingServer.createHLSSession(
      rtspUrl: getStreamUrl(camera),
      sessionId: Uuid().v4(),
    );
    return hlsUrl;
  }
}
```

### Olay Bildirimi

```dart
class CameraEventService {
  void setupEventListener(Camera camera) {
    final eventUrl = 'http://${camera.ip}/ISAPI/Event/notification/alertStream';
    
    _httpClient.getStream(eventUrl).listen((event) {
      final parsed = _parseAlarmEvent(event);
      
      switch (parsed.type) {
        case EventType.motionDetection:
          _handleMotion(camera, parsed);
          break;
        case EventType.lineDetection:
          _handleLineCross(camera, parsed);
          break;
        case EventType.faceDetection:
          _handleFace(camera, parsed);
          break;
      }
    });
  }
}
```

---

## 🛗 Asansör Sistemi Entegrasyonu

### Durum İzleme

```dart
class ElevatorMonitoringService {
  // Asansör kontrolcüsünden veri okuma
  Future<ElevatorStatus> getStatus(Elevator elevator) async {
    final client = ModbusClient(elevator.controllerIp, 502);
    await client.connect();
    
    try {
      final registers = await client.readHoldingRegisters(0, 10);
      
      return ElevatorStatus(
        currentFloor: registers[0],
        direction: ElevatorDirection.values[registers[1]],
        doorStatus: DoorStatus.values[registers[2]],
        isMoving: registers[3] == 1,
        errorCode: registers[4],
        totalTrips: (registers[5] << 16) | registers[6],
      );
    } finally {
      await client.disconnect();
    }
  }
  
  // Arıza bildirimi
  void monitorErrors(Elevator elevator) {
    Timer.periodic(Duration(seconds: 30), (_) async {
      final status = await getStatus(elevator);
      
      if (status.hasError) {
        await _ticketService.createAutomatic(
          category: 'Asansör Arızası',
          title: 'Asansör ${elevator.name} - Hata: ${status.errorCode}',
          priority: Priority.high,
        );
        
        await _notificationService.notifyManagers(
          title: '⚠️ Asansör Arızası',
          body: '${elevator.name} arıza kodu: ${status.errorCode}',
        );
      }
    });
  }
}
```

---

## 🔧 Entegrasyon Altyapısı

### Message Queue (MQTT)

```dart
class IoTMessageBroker {
  late final MqttClient _client;
  
  Future<void> connect() async {
    _client = MqttServerClient('mqtt.siteyonet.local', 'backend');
    await _client.connect();
  }
  
  void subscribeToDevices() {
    // Topic yapısı: site/{siteId}/device/{deviceType}/{deviceId}
    _client.subscribe('site/+/device/+/+', MqttQos.atLeastOnce);
    
    _client.updates?.listen((messages) {
      for (final msg in messages) {
        final topic = msg.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
          msg.payload.message,
        );
        _handleMessage(topic, payload);
      }
    });
  }
  
  void _handleMessage(String topic, String payload) {
    // site/123/device/meter/456
    final parts = topic.split('/');
    final siteId = parts[1];
    final deviceType = parts[3];
    final deviceId = parts[4];
    
    switch (deviceType) {
      case 'meter':
        _meterService.handleReading(deviceId, payload);
        break;
      case 'camera':
        _cameraService.handleEvent(deviceId, payload);
        break;
      case 'elevator':
        _elevatorService.handleStatus(deviceId, payload);
        break;
    }
  }
}
```

---

## 📋 Donanım Uyumluluk Matrisi

| Özellik | Minimum | Önerilen |
|---------|---------|----------|
| PTS Kamera | 2MP, ANPR destekli | 5MP, AI destekli |
| Sayaç Gateway | M-Bus Master | LoRaWAN Gateway |
| Geçiş Kontrol | Wiegand 26 | OSDP v2 |
| Network | 100 Mbps | 1 Gbps, VLAN |
| PoE Switch | PoE | PoE+ (802.3at) |
