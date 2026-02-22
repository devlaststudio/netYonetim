import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class QuickTransactionsPanel extends StatefulWidget {
  const QuickTransactionsPanel({super.key});

  @override
  State<QuickTransactionsPanel> createState() => _QuickTransactionsPanelState();
}

class _QuickTransactionsPanelState extends State<QuickTransactionsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Custom TabBar header
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.add_circle_outline, size: 18),
                  text: 'Ödeme Tanımla',
                ),
                Tab(
                  icon: Icon(Icons.account_balance_wallet, size: 18),
                  text: 'Tahsilat',
                ),
                Tab(icon: Icon(Icons.account_balance, size: 18), text: 'Kasa'),
                Tab(icon: Icon(Icons.credit_card, size: 18), text: 'Kredi'),
              ],
            ),
          ),

          // Tab Content Area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentDefinitionTab(),
                _buildCollectionTab(),
                _buildCashTab(),
                _buildCreditTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: ÖDEME TANIMLA
  // ==========================================
  Widget _buildPaymentDefinitionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField('Apartman Üyesi', 'Tüm Aktif Apartman Üyeleri'),
          const SizedBox(height: 20),

          const Text(
            'İstisnalı Apartman Üyeleri',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: const Text(
                  'Daire:2 - AYŞE',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Colors.pinkAccent.shade200,
                deleteIcon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
                onDeleted: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDropdownField(
            'Borçlandırma Önceliği',
            'Her zaman kat maliğini borçlandır',
          ),
          const SizedBox(height: 20),

          _buildDropdownField('Borçlandırma Şekli', 'Daire Başı Borçlandır'),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildDropdownField('Ödeme Açıklaması', 'Demirbaş'),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Daire Başı Tutar (₺)', '60.00')),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildDatePickerField('Ödeme Tarihi', '19/06/2021'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePickerField('Son Ödeme Tarihi', '04/07/2021'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildCheckboxOption('Daire üyesine bildirim gönderilsin'),
          _buildCheckboxOption(
            'Gecikme süresi bitiminde yasal takip başlatılsın',
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Borçlandır'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF4DB6AC,
                ), // Teal matching screenshot
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: TAHSİLAT
  // ==========================================
  Widget _buildCollectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField('Apartman Üyesi', 'Daire:1 - ALPEREN'),
          const SizedBox(height: 8),

          // Pending Payments small block
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Daire:1 - ALPEREN',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),

          // Debt List Info (Mocked like screenshot)
          Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'Borç Açıklama',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Borç',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Tutar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: true,
                        onChanged: (v) {},
                        activeColor: const Color(0xFF4DB6AC),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Demirbaş',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Son Ödeme Tarihi : 4.07.2021',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text('₺250,00', style: TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  child: const Text(
                    '₺250,00',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildDropdownField('Ödeme Şekli', 'Banka Transferi'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePickerField('Tahsilat Tarihi', '19/06/2021'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tahsilat Edilen Tutar (₺)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('₺250,00', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ödenmesi Gereken (₺)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '₺250,00',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildCheckboxOption(
            'Gecikme Bedeli Uygulansın mı?',
            isChecked: true,
          ),
          _buildCheckboxOption('Daire üyesine bildirim gönderilsin'),
          _buildCheckboxOption('Makbuz Yazdırılsın mı?'),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: KASA
  // ==========================================
  Widget _buildCashTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField('Ödeme Açıklaması', 'Avukatlık'),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _buildTextField('Tutar (₺)', '600,00')),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdownField('Ödeme Tipi', 'Gider')),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDatePickerField('Ödeme Tarihi', '19/06/2021'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.background,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Evrak veya belge ekleyin',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              const Text(
                'Cari Seçimi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF4DB6AC)),
                label: const Text(
                  'Yeni Cari',
                  style: TextStyle(
                    color: Color(0xFF4DB6AC),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDropdownField('', 'Doğrudan Kasaya Tanımla'),

          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Ödemeyi Tanımla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DB6AC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: KREDİ
  // ==========================================
  Widget _buildCreditTab() {
    return const Center(
      child: Text(
        'Kredi Seçenekleri ve Taksitler',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildDropdownField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: hint,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              items: [
                DropdownMenuItem(
                  value: hint,
                  child: Text(
                    hint,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(String label, {bool isChecked = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: isChecked,
              onChanged: (_) {},
              activeColor: const Color(0xFF4DB6AC),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
