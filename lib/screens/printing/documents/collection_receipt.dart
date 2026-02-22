import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/mock/member_mock_data.dart';
import '../../../../core/theme/app_theme.dart';

class CollectionReceipt extends StatelessWidget {
  final MemberData member;
  final Map<String, double> debts;
  final double totalAmount;
  final DateTime date;
  final String receiptNo;

  final String description;
  final String paymentMethod;

  const CollectionReceipt({
    super.key,
    required this.member,
    required this.debts,
    required this.totalAmount,
    required this.date,
    required this.receiptNo,
    required this.description,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormat = DateFormat('dd-MM-yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NET YOL SİTESİ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                const Text('NET YOL SİTESİ', style: TextStyle(fontSize: 11)),
                const Text('(505) 223-68-97', style: TextStyle(fontSize: 11)),
                const Text(
                  'bekirakbulut@hotmail.com',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TAHSİLAT MAKBUZU',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Tarih', ': ${dateFormat.format(date)}'),
                _buildInfoRow('Makbuz No', ': $receiptNo'),
                _buildInfoRow('Ödeme Yöntemi', ': $paymentMethod'),
                _buildInfoRow('Düzenleyen', ': ALİ ER'),
              ],
            ),
          ],
        ),

        const Divider(thickness: 1, height: 16, color: Colors.black26),

        // Member Info
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: const Color(0xFFEEEEEE), // Match table header color
                child: const Text(
                  'Ad Soyad',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  member.fullName,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8), // Reduced spacing
        // Table Header
        Table(
          border: TableBorder.all(color: Colors.black26),
          columnWidths: const {
            0: FlexColumnWidth(1), // Blok
            1: FlexColumnWidth(1), // No
            2: FlexColumnWidth(4), // Ödenen
            3: FlexColumnWidth(2), // Tutar
            4: FlexColumnWidth(2), // Gecikme
            5: FlexColumnWidth(2), // Toplam
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
              children: [
                _TableCell(text: 'Blok', isHeader: true),
                _TableCell(text: 'No', isHeader: true),
                _TableCell(text: 'Ödenen', isHeader: true),
                _TableCell(text: 'Tutar', isHeader: true),
                _TableCell(text: 'Gecikme', isHeader: true),
                _TableCell(text: 'Toplam', isHeader: true),
              ],
            ),
            // Dynamic Debt Rows
            ...debts.entries.map((entry) {
              final type = entry.key;
              final amount = entry.value;
              // Mock delay calculation (5% if Aidat) for consistency
              final delay = type == 'Aidat' ? amount * 0.05 : 0.0;
              final total = amount + delay;

              return TableRow(
                children: [
                  _TableCell(text: member.block.split(' ').first),
                  _TableCell(text: member.unitNo),
                  _TableCell(text: type),
                  _TableCell(
                    text: currencyFormat.format(amount),
                    align: TextAlign.right,
                  ),
                  _TableCell(
                    text: currencyFormat.format(delay),
                    align: TextAlign.right,
                  ),
                  _TableCell(
                    text: currencyFormat.format(total),
                    align: TextAlign.right,
                  ),
                ],
              );
            }),
            // Total Row
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
              children: [
                const SizedBox(),
                const SizedBox(),
                const _TableCell(
                  text: '(Genel Toplam)',
                  fontWeight: FontWeight.bold,
                  align: TextAlign.right,
                ),
                const SizedBox(),
                const SizedBox(),
                _TableCell(
                  text: currencyFormat.format(totalAmount),
                  fontWeight: FontWeight.bold,
                  align: TextAlign.right,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 6), // Reduced spacing
        // Amount in words (Mock)
        const Center(
          child: Text(
            '-YalnızYüzTürkLirasi- Tahsil Edilmiştir.',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ), // Reduced font size
          ),
        ),

        if (description.isNotEmpty) ...[
          const SizedBox(height: 6), // Reduced spacing
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              'Açıklama: $description',
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
        ],

        const Spacer(),

        // Signature Area
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 32.0, bottom: 20.0),
              child: Text(
                'Kaşe / İmza',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),

        const Divider(color: Colors.black26, height: 1),

        // Footer Info & QR
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/1041/1041888.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.apartment,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kayıtlarda değişiklik olması durumunda yönetimin kayıtları geçerlidir.',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Text(
                  'Hesap özetinize www.aidattakipsistemi.com adresinden ulaşabilirsiniz.',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            Container(
              width: 60,
              height: 60,
              color: Colors.black12,
              child: const Center(child: Icon(Icons.qr_code_2, size: 40)),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final FontWeight? fontWeight;
  final TextAlign align;

  const _TableCell({
    required this.text,
    this.isHeader = false,
    this.fontWeight,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontWeight: isHeader
              ? FontWeight.bold
              : (fontWeight ?? FontWeight.normal),
          fontSize: 11,
          color: Colors.black87,
        ),
      ),
    );
  }
}
