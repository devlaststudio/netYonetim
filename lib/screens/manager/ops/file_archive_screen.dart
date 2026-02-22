import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/providers/manager_ops_provider.dart';
import '../shared/manager_common_widgets.dart';

class FileArchiveScreen extends StatefulWidget {
  const FileArchiveScreen({super.key});

  @override
  State<FileArchiveScreen> createState() => _FileArchiveScreenState();
}

class _FileArchiveScreenState extends State<FileArchiveScreen> {
  String _folderFilter = 'Tum Klasorler';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerOpsProvider>();
    if (!provider.isLoading && provider.files.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerOpsProvider>();
    final folders = {
      'Tum Klasorler',
      ...provider.files.map((file) => file.folder),
    }.toList();

    final files = provider.files.where((file) {
      if (_folderFilter == 'Tum Klasorler') {
        return true;
      }
      return file.folder == _folderFilter;
    }).toList();

    return ManagerPageScaffold(
      title: 'Dosya Arsivi',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.upload_file),
        label: const Text('Dosya Ekle'),
      ),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Klasor Filtresi',
                  child: DropdownButtonFormField<String>(
                    initialValue: _folderFilter,
                    items: folders
                        .map(
                          (folder) => DropdownMenuItem(
                            value: folder,
                            child: Text(folder),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _folderFilter = value ?? 'Tum Klasorler');
                    },
                  ),
                ),
                if (files.isEmpty)
                  const SizedBox(
                    height: 260,
                    child: ManagerEmptyState(
                      icon: Icons.folder_open,
                      title: 'Dosya bulunamadi',
                      subtitle: 'Secili klasorde dosya yok.',
                    ),
                  )
                else
                  ...files.map(
                    (file) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE9F0FF),
                          child: Icon(Icons.insert_drive_file,
                              color: AppColors.primary),
                        ),
                        title: Text(file.name),
                        subtitle: Text(
                          '${file.folder} • ${DateFormat('dd.MM.yyyy').format(file.uploadedAt)} • ${file.uploadedBy}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('${file.name} indirildi (mock).')),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    String folder = 'Raporlar';

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Dosya Yukle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Dosya Adi'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: folder,
                    items: const [
                      DropdownMenuItem(
                          value: 'Raporlar', child: Text('Raporlar')),
                      DropdownMenuItem(
                          value: 'Karar Defteri', child: Text('Karar Defteri')),
                      DropdownMenuItem(
                          value: 'Faturalar', child: Text('Faturalar')),
                      DropdownMenuItem(
                          value: 'Sozlesmeler', child: Text('Sozlesmeler')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => folder = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Iptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      return;
                    }

                    await context.read<ManagerOpsProvider>().addFile(
                          name: nameController.text,
                          folder: folder,
                          uploadedBy: 'Yonetici',
                        );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
