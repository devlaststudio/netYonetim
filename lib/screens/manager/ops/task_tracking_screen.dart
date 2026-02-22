import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/dashboard_embed_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_ops_provider.dart';

class TaskTrackingScreen extends StatefulWidget {
  const TaskTrackingScreen({super.key});

  @override
  State<TaskTrackingScreen> createState() => _TaskTrackingScreenState();
}

class _TaskTrackingScreenState extends State<TaskTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerOpsProvider>();
    if (!provider.isLoading && provider.tasks.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerOpsProvider>();
    // Dashboard içine gömüldüğünde AppBar'ı gizle
    final isEmbedded = DashboardEmbedScope.hideBackButton(context);

    return Scaffold(
      appBar: isEmbedded
          ? null
          : AppBar(
              title: const Text('Is Takibi ve Arama Notlari'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Gorevler'),
                  Tab(text: 'Arama Notlari'),
                ],
              ),
            ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showCreateTaskDialog(context);
          } else {
            _showCreateCallLogDialog(context);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Kayit'),
      ),
      body: Column(
        children: [
          // Dashboard'da gömülüyken TabBar'ı ayrı göster
          if (isEmbedded)
            Material(
              color: AppColors.surface,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Gorevler'),
                  Tab(text: 'Arama Notlari'),
                ],
              ),
            ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: provider.tasks
                            .map(
                              (task) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  title: Text(task.title),
                                  subtitle: Text(
                                    '${task.assignedStaffName} • ${task.priority.label} • Son: ${DateFormat('dd.MM.yyyy').format(task.dueDate)}',
                                  ),
                                  trailing: DropdownButton<TaskStatus>(
                                    value: task.status,
                                    underline: const SizedBox.shrink(),
                                    items: TaskStatus.values
                                        .map(
                                          (status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status.label),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      provider.updateTaskStatus(task.id, value);
                                    },
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: provider.callLogs
                            .map(
                              (log) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFE9F0FF),
                                    child: Icon(
                                      Icons.call,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: Text(log.memberName),
                                  subtitle: Text(
                                    '${log.staffName} • ${DateFormat('dd.MM.yyyy HH:mm').format(log.callDate)}\n${log.note}',
                                  ),
                                  isThreeLine: true,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    StaffRoleRecord selectedAssignee = context
        .read<ManagerOpsProvider>()
        .staffRoles
        .first;
    DateTime dueDate = DateTime.now().add(const Duration(days: 2));

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Yeni Gorev'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Gorev Basligi',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<StaffRoleRecord>(
                      initialValue: selectedAssignee,
                      decoration: const InputDecoration(
                        labelText: 'Atanan Personel',
                      ),
                      items: context
                          .read<ManagerOpsProvider>()
                          .staffRoles
                          .map(
                            (staff) => DropdownMenuItem(
                              value: staff,
                              child: Text(staff.fullName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedAssignee = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Oncelik'),
                      items: TaskPriority.values
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedPriority = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Termin: ${DateFormat('dd.MM.yyyy').format(dueDate)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => dueDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Not'),
                      maxLines: 2,
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
                    if (titleController.text.isEmpty) return;

                    await context.read<ManagerOpsProvider>().createTask(
                      title: titleController.text,
                      assignee: selectedAssignee,
                      priority: selectedPriority,
                      dueDate: dueDate,
                      notes: noteController.text,
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

  void _showCreateCallLogDialog(BuildContext context) {
    final memberController = TextEditingController();
    final staffController = TextEditingController();
    final noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Arama Notu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: memberController,
                  decoration: const InputDecoration(labelText: 'Uye Adi'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: staffController,
                  decoration: const InputDecoration(
                    labelText: 'Gorusmeyi Yapan',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Not'),
                  maxLines: 3,
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
                if (memberController.text.isEmpty ||
                    staffController.text.isEmpty) {
                  return;
                }

                await context.read<ManagerOpsProvider>().addCallLog(
                  memberName: memberController.text,
                  staffName: staffController.text,
                  note: noteController.text,
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
