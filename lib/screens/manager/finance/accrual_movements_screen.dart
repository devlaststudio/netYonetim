import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class AccrualMovementsScreen extends StatefulWidget {
  const AccrualMovementsScreen({super.key});

  @override
  State<AccrualMovementsScreen> createState() => _AccrualMovementsScreenState();
}

class _AccrualMovementsScreenState extends State<AccrualMovementsScreen> {
  ChargeBatchStatus? _statusFilter;
  final Set<String> _selectedBatchIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.chargeBatches.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final list = provider.chargeBatches.where((batch) {
      if (_statusFilter == null) {
        return true;
      }
      return batch.status == _statusFilter;
    }).toList();

    return ManagerPageScaffold(
      title: 'Tahakkuk Hareketleri',
      actions: [
        IconButton(
          onPressed: list.isEmpty ? null : () => _runBulkCancel(context, list),
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Toplu Iptal',
        ),
      ],
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Filtre',
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tum Durumlar'),
                        selected: _statusFilter == null,
                        onSelected: (_) => setState(() => _statusFilter = null),
                      ),
                      ...ChargeBatchStatus.values.map(
                        (status) => ChoiceChip(
                          label: Text(status.label),
                          selected: _statusFilter == status,
                          onSelected: (_) =>
                              setState(() => _statusFilter = status),
                        ),
                      ),
                    ],
                  ),
                ),
                if (list.isEmpty)
                  const SizedBox(
                    height: 260,
                    child: ManagerEmptyState(
                      icon: Icons.filter_list_off,
                      title: 'Kayit bulunamadi',
                      subtitle: 'Secili filtreye uygun hareket yok.',
                    ),
                  )
                else
                  ...list.map(
                    (batch) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: CheckboxListTile(
                        value: _selectedBatchIds.contains(batch.id),
                        onChanged: (value) {
                          setState(() {
                            if (value ?? false) {
                              _selectedBatchIds.add(batch.id);
                            } else {
                              _selectedBatchIds.remove(batch.id);
                            }
                          });
                        },
                        title: Text(batch.title),
                        subtitle: Text(
                          '${batch.period} • ${batch.scope.label} • ${DateFormat('dd.MM.yyyy').format(batch.dueDate)}',
                        ),
                        secondary: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ManagerStatusChip(
                                label: batch.status.label,
                                color: batch.status.color),
                            const SizedBox(height: 6),
                            Text(formatCurrency(batch.totalAmount)),
                          ],
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ),
                if (_selectedBatchIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _bulkCancelSelected(context),
                            icon: const Icon(Icons.cancel_outlined),
                            label: Text(
                                'Secilenleri Iptal Et (${_selectedBatchIds.length})'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _bulkRegenerateSelected(context),
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Yeniden Uret'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _bulkCancelSelected(BuildContext context) async {
    final provider = context.read<ManagerFinanceProvider>();
    for (final id in _selectedBatchIds) {
      await provider.cancelChargeBatch(id);
    }
    setState(_selectedBatchIds.clear);
  }

  Future<void> _bulkRegenerateSelected(BuildContext context) async {
    final provider = context.read<ManagerFinanceProvider>();
    for (final id in _selectedBatchIds) {
      await provider.regenerateChargeBatch(id);
    }
    setState(_selectedBatchIds.clear);
  }

  Future<void> _runBulkCancel(
      BuildContext context, List<ChargeBatch> list) async {
    final provider = context.read<ManagerFinanceProvider>();
    for (final batch in list) {
      await provider.cancelChargeBatch(batch.id);
    }
  }
}
