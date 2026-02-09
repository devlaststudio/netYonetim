/// Gecikme Tazminatı Hesaplayıcı (KMK Md. 20)
///
/// Kat Mülkiyeti Kanunu Madde 20'ye göre gecikme tazminatı hesaplaması yapar.
/// Yasal aylık gecikme tazminatı oranı %5'tir.
class DelayFeeCalculator {
  // Aylık %5 gecikme tazminatı (yasal oran)
  static const double monthlyRate = 0.05;

  /// Gecikme tazminatını hesaplar
  ///
  /// [principal]: Ana borç tutarı
  /// [dueDate]: Vade tarihi
  /// [paymentDate]: Ödeme tarihi (yoksa bugün)
  ///
  /// Returns: Gecikme tazminatı tutarı
  static double calculate({
    required double principal,
    required DateTime dueDate,
    DateTime? paymentDate,
  }) {
    final payment = paymentDate ?? DateTime.now();

    // Ödeme vade tarihinden önce yapıldıysa gecikme yok
    if (payment.isBefore(dueDate) || payment.isAtSameMomentAs(dueDate)) {
      return 0.0;
    }

    final daysLate = payment.difference(dueDate).inDays;

    // Gün sayısını aya çevir (30 gün = 1 ay)
    final monthsLate = (daysLate / 30).ceil();

    // Basit faiz hesabı: Ana Para × Oran × Süre
    final delayFee = principal * monthlyRate * monthsLate;

    return delayFee;
  }

  /// Gecikme günü sayısını hesaplar
  static int calculateDaysLate({
    required DateTime dueDate,
    DateTime? paymentDate,
  }) {
    final payment = paymentDate ?? DateTime.now();

    if (payment.isBefore(dueDate) || payment.isAtSameMomentAs(dueDate)) {
      return 0;
    }

    return payment.difference(dueDate).inDays;
  }

  /// Gecikme ay sayısını hesaplar
  static int calculateMonthsLate({
    required DateTime dueDate,
    DateTime? paymentDate,
  }) {
    final daysLate = calculateDaysLate(
      dueDate: dueDate,
      paymentDate: paymentDate,
    );

    return (daysLate / 30).ceil();
  }

  /// Toplam ödenecek tutarı hesaplar (Ana Para + Gecikme Bedeli)
  static double calculateTotalAmount({
    required double principal,
    required DateTime dueDate,
    DateTime? paymentDate,
  }) {
    final delayFee = calculate(
      principal: principal,
      dueDate: dueDate,
      paymentDate: paymentDate,
    );

    return principal + delayFee;
  }

  /// Gecikme durumunu açıklayan metin döndürür
  static String getDelayDescription({
    required DateTime dueDate,
    DateTime? paymentDate,
  }) {
    final daysLate = calculateDaysLate(
      dueDate: dueDate,
      paymentDate: paymentDate,
    );

    if (daysLate == 0) {
      return 'Gecikme yok';
    }

    final monthsLate = (daysLate / 30).ceil();

    if (daysLate < 30) {
      return '$daysLate gün gecikme';
    }

    return '$monthsLate ay ($daysLate gün) gecikme';
  }
}
