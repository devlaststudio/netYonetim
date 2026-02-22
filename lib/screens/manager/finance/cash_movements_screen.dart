import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_finance_provider.dart';
import '../shared/manager_common_widgets.dart';

class CashMovementsScreen extends StatefulWidget {
  const CashMovementsScreen({super.key});

  @override
  State<CashMovementsScreen> createState() => _CashMovementsScreenState();
}

class _CashMovementsScreenState extends State<CashMovementsScreen> {
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerFinanceProvider>();
    if (!provider.isLoading && provider.cashMovements.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerFinanceProvider>();
    final list = provider.cashMovements.where((movement) {
      if (_query.isEmpty) {
        return true;
      }
      return movement.description
              .toLowerCase()
              .contains(_query.toLowerCase()) ||
          movement.accountName.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return ManagerPageScaffold(
      title: 'Detayli Kasa Hareketleri',
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Filtre',
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Aciklama veya hesap ara',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                if (list.isEmpty)
                  const SizedBox(
                    height: 260,
                    child: ManagerEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Hareket bulunamadi',
                      subtitle: 'Filtreyi temizleyip tekrar deneyin.',
                    ),
                  )
                else
                  ...list.map(
                    (movement) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor:
                              movement.direction == MovementDirection.incoming
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : AppColors.error.withValues(alpha: 0.12),
                          child: Icon(
                            movement.direction == MovementDirection.incoming
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color:
                                movement.direction == MovementDirection.incoming
                                    ? AppColors.success
                                    : AppColors.error,
                          ),
                        ),
                        title: Text(movement.description),
                        subtitle: Text(
                          '${movement.accountName} • ${movement.sourceType} • ${DateFormat('dd.MM.yyyy HH:mm').format(movement.date)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
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
                            if (movement.isCancelled)
                              const Text(
                                'Iptal',
                                style: TextStyle(
                                    color: AppColors.error, fontSize: 12),
                              ),
                          ],
                        ),
                        onTap: () => _showMovementDetail(context, movement),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showMovementDetail(BuildContext context, CashMovementRecord movement) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hareket Detayi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kaynak: ${movement.sourceType} / ${movement.sourceId}'),
              const SizedBox(height: 6),
              Text('Hesap: ${movement.accountName}'),
              const SizedBox(height: 6),
              Text('Aciklama: ${movement.description}'),
              const SizedBox(height: 6),
              Text('Tutar: ${formatCurrency(movement.amount)}'),
              const SizedBox(height: 6),
              Text('Durum: ${movement.isCancelled ? 'Iptal' : 'Aktif'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
            if (!movement.isCancelled)
              ElevatedButton(
                onPressed: () async {
                  await context
                      .read<ManagerFinanceProvider>()
                      .cancelCashMovement(movement.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Iptal Et'),
              ),
          ],
        );
      },
    );
  }
}
