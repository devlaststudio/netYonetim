import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/manager/manager_models.dart';
import '../../../data/providers/manager_ops_provider.dart';
import '../shared/manager_common_widgets.dart';

class StaffRolesScreen extends StatefulWidget {
  const StaffRolesScreen({super.key});

  @override
  State<StaffRolesScreen> createState() => _StaffRolesScreenState();
}

class _StaffRolesScreenState extends State<StaffRolesScreen> {
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

    return ManagerPageScaffold(
      title: 'Personel Hesaplari ve Yetkiler',
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...provider.staffRoles.map(
                  (staff) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        child:
                            const Icon(Icons.person, color: AppColors.primary),
                      ),
                      title: Text(staff.fullName),
                      subtitle: Text(
                          '${staff.role.label} • ${staff.permissions.join(', ')}'),
                      trailing: Switch(
                        value: staff.mobileVisible,
                        onChanged: (value) {
                          provider.updateStaffRole(
                              staff.copyWith(mobileVisible: value));
                        },
                      ),
                      onTap: () => _showPermissionEditor(context, staff),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showPermissionEditor(BuildContext context, StaffRoleRecord staff) {
    final allPermissions = [
      'dashboard',
      'reports',
      'collections',
      'expenses',
      'settings',
      'task-tracking',
      'file-archive',
      'meter-reading',
    ];
    final selected = {...staff.permissions};

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${staff.fullName} Yetkileri'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: allPermissions
                      .map(
                        (permission) => CheckboxListTile(
                          value: selected.contains(permission),
                          onChanged: (checked) {
                            setState(() {
                              if (checked ?? false) {
                                selected.add(permission);
                              } else {
                                selected.remove(permission);
                              }
                            });
                          },
                          title: Text(permission),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      )
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Vazgec'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await context.read<ManagerOpsProvider>().updateStaffRole(
                          staff.copyWith(permissions: selected.toList()),
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
