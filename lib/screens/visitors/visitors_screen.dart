import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/visitor_model.dart';
import '../../data/providers/app_provider.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen>
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
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziyaretçi Takibi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Beklenen / Aktif'),
            Tab(text: 'Geçmiş'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVisitorSheet(context),
        label: const Text('Ziyaretçi Ekle'),
        icon: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VisitorListTab(
            visitors: [
              ...provider.activeVisitors,
              ...provider.expectedVisitors,
            ],
            emptyMessage: 'Beklenen ziyaretçi bulunmuyor',
            emptyIcon: Icons.access_time,
          ),
          _VisitorListTab(
            visitors: provider.pastVisitors,
            emptyMessage: 'Geçmiş kayıt bulunmuyor',
            emptyIcon: Icons.history,
          ),
        ],
      ),
    );
  }

  void _showAddVisitorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddVisitorSheet(),
    );
  }
}

class _VisitorListTab extends StatelessWidget {
  final List<VisitorModel> visitors;
  final String emptyMessage;
  final IconData emptyIcon;

  const _VisitorListTab({
    required this.visitors,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (visitors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 80,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(
                visitor.status,
              ).withValues(alpha: 0.1),
              child: Icon(
                _getStatusIcon(visitor.status),
                color: _getStatusColor(visitor.status),
              ),
            ),
            title: Text(visitor.guestName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (visitor.plateNumber != null)
                  Text(
                    '🚗 ${visitor.plateNumber}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary,
                    ),
                  ),
                Text(
                  '🕒 ${DateFormat('dd MMM HH:mm').format(visitor.expectedDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (visitor.note != null)
                  Text(
                    '📝 ${visitor.note}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(visitor.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                visitor.statusDisplayName,
                style: TextStyle(
                  color: _getStatusColor(visitor.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(VisitorStatus status) {
    switch (status) {
      case VisitorStatus.expected:
        return AppColors.warning;
      case VisitorStatus.inside:
        return AppColors.success;
      case VisitorStatus.left:
        return AppColors.textSecondary;
      case VisitorStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(VisitorStatus status) {
    switch (status) {
      case VisitorStatus.expected:
        return Icons.access_time;
      case VisitorStatus.inside:
        return Icons.meeting_room;
      case VisitorStatus.left:
        return Icons.logout;
      case VisitorStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

class _AddVisitorSheet extends StatefulWidget {
  const _AddVisitorSheet();

  @override
  State<_AddVisitorSheet> createState() => _AddVisitorSheetState();
}

class _AddVisitorSheetState extends State<_AddVisitorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();

      final expectedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await provider.addVisitor(
        guestName: _nameController.text,
        plateNumber: _plateController.text.isNotEmpty
            ? _plateController.text
            : null,
        expectedDate: expectedDateTime,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ziyaretçi kaydı oluşturuldu ✅'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Yeni Ziyaretçi Kaydı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Guest Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Misafir Adı Soyadı',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen isim giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Plate Number
            TextFormField(
              controller: _plateController,
              decoration: const InputDecoration(
                labelText: 'Araç Plakası (Opsiyonel)',
                prefixIcon: Icon(Icons.directions_car_outlined),
                hintText: '06 ABC 123',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectTime(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Not (Opsiyonel)',
                prefixIcon: Icon(Icons.note_alt_outlined),
                hintText: 'Kargo getirecek, mobilya montajı vb.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
