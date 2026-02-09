# 🤖 Yapay Zeka ve Otomasyon Planı

## 🎯 AI Kullanım Alanları

### 1. Akıllı Bütçe Asistanı
### 2. Arıza Tahminleme
### 3. Enerji Optimizasyonu
### 4. Chatbot Asistan
### 5. Anomali Tespiti

---

## 📊 Akıllı Bütçe Tahminleme

### Tahmin Modeli

```python
# Time Series Forecasting
from prophet import Prophet
import pandas as pd

class BudgetPredictor:
    def __init__(self):
        self.model = Prophet(
            yearly_seasonality=True,
            monthly_seasonality=True,
            changepoint_prior_scale=0.05
        )
    
    def train(self, historical_data: pd.DataFrame):
        # historical_data: ds (date), y (amount)
        self.model.fit(historical_data)
    
    def predict_next_year(self) -> pd.DataFrame:
        future = self.model.make_future_dataframe(periods=12, freq='M')
        forecast = self.model.predict(future)
        return forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']]
    
    def suggest_monthly_fee(self, total_units: int) -> float:
        yearly_prediction = self.predict_next_year()['yhat'].sum()
        reserve_fund = yearly_prediction * 0.1  # %10 yedek
        return (yearly_prediction + reserve_fund) / (total_units * 12)
```

### Enflasyon Düzeltmesi

```dart
class InflationAdjuster {
  Future<double> adjustForInflation(
    double baseAmount,
    int monthsAhead,
  ) async {
    final tüfeRate = await _fetchTUFERate();
    return baseAmount * pow(1 + tüfeRate/12, monthsAhead);
  }
}
```

---

## 🔧 Arıza Tahminleme (Predictive Maintenance)

### Asansör Bakım Tahmini

```python
from sklearn.ensemble import RandomForestClassifier
import numpy as np

class MaintenancePredictor:
    def __init__(self):
        self.model = RandomForestClassifier(n_estimators=100)
    
    def train(self, features: np.ndarray, labels: np.ndarray):
        # Features: [kullanım_sayısı, son_bakımdan_geçen_gün,
        #            önceki_arıza_sayısı, asansör_yaşı]
        # Labels: [0: normal, 1: bakım gerekli]
        self.model.fit(features, labels)
    
    def predict_maintenance_need(self, elevator_data: dict) -> dict:
        features = self._extract_features(elevator_data)
        probability = self.model.predict_proba([features])[0][1]
        
        return {
            'maintenance_needed': probability > 0.7,
            'probability': probability,
            'recommended_date': self._suggest_date(probability),
            'estimated_cost': self._estimate_cost(elevator_data)
        }
```

### Alert Sistemi

```dart
class MaintenanceAlertService {
  Future<void> checkAndAlert() async {
    final elevators = await _repository.getElevators();
    
    for (final elevator in elevators) {
      final prediction = await _aiService.predictMaintenance(elevator);
      
      if (prediction.maintenanceNeeded) {
        await _notificationService.sendToManagers(
          title: '⚠️ Asansör Bakım Uyarısı',
          body: '${elevator.name} için bakım önerilmektedir. '
                'Tahmini maliyet: ₺${prediction.estimatedCost}',
        );
      }
    }
  }
}
```

---

## ⚡ Enerji Optimizasyonu

### Tüketim Analizi

```python
class EnergyAnalyzer:
    def analyze_consumption(self, meter_readings: list) -> dict:
        df = pd.DataFrame(meter_readings)
        
        # Anormal tüketim tespiti
        mean = df['consumption'].mean()
        std = df['consumption'].std()
        anomalies = df[df['consumption'] > mean + 2*std]
        
        # Trend analizi
        trend = np.polyfit(range(len(df)), df['consumption'], 1)[0]
        
        # Tasarruf önerileri
        recommendations = self._generate_recommendations(df, anomalies)
        
        return {
            'average_consumption': mean,
            'trend': 'increasing' if trend > 0 else 'decreasing',
            'anomalies': anomalies.to_dict('records'),
            'recommendations': recommendations,
            'potential_savings': self._calculate_savings(df)
        }
    
    def _generate_recommendations(self, df, anomalies) -> list:
        recs = []
        
        # Gece tüketimi yüksekse
        night_avg = df[df['hour'].between(0, 6)]['consumption'].mean()
        day_avg = df[df['hour'].between(6, 22)]['consumption'].mean()
        if night_avg > day_avg * 0.3:
            recs.append({
                'type': 'lighting',
                'message': 'Gece aydınlatması optimize edilebilir',
                'savings': '~%20 tasarruf'
            })
        
        return recs
```

