import 'package:flutter/material.dart';

class CustomColors {
  // Kullanıcının belirlediği özel renk paleti
  // Başlangıç rengi: const Color.fromARGB(255, 57, 97, 137).withValues(alpha: 0.7)

  static const Color tableHeaderBackground = Color.fromARGB(255, 62, 84, 110);

  // Opaklık (alpha) değerleri
  static double headerAlpha = 0.7;

  // İleride kullanıcı tarafından isimlendirilecek renkler için placeholder'lar
  static const Color customBlue1 = Color.fromARGB(255, 57, 97, 137);
  static const Color tableHeaderColor = Color.fromARGB(255, 71, 96, 129);
  static const Color tableRowColor = Color.fromARGB(255, 151, 163, 182);

  // Yardımcı metod: Header rengini alpha ile birlikte döndürür
  static Color get headerColor =>
      tableHeaderBackground.withValues(alpha: headerAlpha);
}
