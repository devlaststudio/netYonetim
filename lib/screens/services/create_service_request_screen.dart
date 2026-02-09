import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/technician_model.dart';
import '../../data/providers/app_provider.dart';
import '../../core/theme/app_theme.dart';

class CreateServiceRequestScreen extends StatefulWidget {
  final TechnicianModel technician;

  const CreateServiceRequestScreen({super.key, required this.technician});

  @override
  State<CreateServiceRequestScreen> createState() =>
      _CreateServiceRequestScreenState();
}

class _CreateServiceRequestScreenState
    extends State<CreateServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _hasPhoto = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamerayı Aç'),
                onTap: () {
                  Navigator.pop(context);
                  _simulateFileSelection(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _simulateFileSelection(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulateFileSelection(bool isCamera) {
    // In a real app, we would use image_picker here
    // For now, we simulate a successful selection
    setState(() {
      _hasPhoto = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCamera
              ? 'Fotoğraf çekildi (Simülasyon)'
              : 'Fotoğraf seçildi (Simülasyon)',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final provider = context.read<AppProvider>();
      await provider.createServiceRequest(
        technicianId: widget.technician.id,
        categoryId: widget.technician.category.name,
        description: _descriptionController.text,
        appointmentDate: appointmentDateTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talep başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.popUntil(
          context,
          (route) => route.settings.name == '/service_records',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AppProvider, bool>((p) => p.isLoading);

    return Scaffold(
      appBar: AppBar(title: const Text('Talep Oluştur')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Technician Info Summary
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.technician.photoUrl),
              ),
              title: Text(widget.technician.name),
              subtitle: Text(widget.technician.categoryDisplayName),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Description
            Text(
              'Arıza / İş Tanımı',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Lütfen yapılacak işlemi veya arızayı detaylıca açıklayın...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir açıklama girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Date & Time
            Text(
              'Tercih Edilen Randevu Tarihi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Photo
            Text(
              'Fotoğraf Ekle',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickPhoto,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasPhoto ? AppColors.primary : Colors.grey.shade300,
                    width: _hasPhoto ? 2 : 1,
                  ),
                ),
                child: _hasPhoto
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://picsum.photos/400/300', // Mock photo
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 12,
                              child: Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Fotoğraf yüklemek için dokunun',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: isLoading ? Colors.grey : AppColors.primary,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Talebi Gönder'),
        ),
      ),
    );
  }
}
