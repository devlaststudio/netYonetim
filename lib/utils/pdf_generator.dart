import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../../data/mock/member_mock_data.dart';
import 'package:intl/intl.dart';

Future<Uint8List> generateCollectionReceiptPdf(
  MemberData member,
  Map<String, double> debts,
  double totalAmount,
  DateTime date,
  String receiptNo,
  String description,
  String note,
  String paymentMethod,
) async {
  final pdf = pw.Document();

  // Load fonts that support Turkish characters
  final font = await PdfGoogleFonts.robotoRegular();
  final fontBold = await PdfGoogleFonts.robotoBold();
  final fontItalic = await PdfGoogleFonts.robotoItalic();

  final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  final dateFormat = DateFormat('dd-MM-yyyy');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
        italic: fontItalic,
      ),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NET YOL SİTESİ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'NET YOL SİTESİ',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      '(505) 223-68-97',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'bekirakbulut@hotmail.com',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TAHSİLAT MAKBUZU',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    _buildPdfInfoRow('Tarih', ': ${dateFormat.format(date)}'),
                    _buildPdfInfoRow('Makbuz No', ': $receiptNo'),
                    _buildPdfInfoRow('Ödeme Yöntemi', ': $paymentMethod'),
                    _buildPdfInfoRow('Düzenleyen', ': ALİ ER'),
                  ],
                ),
              ],
            ),

            pw.Divider(thickness: 0.5, height: 12),

            // Member Info
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: PdfColors.grey300,
                    child: pw.Text(
                      'Ad Soyad',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      member.fullName,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(4),
                3: pw.FlexColumnWidth(2),
                4: pw.FlexColumnWidth(2),
                5: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildPdfTableCell('Blok', isHeader: true),
                    _buildPdfTableCell('No', isHeader: true),
                    _buildPdfTableCell('Ödenen', isHeader: true),
                    _buildPdfTableCell('Tutar', isHeader: true),
                    _buildPdfTableCell('Gecikme', isHeader: true),
                    _buildPdfTableCell('Toplam', isHeader: true),
                  ],
                ),
                ...debts.entries.map((entry) {
                  final type = entry.key;
                  final amount = entry.value;
                  final delay = type == 'Aidat' ? amount * 0.05 : 0.0;
                  final total = amount + delay;
                  return pw.TableRow(
                    children: [
                      _buildPdfTableCell(member.block.split(' ').first),
                      _buildPdfTableCell(member.unitNo),
                      _buildPdfTableCell(type),
                      _buildPdfTableCell(
                        currencyFormat.format(amount),
                        align: pw.TextAlign.right,
                      ),
                      _buildPdfTableCell(
                        currencyFormat.format(delay),
                        align: pw.TextAlign.right,
                      ),
                      _buildPdfTableCell(
                        currencyFormat.format(total),
                        align: pw.TextAlign.right,
                      ),
                    ],
                  );
                }),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    _buildPdfTableCell(
                      '(Genel Toplam)',
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.right,
                    ),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    _buildPdfTableCell(
                      currencyFormat.format(totalAmount),
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 6),

            pw.Center(
              child: pw.Text(
                '-YalnızYüzTürkLirasi- Tahsil Edilmiştir.',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),

            if (description.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Text(
                  'Açıklama: $description',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],

            pw.Spacer(),

            // Signature
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 32, bottom: 20),
                  child: pw.Text(
                    'Kaşe / İmza',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            pw.Divider(color: PdfColors.grey400, height: 1),

            // Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Kayıtlarda değişiklik olması durumunda yönetimin kayıtları geçerlidir.',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Hesap özetinize www.aidattakipsistemi.com adresinden ulaşabilirsiniz.',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                // QR Code
                pw.BarcodeWidget(
                  data: 'https://www.aidattakipsistemi.com/makbuz/$receiptNo',
                  width: 50,
                  height: 50,
                  barcode: pw.Barcode.qrCode(),
                  drawText: false,
                ),
              ],
            ),

            // Custom Note
            if (note.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(6),
                color: PdfColors.yellow100,
                child: pw.Text(
                  'Not: $note',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ],
        );
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildPdfInfoRow(String label, String value) {
  return pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.SizedBox(
        width: 60,
        child: pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
    ],
  );
}

pw.Widget _buildPdfTableCell(
  String text, {
  bool isHeader = false,
  pw.FontWeight? fontWeight,
  pw.TextAlign align = pw.TextAlign.left,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: isHeader
            ? pw.FontWeight.bold
            : (fontWeight ?? pw.FontWeight.normal),
      ),
    ),
  );
}

