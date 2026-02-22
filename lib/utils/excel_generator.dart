import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../data/mock/member_mock_data.dart';

List<int>? generateCollectionReceiptExcel(
  MemberData member,
  Map<String, double> debts,
  double totalAmount,
  DateTime date,
  String receiptNo,
  String description,
  String note,
  String paymentMethod,
) {
  var excel = Excel.createExcel();

  // Use 'Sheet1' or create a new one
  String sheetName = 'Tahsilat Makbuzu';
  Sheet sheet = excel[sheetName];
  excel.delete('Sheet1'); // Remove default sheet if not used or rename it

  // Styles
  CellStyle headerStyle = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  CellStyle boldStyle = CellStyle(bold: true);

  // Title
  sheet.merge(
    CellIndex.indexByString("A1"),
    CellIndex.indexByString("F1"),
    customValue: TextCellValue("NET YOL SİTESİ - TAHSİLAT MAKBUZU"),
  );
  var titleCell = sheet.cell(CellIndex.indexByString("A1"));
  titleCell.value = TextCellValue("NET YOL SİTESİ - TAHSİLAT MAKBUZU");
  titleCell.cellStyle = headerStyle;

  // Info Rows
  final dateFormat = DateFormat('dd-MM-yyyy');

  sheet.cell(CellIndex.indexByString("A3")).value = TextCellValue("Tarih:");
  sheet.cell(CellIndex.indexByString("B3")).value = TextCellValue(
    dateFormat.format(date),
  );

  sheet.cell(CellIndex.indexByString("A4")).value = TextCellValue("Makbuz No:");
  sheet.cell(CellIndex.indexByString("B4")).value = TextCellValue(receiptNo);

  sheet.cell(CellIndex.indexByString("A5")).value = TextCellValue(
    "Ödeme Yöntemi:",
  );
  sheet.cell(CellIndex.indexByString("B5")).value = TextCellValue(
    paymentMethod,
  );

  sheet.cell(CellIndex.indexByString("A6")).value = TextCellValue(
    "Düzenleyen:",
  );
  sheet.cell(CellIndex.indexByString("B6")).value = TextCellValue("ALİ ER");

  sheet.cell(CellIndex.indexByString("D3")).value = TextCellValue("Ad Soyad:");
  sheet.cell(CellIndex.indexByString("E3")).value = TextCellValue(
    member.fullName,
  );

  sheet.cell(CellIndex.indexByString("D4")).value = TextCellValue("Blok/No:");
  sheet.cell(CellIndex.indexByString("E4")).value = TextCellValue(
    "${member.block} / ${member.unitNo}",
  );

  // Table Header
  int rowIndex = 8;
  List<String> headers = ["Blok", "No", "Ödenen", "Tutar", "Gecikme", "Toplam"];
  for (int i = 0; i < headers.length; i++) {
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
    );
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = boldStyle;
  }

  rowIndex++;

  // Debts
  final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  debts.forEach((type, amount) {
    double delay = type == 'Aidat' ? amount * 0.05 : 0.0;
    double total = amount + delay;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = TextCellValue(
      member.block.split(' ').first,
    );
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = TextCellValue(
      member.unitNo,
    );
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = TextCellValue(
      type,
    );
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = TextCellValue(
      currencyFormat.format(amount),
    );
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        .value = TextCellValue(
      currencyFormat.format(delay),
    );
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
        .value = TextCellValue(
      currencyFormat.format(total),
    );

    rowIndex++;
  });

  // Total
  rowIndex++;
  sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
      .value = TextCellValue(
    "(Genel Toplam)",
  );
  sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .cellStyle =
      boldStyle;

  sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
      .value = TextCellValue(
    currencyFormat.format(totalAmount),
  );
  sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .cellStyle =
      boldStyle;

  // Notes
  if (description.isNotEmpty) {
    rowIndex += 2;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = TextCellValue(
      "Açıklama: $description",
    );
  }

  if (note.isNotEmpty) {
    rowIndex += 1;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = TextCellValue(
      "Not: $note",
    );
  }

  return excel.encode();
}
