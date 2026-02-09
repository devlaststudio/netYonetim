# 🔗 Blockchain ve Şeffaflık Planı

## 🎯 Blockchain Kullanım Amacı

Site yönetimlerinde güven ve şeffaflık sorunlarını çözmek için blockchain teknolojisinin kullanılması planlanmaktadır:

1. **Değiştirilemez Karar Kayıtları:** Yönetim kurulu kararlarının geriye dönük değiştirilememesi
2. **Şeffaf Harcama Takibi:** Tüm giderlerin doğrulanabilir şekilde kaydedilmesi
3. **Denetim Kanıtı:** Denetçiler için değiştirilemez finansal izleme

---

## 🏗️ Teknik Mimari

### Blockchain Seçimi

| Seçenek | Avantaj | Dezavantaj | Öneri |
|---------|---------|------------|-------|
| **Polygon** | Düşük maliyet, hızlı, Ethereum uyumlu | Merkezileşme riski | ✅ Önerilen |
| Ethereum | Güvenilir, yaygın | Yüksek gas ücreti | Büyük siteler için |
| Avalanche | Hızlı finality | Daha az yaygın | Alternatif |
| Private Blockchain | Tam kontrol | Karmaşık setup | Kurumsal siteler |

### Hibrit Yaklaşım

```
Uygulama Katmanı
       ↓
PostgreSQL (Detaylı veri)
       ↓
Blockchain Katmanı (Hash'ler)
       ↓
Polygon/Ethereum (Değiştirilemezlik)
```

**Mantık:** Tüm veriyi blockchain'e yazmak maliyetli. Sadece kritik verilerin hash'leri zincire yazılır.

---

## 📋 Blockchain Kullanım Senaryoları

### 1. Dijital Karar Defteri

```solidity
// Solidity Smart Contract
contract DecisionRegistry {
    struct Decision {
        uint256 id;
        bytes32 contentHash;  // Karar içeriğinin hash'i
        uint256 timestamp;
        address recorder;
        string ipfsUri;       // Detaylı içerik IPFS'te
    }
    
    mapping(uint256 => Decision) public decisions;
    
    event DecisionRecorded(
        uint256 indexed id,
        bytes32 contentHash,
        uint256 timestamp
    );
    
    function recordDecision(
        uint256 _id,
        bytes32 _contentHash,
        string memory _ipfsUri
    ) external onlyAuthorized {
        decisions[_id] = Decision({
            id: _id,
            contentHash: _contentHash,
            timestamp: block.timestamp,
            recorder: msg.sender,
            ipfsUri: _ipfsUri
        });
        
        emit DecisionRecorded(_id, _contentHash, block.timestamp);
    }
    
    function verifyDecision(
        uint256 _id,
        bytes32 _contentHash
    ) external view returns (bool) {
        return decisions[_id].contentHash == _contentHash;
    }
}
```

### 2. Harcama Doğrulama

```solidity
contract ExpenseRegistry {
    struct Expense {
        bytes32 invoiceHash;   // Fatura hash'i
        uint256 amount;
        uint256 timestamp;
        string category;
        bool auditorApproved;
    }
    
    mapping(bytes32 => Expense) public expenses;
    
    function recordExpense(
        bytes32 _expenseId,
        bytes32 _invoiceHash,
        uint256 _amount,
        string memory _category
    ) external onlyManager {
        expenses[_expenseId] = Expense({
            invoiceHash: _invoiceHash,
            amount: _amount,
            timestamp: block.timestamp,
            category: _category,
            auditorApproved: false
        });
    }
    
    function approveExpense(bytes32 _expenseId) external onlyAuditor {
        expenses[_expenseId].auditorApproved = true;
    }
}
```

---

## 🔧 Flutter Entegrasyonu

