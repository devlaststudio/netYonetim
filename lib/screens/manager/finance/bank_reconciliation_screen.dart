import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class BankReconciliationScreen extends StatefulWidget {
  const BankReconciliationScreen({super.key});

  @override
  State<BankReconciliationScreen> createState() =>
      _BankReconciliationScreenState();
}

class _BankReconciliationScreenState extends State<BankReconciliationScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.bankMovements.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();

    return ManagerPageScaffold(
      title: 'Banka Eslestirme',
      actions: [
        IconButton(
          onPressed: () => _showRuleDialog(context),
          icon: const Icon(Icons.rule_folder_outlined),
          tooltip: 'Kural Ekle',
        ),
      ],
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Eslestirme Ozeti',
                  child: ManagerKpiGrid(
                    items: [
                      ManagerKpiItem(
                        label: 'Toplam Hareket',
                        value: '${provider.bankMovements.length}',
                        color: AppColors.primary,
                      ),
                      ManagerKpiItem(
                        label: 'Eslesti',
                        value:
                            '${provider.bankMovements.where((e) => e.matchedStatus == MatchStatus.matched).length}',
                        color: AppColors.success,
                      ),
                      ManagerKpiItem(
                        label: 'Tanimsiz',
                        value:
                            '${provider.bankMovements.where((e) => e.matchedStatus == MatchStatus.unmatched).length}',
                        color: AppColors.warning,
                      ),
                      ManagerKpiItem(
                        label: 'Kural Sayisi',
                        value: '${provider.reconciliationRules.length}',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
                ManagerSectionCard(
                  title: 'Aktif Kurallar',
                  child: Column(
                    children: provider.reconciliationRules
                        .map(
                          (rule) => ListTile(
                            dense: true,
                            title: Text(rule.name),
                            subtitle: Text('Anahtar: ${rule.keyword}'),
                            trailing: Icon(
                              rule.isActive
                                  ? Icons.check_circle
                                  : Icons.pause_circle,
                              color: rule.isActive
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),
                ...provider.bankMovements.map(
                  (movement) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: movement.matchedStatus.color
                            .withValues(alpha: 0.12),
                        child: Icon(
                          movement.direction == MovementDirection.incoming
                              ? Icons.south_west
                              : Icons.north_east,
                          color: movement.matchedStatus.color,
                        ),
                      ),
                      title: Text(movement.bankAccountName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movement.description),
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm')
                                .format(movement.txnDate),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ManagerStatusChip(
                            label: movement.matchedStatus.label,
                            color: movement.matchedStatus.color,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatCurrency(movement.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: movement.direction ==
                                      MovementDirection.incoming
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _showMatchDialog(context, movement),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showMatchDialog(BuildContext context, BankMovement movement) {
    final referenceController = TextEditingController(
      text: movement.matchedRef ?? 'Tahsilat / Cari Secimi',
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hareket Eslestirme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(movement.description),
              const SizedBox(height: 8),
              TextField(
                controller: referenceController,
                decoration: const InputDecoration(labelText: 'Referans'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await context
                    .read<ManagerFinanceProvider>()
                    .ignoreBankMovement(movement.id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Yoksay'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context
                    .read<ManagerFinanceProvider>()
                    .matchBankMovement(movement.id, referenceController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Eslestir'),
            ),
          ],
        );
      },
    );
  }

  void _showRuleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final keywordController = TextEditingController();
    final defaultRefController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Eslestirme Kurali'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Kural Adi'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: keywordController,
                  decoration:
                      const InputDecoration(labelText: 'Anahtar Kelime'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: defaultRefController,
                  decoration:
                      const InputDecoration(labelText: 'Varsayilan Referans'),
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
                if (nameController.text.isEmpty ||
                    keywordController.text.isEmpty) {
                  return;
                }

                await context
                    .read<ManagerFinanceProvider>()
                    .addReconciliationRule(
                      name: nameController.text,
                      keyword: keywordController.text,
                      defaultRef: defaultRefController.text,
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
