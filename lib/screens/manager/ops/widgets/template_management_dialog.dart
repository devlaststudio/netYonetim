import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TemplateModel {
  String id;
  String title;
  String subtitle;
  String channel; // 'SMS', 'E-Posta', 'WhatsApp'
  String content;
  IconData icon;
  Color color;

  TemplateModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.channel,
    required this.content,
    required this.icon,
    required this.color,
  });
}

class TemplateManagementDialog extends StatefulWidget {
  const TemplateManagementDialog({super.key});

  @override
  State<TemplateManagementDialog> createState() =>
      _TemplateManagementDialogState();
}

class _TemplateManagementDialogState extends State<TemplateManagementDialog> {
  bool _isAddingNew = false;
  TemplateModel? _editingTemplate;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedChannel = 'SMS';

  // Mock list of templates
  final List<TemplateModel> _templates = [
    TemplateModel(
      id: '1',
      title: 'Borç Bildirimi',
      subtitle: 'Aidat ve ek ödemeler',
      channel: 'SMS',
      content:
          'Sayın [Sakin Adı],\n\n[Blok-Daire] nolu bağımsız bölümünüze ait [Tutar] TL tutarında vadesi geçmiş aidat borcunuz bulunmaktadır.\n\nSite Yönetimi',
      icon: Icons.account_balance_wallet,
      color: AppColors.primary,
    ),
    TemplateModel(
      id: '2',
      title: 'Genel Duyuru',
      subtitle: 'Bakım, kesinti vb.',
      channel: 'E-Posta',
      content:
          'Değerli Sakinimiz,\n\nYarın 10:00 - 12:00 saatleri arasında su kesintisi yaşanacaktır.\n\nİyi günler.',
      icon: Icons.campaign,
      color: AppColors.warning,
    ),
    TemplateModel(
      id: '3',
      title: 'Özel Gün',
      subtitle: 'Kutlama mesajları',
      channel: 'SMS',
      content:
          'Yeni yılınızı en içten dileklerimizle kutlar, sağlık ve mutluluk dolu güzel günler dileriz.\n\nSite Yönetimi',
      icon: Icons.celebration,
      color: AppColors.secondary,
    ),
    TemplateModel(
      id: '4',
      title: 'Toplantı Çağrısı',
      subtitle: 'Genel kurul daveti',
      channel: 'E-Posta',
      content:
          'Değerli Kat Malikimiz,\n\nOlağan Genel Kurul toplantımız [Tarih] günü saat [Saat]\'te yapılacaktır. Katılımınız önemlidir.\n\nYönetim',
      icon: Icons.groups,
      color: Colors.blue,
    ),
    TemplateModel(
      id: '5',
      title: 'İcra Bildirimi',
      subtitle: 'Yasal süreç başlatma',
      channel: 'SMS',
      content:
          'Sayın [Sakin Adı], borcunuz yasal işlem sürecine aktarılacaktır. Lütfen ödemenizi gerçekleştiriniz.',
      icon: Icons.gavel,
      color: AppColors.error,
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _openForm([TemplateModel? template]) {
    setState(() {
      _isAddingNew = true;
      _editingTemplate = template;
      if (template != null) {
        _titleController.text = template.title;
        _subtitleController.text = template.subtitle;
        _contentController.text = template.content;
        _selectedChannel = template.channel;
      } else {
        _titleController.clear();
        _subtitleController.clear();
        _contentController.clear();
        _selectedChannel = 'SMS';
      }
    });
  }

  void _closeForm() {
    setState(() {
      _isAddingNew = false;
      _editingTemplate = null;
    });
  }

  void _saveTemplate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (_editingTemplate != null) {
          // Update existing
          _editingTemplate!.title = _titleController.text;
          _editingTemplate!.subtitle = _subtitleController.text;
          _editingTemplate!.content = _contentController.text;
          _editingTemplate!.channel = _selectedChannel;
        } else {
          // Add new
          _templates.add(
            TemplateModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              subtitle: _subtitleController.text,
              content: _contentController.text,
              channel: _selectedChannel,
              icon: Icons.message, // Default icon
              color: AppColors.primary,
            ),
          );
        }
        _isAddingNew = false;
        _editingTemplate = null;
      });
    }
  }

  void _deleteTemplate(TemplateModel template) {
    setState(() {
      _templates.remove(template);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isAddingNew
                      ? (_editingTemplate != null
                            ? 'Şablonu Düzenle'
                            : 'Yeni Şablon Ekle')
                      : 'Hızlı Şablon Yönetimi',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (_isAddingNew) {
                      _closeForm();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 32),

            // Content
            Expanded(child: _isAddingNew ? _buildForm() : _buildTemplateList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList() {
    return Column(
      children: [
        // Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Yeni Şablon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // List
        Expanded(
          child: ListView.builder(
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final t = _templates[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: t.color.withValues(alpha: 0.1),
                    child: Icon(t.icon, color: t.color),
                  ),
                  title: Text(
                    t.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${t.channel} • ${t.subtitle}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _openForm(t),
                        tooltip: 'Düzenle',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _deleteTemplate(t),
                        tooltip: 'Sil',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          // Title
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Şablon Adı',
              hintText: 'Örn: Borç Bildirimi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Gerekli alan' : null,
          ),
          const SizedBox(height: 16),

          // Subtitle
          TextFormField(
            controller: _subtitleController,
            decoration: InputDecoration(
              labelText: 'Kısa Açıklama',
              hintText: 'Örn: Aidat ve ek ödemeler',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Gerekli alan' : null,
          ),
          const SizedBox(height: 16),

          // Channel Dropdown
          DropdownButtonFormField<String>(
            value: _selectedChannel,
            decoration: InputDecoration(
              labelText: 'İletişim Kanalı',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: ['SMS', 'E-Posta', 'WhatsApp'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) {
              setState(() {
                if (val != null) _selectedChannel = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Content Box
          TextFormField(
            controller: _contentController,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Mesaj İçeriği',
              hintText: 'Mesajınızı buraya yazın...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Gerekli alan' : null,
          ),
          const SizedBox(height: 16),

          // Variables Hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanılabilir Değişkenler:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  '[Sakin Adı], [Blok-Daire], [Tutar], [Tarih]',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _closeForm, child: const Text('İptal')),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveTemplate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
