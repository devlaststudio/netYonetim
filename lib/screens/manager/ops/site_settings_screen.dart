import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_ops_provider.dart';
import '../shared/manager_common_widgets.dart';

class SiteSettingsScreen extends StatefulWidget {
  const SiteSettingsScreen({super.key});

  @override
  State<SiteSettingsScreen> createState() => _SiteSettingsScreenState();
}

class _SiteSettingsScreenState extends State<SiteSettingsScreen> {
  bool _includeWarnings = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerOpsProvider>();
    if (!provider.isLoading && provider.unitGroups.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerOpsProvider>();

    return ManagerPageScaffold(
      title: 'Site Ayarlari',
      actions: [
        IconButton(
          onPressed: () => _showCreateGroupDialog(context),
          icon: const Icon(Icons.group_add_outlined),
          tooltip: 'Daire Grubu Ekle',
        ),
      ],
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Daire Gruplari',
                  child: Column(
                    children: provider.unitGroups
                        .map(
                          (group) => ListTile(
                            dense: true,
                            title: Text(group.name),
                            trailing: Text('${group.unitCount} daire'),
                          ),
                        )
                        .toList(),
                  ),
                ),
                ManagerSectionCard(
                  title: 'Eski Uye Gorunumu',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.history_outlined),
                    ),
                    title: const Text('Eski malik/kiraci kayitlarini incele'),
                    subtitle: Text(
                      '${provider.legacyMembers.length} kayit listelenmeye hazir.',
                    ),
                    trailing: OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/manager/legacy-members'),
                      child: const Text('Ac'),
                    ),
                  ),
                ),
                ManagerSectionCard(
                  title: 'Toplu Uye / Daire Aktarimi',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Excel sihirbazi mock akisi: dosya secimi, onizleme, satir bazli hata kontrolu ve aktarim.',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Ornek sablon indirildi (mock).'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Sablon Indir'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await context
                                    .read<ManagerOpsProvider>()
                                    .prepareImportPreview(
                                      sourceName: 'uye_daire_import_2026.xlsx',
                                    );
                              },
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Onizleme Yukle'),
                            ),
                          ),
                        ],
                      ),
                      if (provider.importPreviewRows.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Dosya: ${provider.importSourceName ?? '-'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ManagerStatusChip(
                              label: 'Gecerli: ${provider.importValidCount}',
                              color: ImportRowStatus.valid.color,
                            ),
                            ManagerStatusChip(
                              label: 'Uyarili: ${provider.importWarningCount}',
                              color: ImportRowStatus.warning.color,
                            ),
                            ManagerStatusChip(
                              label: 'Hatali: ${provider.importErrorCount}',
                              color: ImportRowStatus.error.color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Uyarili satirlari da aktar'),
                          subtitle: const Text(
                            'Kapaliysa sadece gecerli satirlar import edilir.',
                          ),
                          value: _includeWarnings,
                          onChanged: (value) {
                            setState(() => _includeWarnings = value);
                          },
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Satir')),
                              DataColumn(label: Text('Blok')),
                              DataColumn(label: Text('Daire')),
                              DataColumn(label: Text('Malik')),
                              DataColumn(label: Text('Kiraci')),
                              DataColumn(label: Text('m2')),
                              DataColumn(label: Text('Durum')),
                              DataColumn(label: Text('Hata / Uyari')),
                              DataColumn(label: Text('Islem')),
                            ],
                            rows: provider.importPreviewRows
                                .map(
                                  (row) => DataRow(
                                    cells: [
                                      DataCell(Text('${row.rowNumber}')),
                                      DataCell(Text(row.block)),
                                      DataCell(Text(row.unitNo.isEmpty
                                          ? '-'
                                          : row.unitNo)),
                                      DataCell(Text(row.ownerName.isEmpty
                                          ? '-'
                                          : row.ownerName)),
                                      DataCell(Text(row.tenantName ?? '-')),
                                      DataCell(Text(row.sqm == 0
                                          ? '-'
                                          : row.sqm.toStringAsFixed(0))),
                                      DataCell(
                                        ManagerStatusChip(
                                          label: row.status.label,
                                          color: row.status.color,
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 220,
                                          child: Text(
                                            row.issues.isEmpty
                                                ? '-'
                                                : row.issues.join(' | '),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          tooltip: 'Satiri Duzenle',
                                          onPressed: () =>
                                              _showEditImportRowDialog(
                                                  context, row),
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context
                                      .read<ManagerOpsProvider>()
                                      .revalidateImportPreviewRows();
                                },
                                icon: const Icon(Icons.rule_folder_outlined),
                                label: const Text('Yeniden Kontrol Et'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context
                                      .read<ManagerOpsProvider>()
                                      .clearImportPreview();
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Temizle'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final summary = await context
                                      .read<ManagerOpsProvider>()
                                      .applyImportPreview(
                                        includeWarnings: _includeWarnings,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Aktarim tamamlandi: ${summary.inserted} eklendi, ${summary.updated} guncellendi, ${summary.skipped} atlandi, ${summary.errors} hata.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.playlist_add_check),
                                label: const Text('Aktarimi Tamamla'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                ManagerSectionCard(
                  title: 'Demirbas Kayitlari',
                  trailing: TextButton(
                    onPressed: () => _showAssetDialog(context),
                    child: const Text('Yeni Demirbas'),
                  ),
                  child: Column(
                    children: provider.assets
                        .map(
                          (asset) => ListTile(
                            dense: true,
                            title: Text(asset.name),
                            subtitle:
                                Text('${asset.category} • ${asset.location}'),
                            trailing: Text(asset.status),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final countController = TextEditingController(text: '10');

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Daire Grubu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Grup Adi'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: countController,
                decoration: const InputDecoration(labelText: 'Daire Sayisi'),
                keyboardType: TextInputType.number,
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
                final count = int.tryParse(countController.text);
                if (nameController.text.isEmpty || count == null) return;

                await context
                    .read<ManagerOpsProvider>()
                    .addUnitGroup(name: nameController.text, unitCount: count);

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
  }

  void _showAssetDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: 'Asansor');
    final locationController = TextEditingController(text: 'A Blok');

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Demirbas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Demirbas Adi'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Konum'),
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
                if (nameController.text.isEmpty) return;

                await context.read<ManagerOpsProvider>().addAsset(
                      name: nameController.text,
                      category: categoryController.text,
                      location: locationController.text,
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
  }

  void _showEditImportRowDialog(BuildContext context, ImportPreviewRow row) {
    final blockController = TextEditingController(text: row.block);
    final unitController = TextEditingController(text: row.unitNo);
    final ownerController = TextEditingController(text: row.ownerName);
    final tenantController = TextEditingController(text: row.tenantName ?? '');
    final sqmController = TextEditingController(
      text: row.sqm == 0 ? '' : row.sqm.toStringAsFixed(0),
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Satir ${row.rowNumber} Duzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: blockController,
                  decoration: const InputDecoration(labelText: 'Blok'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Daire No'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: ownerController,
                  decoration: const InputDecoration(labelText: 'Malik'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tenantController,
                  decoration: const InputDecoration(labelText: 'Kiraci'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sqmController,
                  decoration: const InputDecoration(labelText: 'm2'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Iptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final sqmValue = double.tryParse(sqmController.text) ?? 0;
                await context.read<ManagerOpsProvider>().updateImportPreviewRow(
                      rowNumber: row.rowNumber,
                      block: blockController.text,
                      unitNo: unitController.text,
                      ownerName: ownerController.text,
                      tenantName: tenantController.text,
                      sqm: sqmValue,
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
  }
}
