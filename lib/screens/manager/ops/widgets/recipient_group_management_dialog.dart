import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RecipientGroupModel {
  String id;
  String name;
  String description;
  int memberCount;

  RecipientGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
  });
}

class RecipientGroupManagementDialog extends StatefulWidget {
  const RecipientGroupManagementDialog({super.key});

  @override
  State<RecipientGroupManagementDialog> createState() =>
      _RecipientGroupManagementDialogState();
}

class _RecipientGroupManagementDialogState
    extends State<RecipientGroupManagementDialog> {
  bool _isAddingNew = false;
  RecipientGroupModel? _editingGroup;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  final List<RecipientGroupModel> _groups = [
    RecipientGroupModel(
      id: '1',
      name: 'Aktif Malikler',
      description: 'Tapu sahibi sakinler',
      memberCount: 124,
    ),
    RecipientGroupModel(
      id: '2',
      name: 'Kiracılar',
      description: 'Aktif ikamet edenler',
      memberCount: 86,
    ),
    RecipientGroupModel(
      id: '3',
      name: 'Borçlu Sakinler',
      description: 'Ödemesi gecikenler',
      memberCount: 42,
    ),
    RecipientGroupModel(
      id: '4',
      name: 'Yönetim Kurulu',
      description: 'Site yönetim kurulu üyeleri',
      memberCount: 5,
    ),
    RecipientGroupModel(
      id: '5',
      name: 'Tüm Sakinler',
      description: 'Sitede yaşayan herkes',
      memberCount: 210,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _openForm([RecipientGroupModel? group]) {
    setState(() {
      _isAddingNew = true;
      _editingGroup = group;
      if (group != null) {
        _nameController.text = group.name;
        _descController.text = group.description;
      } else {
        _nameController.clear();
        _descController.clear();
      }
    });
  }

  void _closeForm() {
    setState(() {
      _isAddingNew = false;
      _editingGroup = null;
    });
  }

  void _saveGroup() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (_editingGroup != null) {
          _editingGroup!.name = _nameController.text;
          _editingGroup!.description = _descController.text;
        } else {
          _groups.add(
            RecipientGroupModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text,
              description: _descController.text,
              memberCount: 0,
            ),
          );
        }
        _isAddingNew = false;
        _editingGroup = null;
      });
    }
  }

  void _deleteGroup(RecipientGroupModel group) {
    setState(() {
      _groups.remove(group);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isAddingNew
                      ? (_editingGroup != null
                            ? 'Grubu Düzenle'
                            : 'Yeni Grup Oluştur')
                      : 'Alıcı Grubu Yönetimi',
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
            Expanded(child: _isAddingNew ? _buildForm() : _buildGroupList()),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Yeni Grup Oluştur'),
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
        Expanded(
          child: ListView.builder(
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              final g = _groups[index];
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
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.group, color: AppColors.primary),
                  ),
                  title: Text(
                    g.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${g.memberCount} Kişi • ${g.description}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _openForm(g),
                        tooltip: 'Düzenle',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _deleteGroup(g),
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
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Grup Adı',
              hintText: 'Örn: Aidat Ödemeyenler',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Gerekli alan' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Grup Açıklaması',
              hintText: 'Grubun amacını kısaca yazınız...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Gerekli alan' : null,
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Yeni oluşturulan gruplara kişileri sağ taraftaki "Alıcı Listesi" tablosundan filtreleyerek de ekleyebilirsiniz.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _closeForm, child: const Text('İptal')),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveGroup,
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
