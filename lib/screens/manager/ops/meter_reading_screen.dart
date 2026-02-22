import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/mock/manager_finance_mock_data.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_ops_provider.dart';
import '../shared/manager_common_widgets.dart';

class MeterReadingScreen extends StatefulWidget {
  const MeterReadingScreen({super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerOpsProvider>();
    if (!provider.isLoading && provider.meterReadings.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerOpsProvider>();

    return ManagerPageScaffold(
      title: 'Sayac Okuma',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.speed),
        label: const Text('Okuma Ekle'),
      ),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ManagerSectionCard(
                  title: 'Okuma Kayitlari',
                  child: provider.meterReadings.isEmpty
                      ? const ManagerEmptyState(
                          icon: Icons.speed_outlined,
                          title: 'Sayac kaydi yok',
                          subtitle: 'Yeni okuma kaydi ekleyebilirsiniz.',
                        )
                      : Column(
                          children: provider.meterReadings
                              .map(
                                (reading) => ListTile(
                                  dense: true,
                                  title: Text(
                                      '${reading.unitLabel} • ${reading.meterType.label}'),
                                  subtitle: Text(
                                    '${reading.period} • ${reading.startIndex.toStringAsFixed(0)} → ${reading.endIndex.toStringAsFixed(0)}',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        reading.consumption.toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(reading.status.label),
                                    ],
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

  void _showCreateDialog(BuildContext context) {
    Map<String, String> selectedUnit = ManagerFinanceMockData.units.first;
    MeterType selectedType = MeterType.hotWater;
    final periodController = TextEditingController(text: '2026-02');
    final startController = TextEditingController(text: '1500');
    final endController = TextEditingController(text: '1560');

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Sayac Okuma Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Map<String, String>>(
                      initialValue: selectedUnit,
                      decoration: const InputDecoration(labelText: 'Daire'),
                      items: ManagerFinanceMockData.units
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit['label']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedUnit = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MeterType>(
                      initialValue: selectedType,
                      decoration:
                          const InputDecoration(labelText: 'Sayac Turu'),
                      items: MeterType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedType = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: periodController,
                      decoration: const InputDecoration(labelText: 'Donem'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: startController,
                      decoration:
                          const InputDecoration(labelText: 'Ilk Endeks'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: endController,
                      decoration:
                          const InputDecoration(labelText: 'Son Endeks'),
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
                    final start = double.tryParse(startController.text);
                    final end = double.tryParse(endController.text);
                    if (start == null || end == null || end < start) {
                      return;
                    }

                    await context.read<ManagerOpsProvider>().addMeterReading(
                          unitId: selectedUnit['id']!,
                          unitLabel: selectedUnit['label']!,
                          meterType: selectedType,
                          period: periodController.text,
                          start: start,
                          end: end,
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
