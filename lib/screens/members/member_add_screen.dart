import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

import '../../data/mock/member_mock_data.dart';

class MemberAddScreen extends StatefulWidget {
  final MemberData? initialMember;

  const MemberAddScreen({super.key, this.initialMember});

  @override
  State<MemberAddScreen> createState() => _MemberAddScreenState();
}

class _MemberAddScreenState extends State<MemberAddScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Genel Bilgiler',
    'Açılış Rakamları',
    'Sakinler',
    'Araçlar',
    'Dosyalar',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üye Ekle/Düzenle'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GeneralInfoTab(initialMember: widget.initialMember),
          const _OpeningFiguresTab(),
          const _ResidentsTab(),
          const _VehiclesTab(),
          const _FilesTab(),
        ],
      ),
    );
  }
}

// --- TAB 1: General Info ---

// --- TAB 1: General Info ---

class _GeneralInfoTab extends StatefulWidget {
  final MemberData? initialMember;
  const _GeneralInfoTab({this.initialMember});

  @override
  State<_GeneralInfoTab> createState() => _GeneralInfoTabState();
}

class _GeneralInfoTabState extends State<_GeneralInfoTab> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _entryDateController = TextEditingController(text: '01-01-2016');
  final _exitDateController = TextEditingController();
  final _nameController = TextEditingController(); // Ad Soyad
  final _tcController = TextEditingController(); // TC/Vergi No
  final _phoneController1 = TextEditingController();
  final _phoneController2 = TextEditingController();
  final _emailController1 = TextEditingController();
  final _emailController2 = TextEditingController();
  final _memberNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _accountingCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _employerNameController = TextEditingController();
  final _employerAddressController = TextEditingController();
  final _notesController = TextEditingController();

  // State Variables
  String _status = 'Malik';
  String _gender = 'Erkek';
  String? _bloodGroup;
  String? _profession;

  // Lists
  final List<String> _bloodGroups = [
    'A Rh+',
    'A Rh-',
    'B Rh+',
    'B Rh-',
    'AB Rh+',
    'AB Rh-',
    '0 Rh+',
    '0 Rh-',
  ];
  final List<String> _professions = [
    'Mühendis',
    'Doktor',
    'Öğretmen',
    'Avukat',
    'Emekli',
    'Serbest',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialMember != null) {
      final m = widget.initialMember!;
      _nameController.text = m.fullName;
      _phoneController1.text = m.phone;
      _emailController1.text = m.email;
      if (m.status == MemberStatus.malik) {
        _status = 'Malik';
      } else if (m.status == MemberStatus.kiraci) {
        _status = 'Kiracı';
      } else {
        _status = 'Kat Maliki';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // --- Group 1: Üyelik & Kimlik ---
            _buildSectionCard(
              title: 'Üyelik ve Kimlik Bilgileri',
              icon: Icons.person_outline,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Durumu',
                        value: _status,
                        items: ['Malik', 'Kiracı', 'Kat Maliki'],
                        onChanged: (val) => setState(() => _status = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Giriş Tarihi',
                        controller: _entryDateController,
                        hint: 'gg-aa-yyyy',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Çıkış Tarihi',
                        controller: _exitDateController,
                        hint: 'gg-aa-yyyy',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Placeholder
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.textTertiary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: 'Erkek',
                              groupValue: _gender,
                              onChanged: (val) =>
                                  setState(() => _gender = val!),
                              activeColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text('Erkek', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Radio<String>(
                              value: 'Kadın',
                              groupValue: _gender,
                              onChanged: (val) =>
                                  setState(() => _gender = val!),
                              activeColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text('Kadın', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Names
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Ad Soyad',
                            controller: _nameController,
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'TC Kimlik / Vergi No',
                            controller: _tcController,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Doğum Tarihi',
                                  controller: _birthDateController,
                                  hint: 'gg-aa-yyyy',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Kan Grubu',
                                  value: _bloodGroup,
                                  items: _bloodGroups,
                                  onChanged: (val) =>
                                      setState(() => _bloodGroup = val),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Group 2: İletişim & Hesap ---
            _buildSectionCard(
              title: 'İletişim ve Hesap Bilgileri',
              icon: Icons.contact_phone_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Telefon',
                        controller: _phoneController1,
                        hint: '(5XX) ...',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Telefon (2)',
                        controller: _phoneController2,
                        hint: '(000) ...',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'E-Posta',
                        controller: _emailController1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        label: 'E-Posta (2)',
                        controller: _emailController2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Adres',
                  controller: _addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Üye Numarası',
                        controller: _memberNoController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        label: 'Web Giriş Şifresi',
                        controller: _passwordController,
                        hint: '*****',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        label: 'Muhasebe Kodu',
                        controller: _accountingCodeController,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Group 3: Çalışma & Diğer ---
            _buildSectionCard(
              title: 'Çalışma ve Diğer Bilgiler',
              icon: Icons.work_outline,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Mesleği',
                        value: _profession,
                        items: _professions,
                        onChanged: (val) => setState(() => _profession = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        label: 'Çalıştığı İş Yeri Adı',
                        controller: _employerNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'İş Yeri Adresi',
                  controller: _employerAddressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Not',
                  controller: _notesController,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'Taşınmazdan Sil',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save),
                    label: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- TAB 2: Opening Figures ---

class _OpeningFiguresTab extends StatefulWidget {
  const _OpeningFiguresTab();

  @override
  State<_OpeningFiguresTab> createState() => _OpeningFiguresTabState();
}

class _OpeningFiguresTabState extends State<_OpeningFiguresTab> {
  bool _isCredit = true;
  final List<String> _debtTypes = [
    'Aidat',
    'Demirbaş',
    'Yakıt',
    'Avans',
    'Depozito',
    'Ek Gider',
    'İdari Ceza',
    'Kira',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          value: true,
                          groupValue: _isCredit,
                          onChanged: (val) => setState(() => _isCredit = val!),
                          title: const Text('Alacak Devir'),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          value: false,
                          groupValue: _isCredit,
                          onChanged: (val) => setState(() => _isCredit = val!),
                          title: const Text('Borç Devir'),
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (_isCredit)
                    _buildEntryRow('Alacak Devir', isCredit: true)
                  else
                    ..._debtTypes.map(
                      (type) => _buildEntryRow(type, isCredit: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow(String label, {required bool isCredit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tarih',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tutar',
                suffixText: '₺',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                color: isCredit ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TAB 3: Residents ---

class _ResidentsTab extends StatelessWidget {
  const _ResidentsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Center(
            child: Text(
              'Henüz sakin eklenmemiş.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- TAB 4: Vehicles ---

class _VehiclesTab extends StatelessWidget {
  const _VehiclesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.directions_car,
                color: AppColors.primary,
              ),
              title: const Text('34 ABC 123'),
              subtitle: const Text('Ford Focus - Beyaz'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- TAB 5: Files ---

class _FilesTab extends StatelessWidget {
  const _FilesTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file,
            size: 64,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dosya Yükle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () {}, child: const Text('Gözat')),
        ],
      ),
    );
  }
}

// --- Helpers ---

Widget _buildSectionCard({
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    ),
  );
}

Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  String? hint,
  int maxLines = 1,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          isDense: true,
        ),
      ),
    ],
  );
}

Widget _buildDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      const SizedBox(height: 4),
      Container(
        height: 36, // Fixed height for compact look
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value) ? value : null,
            isExpanded: true,
            isDense: true, // Added isDense
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}