---

## 💬 AI Chatbot Asistan

### Doğal Dil İşleme

```dart
class ChatbotService {
  final OpenAI _openai;
  
  Future<String> processQuery(String userQuery, Map<String, dynamic> context) async {
    final systemPrompt = '''
Sen bir site yönetimi asistanısın. Kullanıcıya yardımcı ol.
Site bilgileri:
- Toplam daire: ${context['totalUnits']}
- Kullanıcı rolü: ${context['userRole']}
- Açık borç: ${context['openDues']}

Yapabileceklerin:
- Borç bilgisi verme
- Aidat hesaplama
- Talep oluşturma
- Site bilgileri
''';

    final response = await _openai.chat.completions.create(
      model: 'gpt-4-turbo-preview',
      messages: [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userQuery},
      ],
      functions: _availableFunctions,
    );
    
    return response.choices.first.message.content;
  }
  
  final _availableFunctions = [
    {
      'name': 'get_dues',
      'description': 'Kullanıcının borç bilgilerini getirir',
      'parameters': {...}
    },
    {
      'name': 'create_ticket',
      'description': 'Yeni talep oluşturur',
      'parameters': {...}
    },
  ];
}
```

### Örnek Diyaloglar

```
Kullanıcı: Borcum ne kadar?
Asistan: Şu anda toplam ₺2.450 borcunuz bulunmaktadır:
         - Şubat 2026 Aidatı: ₺850
         - Ocak 2026 Aidatı: ₺850 + ₺42.50 gecikme
         - Su tüketimi: ₺156
         Ödeme yapmak ister misiniz?

Kullanıcı: Asansör bozuldu
Asistan: Asansör arızası talebi oluşturuyorum. 
         📍 Blok/Daire: A Blok - 5
         🔧 Kategori: Asansör Arızası
         📝 Açıklama: [Lütfen detay ekleyin]
         Onaylıyor musunuz?
```

---

## 🚨 Anomali Tespiti

### Finansal Anomali

```python
from sklearn.ensemble import IsolationForest

class AnomalyDetector:
    def __init__(self):
        self.model = IsolationForest(contamination=0.1)
    
    def detect_expense_anomalies(self, expenses: list) -> list:
        df = pd.DataFrame(expenses)
        features = df[['amount', 'category_encoded', 'day_of_month']]
        
        predictions = self.model.fit_predict(features)
        anomalies = df[predictions == -1]
        
        return anomalies.to_dict('records')
    
    def detect_payment_anomalies(self, payments: list) -> list:
        # Olağandışı ödeme paterni tespiti
        # Örn: Gece yarısı toplu ödemeler, tekrarlayan başarısız
        pass
```

---

## 🔄 ML Model Deployment

### Model Servisi

```yaml
# Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ai-service
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: ai-service
        image: siteyonet/ai-service:latest
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        env:
        - name: MODEL_PATH
          value: "/models"
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-secrets
              key: openai-key
```

### API Endpoints

```
POST /api/ai/predict-budget
POST /api/ai/predict-maintenance
POST /api/ai/analyze-energy
POST /api/ai/chat
POST /api/ai/detect-anomalies
```

---

## 📈 Performans Metrikleri

| Model | Metrik | Hedef |
|-------|--------|-------|
| Bütçe Tahmini | MAPE | < 15% |
| Arıza Tahmini | F1 Score | > 0.85 |
| Anomali Tespiti | Precision | > 0.90 |
| Chatbot | User Satisfaction | > 4.0/5 |

---

## 🛡️ AI Güvenlik ve Etik

1. **Veri Gizliliği:** Kişisel veriler anonimleştirilir
2. **Şeffaflık:** AI kararları açıklanabilir
3. **İnsan Kontrolü:** Kritik kararlar onay gerektirir
4. **Bias Kontrolü:** Düzenli model denetimi