Future<Uint8List> generateAccountActivityPdf(
  MemberData member,
  List<Map<String, dynamic>> transactions,
  DateTime? startDate,
  DateTime? endDate,
) async {
  final pdf = pw.Document();
  final font = await PdfGoogleFonts.robotoRegular();
  final fontBold = await PdfGoogleFonts.robotoBold();

  final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  final dateFormat = DateFormat('dd.MM.yyyy');

  // Calculate totals
  double totalDebt = 0;
  double totalPaid = 0;
  double totalBalance = 0;

  for (var tx in transactions) {
    totalDebt += (tx['debt'] as num).toDouble();
    totalPaid += (tx['paid'] as num).toDouble();
    totalBalance += (tx['balance'] as num).toDouble();
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (pw.Context context) {
        return [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'NET YOL SİTESİ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'NET YOL SİTESİ',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '(505) 223-68-97',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'bekirakbulut@hotmail.com',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'HESAP EKSTRESİ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  _buildPdfInfoRow(
                    'Tarih',
                    ': ${dateFormat.format(DateTime.now())}',
                  ),
                  if (startDate != null && endDate != null)
                    _buildPdfInfoRow(
                      'Dönem',
                      ': ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                    ),
                  _buildPdfInfoRow('Düzenleyen', ': YÖNETİM'),
                ],
              ),
            ],
          ),
          pw.Divider(thickness: 0.5, height: 12),

          // Member Info
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color: PdfColors.grey300,
                  child: pw.Text(
                    'Ad Soyad / Blok - Daire',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    '${member.fullName} - ${member.block} / No: ${member.unitNo}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // Transactions Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FlexColumnWidth(2), // Tarih
              1: pw.FlexColumnWidth(2), // Makbuz
              2: pw.FlexColumnWidth(4), // Açıklama
              3: pw.FlexColumnWidth(2), // Borç
              4: pw.FlexColumnWidth(2), // Ödenen
              5: pw.FlexColumnWidth(2), // Bakiye
            },
            children: [
              // Table Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildPdfTableCell(
                    'Tarih',
                    isHeader: true,
                    align: pw.TextAlign.center,
                  ),
                  _buildPdfTableCell(
                    'Makbuz',
                    isHeader: true,
                    align: pw.TextAlign.center,
                  ),
                  _buildPdfTableCell(
                    'Açıklama',
                    isHeader: true,
                    align: pw.TextAlign.center,
                  ),
                  _buildPdfTableCell(
                    'Borç',
                    isHeader: true,
                    align: pw.TextAlign.center,
                  ),
                  _buildPdfTableCell(
                    'Ödenen',
                    isHeader: true,
                    align: pw.TextAlign.center,
                  ),
                  _buildPdfTableCell(
                    'Bakiye',
                    isHeader: true,
                    align: pw.TextAlign.center,
                  ),
                ],
              ),
              // Transaction Rows
              ...transactions.map((tx) {
                return pw.TableRow(
                  children: [
                    _buildPdfTableCell(
                      dateFormat.format(tx['date'] as DateTime),
                      align: pw.TextAlign.center,
                    ),
                    _buildPdfTableCell(
                      tx['receiptNo']?.toString() ?? '-',
                      align: pw.TextAlign.center,
                    ),
                    _buildPdfTableCell(tx['description'].toString()),
                    _buildPdfTableCell(
                      currencyFormat.format(tx['debt']),
                      align: pw.TextAlign.right,
                    ),
                    _buildPdfTableCell(
                      currencyFormat.format(tx['paid']),
                      align: pw.TextAlign.right,
                    ),
                    _buildPdfTableCell(
                      currencyFormat.format(tx['balance']),
                      align: pw.TextAlign.right,
                      // Logic for color in standard PDF is tricky without rich text, keeping simple black for now
                      // unless checking library capabilities. Pdf/Widgets supports Text color.
                    ),
                  ],
                );
              }),
              // Total Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.SizedBox(),
                  pw.SizedBox(),
                  _buildPdfTableCell(
                    'TOPLAM',
                    isHeader: true,
                    align: pw.TextAlign.right,
                  ),
                  _buildPdfTableCell(
                    currencyFormat.format(totalDebt),
                    isHeader: true,
                    align: pw.TextAlign.right,
                  ),
                  _buildPdfTableCell(
                    currencyFormat.format(totalPaid),
                    isHeader: true,
                    align: pw.TextAlign.right,
                  ),
                  _buildPdfTableCell(
                    currencyFormat.format(totalBalance),
                    isHeader: true,
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'Bu belge elektronik ortamda üretilmiştir.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
        ];
      },
    ),
  );

  return pdf.save();
}
