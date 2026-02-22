import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/mock/member_mock_data.dart';

class AccountActivityStatement extends StatelessWidget {
  final MemberData member;
  final List<Map<String, dynamic>> transactions;
  final DateTime? startDate;
  final DateTime? endDate;

  const AccountActivityStatement({
    super.key,
    required this.member,
    required this.transactions,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormat = DateFormat('dd.MM.yyyy');

    double totalDebt = 0;
    double totalPaid = 0;
    double totalBalance = 0;

    for (var tx in transactions) {
      totalDebt += (tx['debt'] as num).toDouble();
      totalPaid += (tx['paid'] as num).toDouble();
      totalBalance += (tx['balance'] as num).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header (Same as CollectionReceipt)
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
                  'HESAP EKSTRESİ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  'Tarih',
                  ': ${dateFormat.format(DateTime.now())}',
                ),
                if (startDate != null && endDate != null)
                  _buildInfoRow(
                    'Dönem',
                    ': ${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}',
                  ),
                _buildInfoRow('Düzenleyen', ': YÖNETİM'),
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
                color: const Color(0xFFEEEEEE),
                child: const Text(
                  'Ad Soyad / Blok - Daire',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  '${member.fullName} - ${member.block} / No: ${member.unitNo}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Transactions Table
        Table(
          border: TableBorder.all(color: Colors.black26),
          columnWidths: const {
            0: FlexColumnWidth(2), // Tarih
            1: FlexColumnWidth(2), // Makbuz
            2: FlexColumnWidth(4), // Açıklama
            3: FlexColumnWidth(2), // Borç
            4: FlexColumnWidth(2), // Ödenen
            5: FlexColumnWidth(2), // Bakiye
          },
          children: [
            // Header
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
              children: [
                _TableCell(
                  text: 'Tarih',
                  isHeader: true,
                  align: TextAlign.center,
                ),
                _TableCell(
                  text: 'Makbuz',
                  isHeader: true,
                  align: TextAlign.center,
                ),
                _TableCell(
                  text: 'Açıklama',
                  isHeader: true,
                  align: TextAlign.center,
                ),
                _TableCell(
                  text: 'Borç',
                  isHeader: true,
                  align: TextAlign.center,
                ),
                _TableCell(
                  text: 'Ödenen',
                  isHeader: true,
                  align: TextAlign.center,
                ),
                _TableCell(
                  text: 'Bakiye',
                  isHeader: true,
                  align: TextAlign.center,
                ),
              ],
            ),
            // Rows
            ...transactions.map((tx) {
              return TableRow(
                children: [
                  _TableCell(
                    text: dateFormat.format(tx['date'] as DateTime),
                    align: TextAlign.center,
                  ),
                  _TableCell(
                    text: tx['receiptNo']?.toString() ?? '-',
                    align: TextAlign.center,
                  ),
                  _TableCell(text: tx['description'].toString()),
                  _TableCell(
                    text: currencyFormat.format(tx['debt']),
                    align: TextAlign.right,
                  ),
                  _TableCell(
                    text: currencyFormat.format(tx['paid']),
                    align: TextAlign.right,
                  ),
                  _TableCell(
                    text: currencyFormat.format(tx['balance']),
                    align: TextAlign.right,
                  ),
                ],
              );
            }),
            // Total
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
              children: [
                const SizedBox(),
                const SizedBox(),
                const _TableCell(
                  text: 'TOPLAM',
                  isHeader: true,
                  align: TextAlign.right,
                ),
                _TableCell(
                  text: currencyFormat.format(totalDebt),
                  isHeader: true,
                  align: TextAlign.right,
                ),
                _TableCell(
                  text: currencyFormat.format(totalPaid),
                  isHeader: true,
                  align: TextAlign.right,
                ),
                _TableCell(
                  text: currencyFormat.format(totalBalance),
                  isHeader: true,
                  align: TextAlign.right,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Bu belge elektronik ortamda üretilmiştir.',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
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
  final TextAlign align;

  const _TableCell({
    required this.text,
    this.isHeader = false,
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
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 10, // Slightly smaller for table compact
          color: Colors.black87,
        ),
      ),
    );
  }
}
