import 'package:flutter/material.dart';

/// Tembel (Lazy) IndexedStack Widget'ı
///
/// Standart [IndexedStack]'ten farkı:
/// - Sayfaları sadece ilk kez görüntülendiklerinde oluşturur (build eder)
/// - Daha önce hiç açılmamış sayfalar için boş alan gösterir
/// - Bir kez oluşturulan sayfalar bellekte kalır (cache)
/// - Sayfa geçişleri anlık olur (tekrar build yok)
///
/// Kullanım:
/// ```dart
/// LazyIndexedStack(
///   index: _seciliSayfaIndex,
///   children: [SayfaA(), SayfaB(), SayfaC()],
/// )
/// ```
class LazyIndexedStack extends StatefulWidget {
  /// Görüntülenecek sayfanın index numarası
  final int index;

  /// Tüm sayfa widget'ları listesi
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<LazyIndexedStack> createState() => LazyIndexedStackState();
}

class LazyIndexedStackState extends State<LazyIndexedStack> {
  /// Daha önce ziyaret edilmiş sayfa index'lerini tutan küme
  final Set<int> _yuklenenSayfalar = {};

  @override
  void initState() {
    super.initState();
    // İlk açılan sayfayı yüklenen listesine ekle
    _yuklenenSayfalar.add(widget.index);
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Yeni seçilen sayfayı yüklenen listesine ekle
    _yuklenenSayfalar.add(widget.index);
  }

  /// Tüm cache'lenmiş sayfaları temizler ve sıfırdan yükler.
  /// Site değişikliği gibi durumlarda kullanılır.
  void tumSayfalariSifirla() {
    setState(() {
      _yuklenenSayfalar.clear();
      _yuklenenSayfalar.add(widget.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        // Sadece daha önce ziyaret edilmiş sayfaları oluştur,
        // diğerleri için boş alan göster
        if (_yuklenenSayfalar.contains(i)) {
          return widget.children[i];
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