```dart
// Web3 Service
class BlockchainService {
  late Web3Client _client;
  late Credentials _credentials;
  late DeployedContract _decisionContract;
  
  Future<void> initialize() async {
    _client = Web3Client(polygonRpcUrl, Client());
    // Contract ABI yükle
  }
  
  Future<String> recordDecision({
    required int decisionId,
    required String decisionContent,
  }) async {
    // 1. İçeriği hash'le
    final contentHash = keccak256(utf8.encode(decisionContent));
    
    // 2. İçeriği IPFS'e yükle
    final ipfsUri = await _uploadToIPFS(decisionContent);
    
    // 3. Hash'i blockchain'e yaz
    final txHash = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _decisionContract,
        function: _recordDecisionFunction,
        parameters: [
          BigInt.from(decisionId),
          contentHash,
          ipfsUri,
        ],
      ),
    );
    
    return txHash;
  }
  
  Future<bool> verifyDecision({
    required int decisionId,
    required String decisionContent,
  }) async {
    final contentHash = keccak256(utf8.encode(decisionContent));
    
    final result = await _client.call(
      contract: _decisionContract,
      function: _verifyDecisionFunction,
      params: [BigInt.from(decisionId), contentHash],
    );
    
    return result.first as bool;
  }
}
```

---

## 📁 IPFS Entegrasyonu

Büyük dosyalar (fatura görselleri, karar belgeleri) IPFS'te saklanır:

```dart
class IPFSService {
  final String _pinataApiKey;
  final String _pinataSecretKey;
  
  Future<String> uploadFile(File file) async {
    final response = await Dio().post(
      'https://api.pinata.cloud/pinning/pinFileToIPFS',
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      }),
      options: Options(headers: {
        'pinata_api_key': _pinataApiKey,
        'pinata_secret_api_key': _pinataSecretKey,
      }),
    );
    
    return 'ipfs://${response.data['IpfsHash']}';
  }
  
  Future<Uint8List> downloadFile(String ipfsUri) async {
    final hash = ipfsUri.replaceFirst('ipfs://', '');
    final response = await Dio().get(
      'https://gateway.pinata.cloud/ipfs/$hash',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }
}
```

---

## 💰 Maliyet Analizi

### Polygon Gas Maliyetleri (Tahmini)

| İşlem | Gas | Maliyet (MATIC) | ~TL |
|-------|-----|-----------------|-----|
| Karar Kayıt | ~50,000 | 0.001 | ₺0.5 |
| Harcama Kayıt | ~40,000 | 0.0008 | ₺0.4 |
| Doğrulama | 0 (read) | 0 | ₺0 |

**Aylık Tahmini Maliyet (orta büyüklükte site):**
- 4 karar + 20 harcama = ~₺12/ay

---

## 🔐 Güvenlik Önlemleri

1. **Cüzdan Yönetimi:** Yönetici cüzdanları için multi-sig
2. **Yetkilendirme:** Smart contract'ta role-based access
3. **Backup:** Seed phrase güvenli saklama
4. **Audit:** Smart contract güvenlik denetimi

---

## 📊 Şeffaflık Dashboard

### Sakinlerin Görebileceği Bilgiler

```
┌─────────────────────────────────┐
│ 📜 Şeffaflık Merkezi           │
├─────────────────────────────────┤
│                                 │
│ 📋 Son Kararlar                 │
│ ┌─────────────────────────────┐ │
│ │ #42 Asansör Bakım Sözleşmesi│ │
│ │ 📅 02.02.2026               │ │
│ │ ✅ Blockchain Doğrulandı    │ │
│ │ [Detay] [Doğrula]           │ │
│ └─────────────────────────────┘ │
│                                 │
│ 💰 Son Harcamalar               │
│ ┌─────────────────────────────┐ │
│ │ Temizlik Malzemesi ₺2,450   │ │
│ │ 📎 Fatura Görüntüle         │ │
│ │ ✅ Hash: 0x7f3a...          │ │
│ └─────────────────────────────┘ │
│                                 │
│ 📊 Aylık Özet                   │
│ Toplam Gelir: ₺125,450         │
│ Toplam Gider: ₺98,230          │
│ [Detaylı Rapor]                 │
│                                 │
└─────────────────────────────────┘
```

---

## ⚠️ Opsiyonel Modül Olarak Sunma

Blockchain özellikleri tüm siteler için zorunlu olmayacaktır:

```
Plan Seviyesi    | Blockchain
─────────────────┼───────────
Light            | ❌ Yok
Standard         | ⭕ Opsiyonel (+₺X/ay)
Enterprise       | ✅ Dahil
```

Bu yaklaşım:
- Küçük siteler için maliyeti düşürür
- İsteyen siteler için şeffaflık sağlar
- Kurumsal siteler için değer katar
