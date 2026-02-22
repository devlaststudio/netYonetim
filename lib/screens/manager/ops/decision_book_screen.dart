import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/providers/manager_ops_provider.dart';
import '../shared/manager_common_widgets.dart';

class DecisionBookScreen extends StatefulWidget {
  const DecisionBookScreen({super.key});

  @override
  State<DecisionBookScreen> createState() => _DecisionBookScreenState();
}

class _DecisionBookScreenState extends State<DecisionBookScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerOpsProvider>();
    if (!provider.isLoading && provider.decisions.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerOpsProvider>();

    return ManagerPageScaffold(
      title: 'Karar Defteri',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.gavel),
        label: const Text('Karar Ekle'),
      ),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: provider.decisions
                  .map(
                    (decision) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF7E8),
                          child: Icon(Icons.gavel, color: AppColors.warning),
                        ),
                        title: Text(decision.title),
                        subtitle: Text(
                          '${decision.decisionNo} • ${DateFormat('dd.MM.yyyy').format(decision.meetingDate)}\n${decision.summary}',
                        ),
                        isThreeLine: true,
                        trailing: Text('${decision.attachmentIds.length} ek'),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final noController = TextEditingController();
    final summaryController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Karar Kaydi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Baslik'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noController,
                  decoration: const InputDecoration(labelText: 'Karar No'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: summaryController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Ozet'),
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
                if (titleController.text.isEmpty || noController.text.isEmpty) {
                  return;
                }

                await context.read<ManagerOpsProvider>().addDecision(
                      title: titleController.text,
                      decisionNo: noController.text,
                      summary: summaryController.text,
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
