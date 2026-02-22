import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/manager/manager_models.dart';
import '../../data/providers/manager_ops_provider.dart';

class PhonebookScreen extends StatefulWidget {
  const PhonebookScreen({super.key});

  @override
  State<PhonebookScreen> createState() => _PhonebookScreenState();
}

class _PhonebookScreenState extends State<PhonebookScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ManagerOpsProvider>();
    if (!provider.isLoading && provider.staffRoles.isEmpty) {
      provider.loadMockData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerOpsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Telefon Rehberi')),
      backgroundColor: AppColors.background,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Acil Durum Hatlari',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 10),
                        _EmergencyTile(
                          title: 'Guvenlik Noktasi',
                          phone: '0 (212) 555 10 10',
                          icon: Icons.shield_outlined,
                        ),
                        _EmergencyTile(
                          title: 'Teknik Servis',
                          phone: '0 (212) 555 20 20',
                          icon: Icons.handyman_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.staffRoles.map(
                  (staff) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        child:
                            const Icon(Icons.person, color: AppColors.primary),
                      ),
                      title: Text(staff.fullName),
                      subtitle: Text(staff.role.label),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Ara',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${staff.fullName} aranıyor (mock).')),
                              );
                            },
                            icon: const Icon(Icons.call_outlined),
                          ),
                          IconButton(
                            tooltip: 'Mesaj',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${staff.fullName} mesaj ekranı (mock).')),
                              );
                            },
                            icon: const Icon(Icons.message_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmergencyTile extends StatelessWidget {
  final String title;
  final String phone;
  final IconData icon;

  const _EmergencyTile({
    required this.title,
    required this.phone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(phone),
      trailing: IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title aranıyor (mock).')),
          );
        },
        icon: const Icon(Icons.call),
      ),
    );
  }
}
