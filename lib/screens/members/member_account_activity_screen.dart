import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/custom_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/member_mock_data.dart';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import '../../utils/pdf_generator.dart';
import 'transaction_detail_sheet.dart';
import '../printing/universal_print_screen.dart';
import '../printing/documents/account_activity_statement.dart';
import 'package:pdf/pdf.dart';

class MemberAccountActivityScreen extends StatefulWidget {
  final MemberData member;

  const MemberAccountActivityScreen({super.key, required this.member});

  @override
  State<MemberAccountActivityScreen> createState() =>
      _MemberAccountActivityScreenState();
}

class _MemberAccountActivityScreenState
    extends State<MemberAccountActivityScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  final ScrollController _horizontalScrollController = ScrollController();

  // Mock data for transactions
  final List<Map<String, dynamic>> _transactions = [
    {
      'date': DateTime(2026, 2, 12),
      'receiptNo': '1',
      'safe': 'Nakit Kasa',
      'description': 'Üyeye Ödenen',
      'debt': 100.00,
      'paid': 0.00,
      'balance': -100.00,
    },
    {
      'date': DateTime(2026, 2, 10),
      'receiptNo': '2',
      'safe': 'Banka',
      'description': 'Aidat Tahsilatı',
      'debt': 0.00,
      'paid': 500.00,
      'balance': 400.00,
    },
    {
      'date': DateTime(2026, 2, 1),
      'receiptNo': '-',
      'safe': '-',
      'description': 'Şubat Ayı Aidat Tahakkuku',
      'debt': 500.00,
      'paid': 0.00,
      'balance': -100.00,
    },
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${widget.member.fullName} - Hesap Hareketleri',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          return Column(
            children: [
              // 1. Summary Section (Top)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      SizedBox(
                        width: isMobile ? 140 : null,
                        child: _buildSummaryCard(
                          'Bakiye',
                          '0,00 ₺ (A)',
                          AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: isMobile ? 140 : null,
                        child: _buildSummaryCard(
                          'Aidat',
                          '0,00 ₺ (A)',
                          AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: isMobile ? 140 : null,
                        child: _buildSummaryCard(
                          'Yakıt',
                          '0,00 ₺ (A)',
                          AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: isMobile ? 140 : null,
                        child: _buildSummaryCard(
                          'Demirbaş',
                          '0,00 ₺ (A)',
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Filter Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _dateSelector(
                                  context: context,
                                  label: _startDate == null
                                      ? 'Başlangıç'
                                      : DateFormat(
                                          'dd.MM.yyyy',
                                        ).format(_startDate!),
                                  onTap: () => _selectDate(context, true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _dateSelector(
                                  context: context,
                                  label: _endDate == null
                                      ? 'Bitiş'
                                      : DateFormat(
                                          'dd.MM.yyyy',
                                        ).format(_endDate!),
                                  onTap: () => _selectDate(context, false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sorgulama yapılıyor...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text('Sorgula'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildDateFilter(),
              ),

              // 3. Transactions Table (Scrollable on Mobile)
              Expanded(
                child: isMobile
                    ? _buildMobileTransactionList()
                    : LayoutBuilder(
                        builder: (context, innerConstraints) {
                          return Scrollbar(
                            controller: _horizontalScrollController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: innerConstraints.maxHeight,
                                child: Column(
                                  children: [
                                    _buildTableHeader(),
                                    Expanded(child: _buildTransactionList()),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Row(
      children: [
        Expanded(
          child: _dateSelector(
            context: context,
            label: _startDate == null
                ? 'Başlangıç Tarihi'
                : DateFormat('dd.MM.yyyy').format(_startDate!),
            onTap: () => _selectDate(context, true),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _dateSelector(
            context: context,
            label: _endDate == null
                ? 'Bitiş Tarihi'
                : DateFormat('dd.MM.yyyy').format(_endDate!),
            onTap: () => _selectDate(context, false),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sorgulama yapılıyor...')),
            );
          },
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Sorgula'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateSelector({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: CustomColors.tableHeaderColor,
      child: Row(
        children: [
          _tableHeaderCell('Tarih', flex: 2),
          _tableHeaderCell('Mak.No', flex: 2),
          _tableHeaderCell('Kasa', flex: 2),
          _tableHeaderCell('Açıklama', flex: 5),
          _tableHeaderCell('Borç', flex: 2),
          _tableHeaderCell('Ödenen', flex: 2),
          _tableHeaderCell('Bakiye', flex: 2),
          _tableHeaderCell('İşlem', flex: 2, isLast: true),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(
    String text, {
    required int flex,
    bool isLast = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(right: BorderSide(color: Colors.white24)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMobileTransactionList() {
    return ListView.builder(
      itemCount: _transactions.length + 1,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          return _buildTotalFooter(isMobile: true);
        }
        final tx = _transactions[index];
        final isDebt = tx['debt'] > 0;
        final amount = isDebt ? tx['debt'] : tx['paid'];
        final color = isDebt ? AppColors.error : AppColors.success;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showTransactionDetail(tx, index),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(tx['date']),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          if (tx['receiptNo'] != null &&
                              tx['receiptNo'].toString() != '-') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                'Makbuz: ${tx['receiptNo']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if ((tx['paid'] as double) > 0)
                            InkWell(
                              onTap: () => _handlePrint(tx),
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.print,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx['description'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDebt ? Icons.arrow_outward : Icons.arrow_downward,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currencyFormat.format(amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Bakiye',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _currencyFormat.format(tx['balance']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: (tx['balance'] as double) < 0
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: _transactions.length + 1,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          return _buildTotalFooter();
        }
        final tx = _transactions[index];
        final isEven = index % 2 == 0;
        return Container(
          color: isEven ? Colors.white : AppColors.background,
          child: Row(
            children: [
              _tableCell(DateFormat('dd.MM.yyyy').format(tx['date']), flex: 2),
              _tableCell(tx['receiptNo'], flex: 2),
              _tableCell(tx['safe'], flex: 2),
              _tableCell(tx['description'], flex: 5, alignLeft: true),
              _tableCell(
                _currencyFormat.format(tx['debt']),
                flex: 2,
                color: Colors.red,
                alignRight: true,
              ),
              _tableCell(
                _currencyFormat.format(tx['paid']),
                flex: 2,
                color: Colors.black,
                alignRight: true,
              ),
              _tableCell(
                _currencyFormat.format(tx['balance']),
                flex: 2,
                color: (tx['balance'] as double) < 0
                    ? Colors.red
                    : Colors.green,
                alignRight: true,
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Detay',
                      onPressed: () => _showTransactionDetail(tx, index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.print_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Yazdır',
                      onPressed: () => _handlePrint(tx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tableCell(
    String text, {
    required int flex,
    Color? color,
    bool alignRight = false,
    bool alignLeft = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: alignLeft
            ? Alignment.centerLeft
            : (alignRight ? Alignment.centerRight : Alignment.center),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _handlePrintActivity() async {
    try {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UniversalPrinterScreen(
            title: 'Hesap Ekstresi Yazdır',
            content: AccountActivityStatement(
              member: widget.member,
              transactions: _transactions,
              startDate: _startDate,
              endDate: _endDate,
            ),
            onPrint: (note) async {
              final pdfBytes = await generateAccountActivityPdf(
                widget.member,
                _transactions,
                _startDate,
                _endDate,
              );
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdfBytes,
                name: 'Hesap Ekstresi',
              );
            },
            onPdf: (note) async {
              final pdfBytes = await generateAccountActivityPdf(
                widget.member,
                _transactions,
                _startDate,
                _endDate,
              );

              await FileSaver.instance.saveFile(
                name: 'hesap_ekstresi',
                bytes: Uint8List.fromList(pdfBytes),
                fileExtension: 'pdf',
                mimeType: MimeType.other,
                customMimeType: 'application/pdf',
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF ekstresi cihazınıza indirildi.'),
                  ),
                );
              }
            },
            onEmail: (note) async {
              if (kIsWeb) {
                // Web: Open mail client
                final String subject = 'Hesap Ekstresi - Net Yol Sitesi';
                final String body =
                    'Sayın ${widget.member.fullName},\n\nEkte hesap ekstreniz yer almaktadır.\n\nİyi günler dileriz.';

                final String emailPath = widget.member.email;

                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: emailPath,
                  query:
                      'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
                );

                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('E-posta uygulaması açılamadı.'),
                      ),
                    );
                  }
                }
              } else {
                // Mobile/Desktop: Share with attachment
                final pdfBytes = await generateAccountActivityPdf(
                  widget.member,
                  _transactions,
                  _startDate,
                  _endDate,
                );

                await Printing.sharePdf(
                  bytes: pdfBytes,
                  filename: 'hesap_ekstresi.pdf',
                  subject: 'Hesap Ekstresi - Net Yol Sitesi',
                  body:
                      'Sayın ${widget.member.fullName},\n\nEkte hesap ekstreniz yer almaktadır.\n\nİyi günler dileriz.',
                  emails: widget.member.email.isNotEmpty
                      ? [widget.member.email]
                      : null,
                );
              }
            },
            // Excel is optional, omitted for now as allowed by logic
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Widget _buildTotalFooter({bool isMobile = false}) {
    double totalDebt = 0;
    double totalPaid = 0;
    double totalBalance = 0;

    for (var tx in _transactions) {
      totalDebt += (tx['debt'] as num).toDouble();
      totalPaid += (tx['paid'] as num).toDouble();
      totalBalance += (tx['balance'] as num).toDouble();
    }

    if (isMobile) {
      return Column(
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 20, top: 8),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'GENEL TOPLAM',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Borç:',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        _currencyFormat.format(totalDebt),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Tahsilat:',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        _currencyFormat.format(totalPaid),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Genel Bakiye:',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        _currencyFormat.format(totalBalance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: totalBalance < 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _handlePrintActivity,
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Hesap Hareketlerini Yazdır'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Expanded(
                flex: 11, // Tarih(2)+Mak(2)+Kasa(2)+Açıklama(5)
                child: Text(
                  'TOPLAM',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Expanded(
                flex: 2, // Borç
                child: Text(
                  _currencyFormat.format(totalDebt),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 2, // Ödenen
                child: Text(
                  _currencyFormat.format(totalPaid),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 2, // Bakiye
                child: Text(
                  _currencyFormat.format(totalBalance),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: totalBalance < 0 ? Colors.red : Colors.green,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(flex: 2), // İşlem
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _handlePrintActivity,
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Hesap Hareketlerini Yazdır'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 1,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePrint(Map<String, dynamic> tx) async {
    if ((tx['paid'] as double) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sadece tahsilat işlemleri yazdırılabilir.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      final description = tx['description'].toString().toLowerCase();
      String category = 'Diğer';
      if (description.contains('aidat')) {
        category = 'Aidat';
      } else if (description.contains('yakıt') ||
          description.contains('yakit')) {
        category = 'Yakıt';
      } else if (description.contains('demirbaş') ||
          description.contains('demirbas')) {
        category = 'Demirbaş';
      }

      final debts = {category: (tx['paid'] as double)};

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Tahsilat Makbuzu'),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
            ),
            body: PdfPreview(
              build: (format) => generateCollectionReceiptPdf(
                widget.member,
                debts,
                tx['paid'] as double,
                tx['date'] as DateTime,
                tx['receiptNo']?.toString() ?? '-',
                tx['description'] as String,
                '', // No extra note for now
                tx['safe']?.toString() ?? 'Nakit',
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  void _showTransactionDetail(Map<String, dynamic> tx, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TransactionDetailSheet(
            transaction: tx,
            onDelete: () {
              setState(() {
                _transactions.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('İşlem başarıyla silindi'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            onUpdate: (updatedTx) {
              setState(() {
                _transactions[index] = updatedTx;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('İşlem güncellendi'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
