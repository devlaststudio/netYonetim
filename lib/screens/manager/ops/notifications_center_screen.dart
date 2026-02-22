import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_ops_provider.dart';
import '../shared/manager_common_widgets.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  String _targetFilter = 'Borclu Uyeler';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerOpsProvider>();
    if (!provider.isLoading && provider.templates.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerOpsProvider>();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return ManagerPageScaffold(
      title: 'Toplu Bildirim Merkezi',
      actions: [
        IconButton(
          onPressed: () => _showCreateTemplateDialog(context),
          icon: const Icon(Icons.add_alert),
          tooltip: 'Sablon Ekle',
        ),
        IconButton(
          onPressed: () => _showCreateAutoRuleDialog(context),
          icon: const Icon(Icons.schedule),
          tooltip: 'Otomatik Kural Ekle',
        ),
      ],
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Hedef Filtre',
                  child: DropdownButtonFormField<String>(
                    initialValue: _targetFilter,
                    decoration: const InputDecoration(labelText: 'Hedef Grup'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Borclu Uyeler', child: Text('Borclu Uyeler')),
                      DropdownMenuItem(
                          value: 'Tum Uyeler', child: Text('Tum Uyeler')),
                      DropdownMenuItem(value: 'A Blok', child: Text('A Blok')),
                      DropdownMenuItem(
                          value: 'Kiracilar', child: Text('Kiracilar')),
                    ],
                    onChanged: (value) => setState(
                        () => _targetFilter = value ?? 'Borclu Uyeler'),
                  ),
                ),
                ManagerSectionCard(
                  title: 'Otomatik Bildirim Kurallari',
                  child: provider.autoNotificationRules.isEmpty
                      ? const ManagerEmptyState(
                          icon: Icons.schedule_send_outlined,
                          title: 'Kural bulunamadi',
                          subtitle:
                              'Yeni bir otomatik bildirim kurali ekleyin.',
                        )
                      : Column(
                          children: provider.autoNotificationRules
                              .map(
                                (rule) => ListTile(
                                  dense: true,
                                  leading: Icon(
                                    rule.isActive
                                        ? Icons.notifications_active_outlined
                                        : Icons.notifications_off_outlined,
                                    color: rule.isActive
                                        ? Colors.green
                                        : AppColors.textSecondary,
                                  ),
                                  title: Text(rule.name),
                                  subtitle: Text(
                                    '${rule.channel.label} • ${rule.templateName}\n${rule.targetFilter} • Sonraki: ${DateFormat('dd.MM.yyyy').format(rule.nextRunAt)}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Simdi Calistir',
                                        onPressed: rule.isActive
                                            ? () => context
                                                .read<ManagerOpsProvider>()
                                                .runAutoNotificationRuleNow(
                                                  rule.id,
                                                )
                                            : null,
                                        icon: const Icon(Icons.play_arrow),
                                      ),
                                      Switch(
                                        value: rule.isActive,
                                        onChanged: (value) => context
                                            .read<ManagerOpsProvider>()
                                            .toggleAutoNotificationRule(
                                              rule.id,
                                              value,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                ManagerSectionCard(
                  title: 'Bildirim Sablonlari',
                  child: Column(
                    children: provider.templates
                        .map(
                          (template) => ListTile(
                            dense: true,
                            title: Text(template.name),
                            subtitle: Text(
                                '${template.channel.label} • ${template.title}'),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await provider.sendNotification(
                                  template: template,
                                  targetFilter: _targetFilter,
                                  targetCount:
                                      _targetFilter == 'Tum Uyeler' ? 180 : 96,
                                );
                              },
                              child: const Text('Gonder'),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                ManagerSectionCard(
                  title: 'Gonderim Loglari',
                  child: provider.dispatches.isEmpty
                      ? const ManagerEmptyState(
                          icon: Icons.send_outlined,
                          title: 'Log yok',
                          subtitle: 'Gonderilen bildirimler burada gorunur.',
                        )
                      : Column(
                          children: provider.dispatches
                              .map(
                                (dispatch) => ListTile(
                                  dense: true,
                                  title: Text(dispatch.templateName),
                                  subtitle: Text(
                                    '${dispatch.targetFilter} • ${dateFormat.format(dispatch.createdAt)}',
                                  ),
                                  trailing: Text(
                                    '${dispatch.sentCount}/${dispatch.targetCount}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    NotificationChannel selectedChannel = NotificationChannel.whatsapp;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Yeni Bildirim Sablonu'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Sablon Adi'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<NotificationChannel>(
                      initialValue: selectedChannel,
                      decoration: const InputDecoration(labelText: 'Kanal'),
                      items: NotificationChannel.values
                          .map(
                            (channel) => DropdownMenuItem(
                              value: channel,
                              child: Text(channel.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedChannel = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Baslik'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bodyController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Icerik'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Vazgec'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        bodyController.text.isEmpty) {
                      return;
                    }
                    await context
                        .read<ManagerOpsProvider>()
                        .addNotificationTemplate(
                          name: nameController.text,
                          channel: selectedChannel,
                          title: titleController.text.isEmpty
                              ? nameController.text
                              : titleController.text,
                          body: bodyController.text,
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

  void _showCreateAutoRuleDialog(BuildContext context) {
    final provider = context.read<ManagerOpsProvider>();
    if (provider.templates.isEmpty) {
      return;
    }

    final nameController = TextEditingController();
    NotificationTemplate selectedTemplate = provider.templates.first;
    String selectedTarget = 'Borclu Uyeler';
    SchedulerFrequency selectedFrequency = SchedulerFrequency.weekly;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Otomatik Bildirim Kurali'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Kural Adi'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<NotificationTemplate>(
                      initialValue: selectedTemplate,
                      decoration: const InputDecoration(labelText: 'Sablon'),
                      items: provider.templates
                          .map(
                            (template) => DropdownMenuItem(
                              value: template,
                              child: Text(
                                '${template.name} (${template.channel.label})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedTemplate = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedTarget,
                      decoration:
                          const InputDecoration(labelText: 'Hedef Filtre'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Borclu Uyeler',
                            child: Text('Borclu Uyeler')),
                        DropdownMenuItem(
                            value: 'Tum Uyeler', child: Text('Tum Uyeler')),
                        DropdownMenuItem(
                            value: 'A Blok', child: Text('A Blok')),
                        DropdownMenuItem(
                            value: 'Kiracilar', child: Text('Kiracilar')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedTarget = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<SchedulerFrequency>(
                      initialValue: selectedFrequency,
                      decoration: const InputDecoration(labelText: 'Siklik'),
                      items: SchedulerFrequency.values
                          .map(
                            (frequency) => DropdownMenuItem(
                              value: frequency,
                              child: Text(frequency.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedFrequency = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Vazgec'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await context
                        .read<ManagerOpsProvider>()
                        .addAutoNotificationRule(
                          name: nameController.text.isEmpty
                              ? 'Otomatik Bildirim'
                              : nameController.text,
                          template: selectedTemplate,
                          targetFilter: selectedTarget,
                          frequency: selectedFrequency,
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
