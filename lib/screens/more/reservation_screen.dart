import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/facility_model.dart';
import '../../data/models/reservation_model.dart';
import '../../data/providers/app_provider.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen>
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tesisler & Etkinlikler'),
            Tab(text: 'Rezervasyonlarım'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_FacilitiesTab(), _MyReservationsTab()],
      ),
    );
  }
}

class _FacilitiesTab extends StatelessWidget {
  const _FacilitiesTab();

  @override
  Widget build(BuildContext context) {
    final facilities = context.watch<AppProvider>().facilities;

    if (facilities.isEmpty) {
      return const Center(child: Text('Tesis bulunamadı'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        return _FacilityCard(facility: facilities[index]);
      },
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final FacilityModel facility;

  const _FacilityCard({required this.facility});

  @override
  Widget build(BuildContext context) {
    final isEvent = facility.type == FacilityType.event;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Image.network(
              facility.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isEvent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Etkinlik',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  facility.description,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${facility.openTime.format(context)} - ${facility.closeTime.format(context)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _showBookingDialog(context, facility);
                      },
                      child: const Text('Rezervasyon Yap'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, FacilityModel facility) {
    showDialog(
      context: context,
      builder: (_) => _BookingDialog(facility: facility),
    );
  }
}

class _BookingDialog extends StatefulWidget {
  final FacilityModel facility;

  const _BookingDialog({required this.facility});

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validate time
      final open = widget.facility.openTime;
      final close = widget.facility.closeTime;

      final openMinutes = open.hour * 60 + open.minute;
      final closeMinutes = close.hour * 60 + close.minute;
      final pickedMinutes = picked.hour * 60 + picked.minute;

      if (pickedMinutes < openMinutes || pickedMinutes >= closeMinutes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Seçilen saat çalışma saatleri dışında'),
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.facility.name} Rezervasyon'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate),
            ),
            onTap: _selectDate,
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(_selectedTime?.format(context) ?? 'Saat Seçin'),
            onTap: _selectTime,
          ),
          const SizedBox(height: 8),
          Text(
            'Çalışma Saatleri: ${widget.facility.openTime.format(context)} - ${widget.facility.closeTime.format(context)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _selectedTime == null || _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);

                  final startTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );

                  final success = await context
                      .read<AppProvider>()
                      .makeReservation(
                        facility: widget.facility,
                        startTime: startTime,
                        durationMinutes: 60, // Default 1 hour
                      );

                  if (!context.mounted) return;

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Rezervasyon oluşturuldu'
                            : 'Bu saat dolu, lütfen başka bir saat seçin',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Onayla'),
        ),
      ],
    );
  }
}

class _MyReservationsTab extends StatelessWidget {
  const _MyReservationsTab();

  @override
  Widget build(BuildContext context) {
    final reservations = context.watch<AppProvider>().reservations;

    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz rezervasyonunuz yok',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        final isPast =
            reservation.status == ReservationStatus.completed ||
            reservation.status == ReservationStatus.cancelled;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPast
                  ? Colors.grey.shade200
                  : AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.event_available,
                color: isPast ? Colors.grey : AppColors.primary,
              ),
            ),
            title: Text(reservation.facilityName),
            subtitle: Text(
              '${DateFormat('d MMM yyyy HH:mm', 'tr_TR').format(reservation.startTime)}\n${reservation.durationMinutes} dakika',
            ),
            isThreeLine: true,
            trailing: reservation.status == ReservationStatus.active
                ? IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('İptal Et'),
                          content: const Text(
                            'Rezervasyonu iptal etmek istiyor musunuz?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Hayır'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AppProvider>().cancelReservation(
                                  reservation.id,
                                );
                                Navigator.pop(ctx);
                              },
                              child: const Text('Evet, İptal Et'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: reservation.status == ReservationStatus.cancelled
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      reservation.status == ReservationStatus.cancelled
                          ? 'İptal'
                          : 'Tamamlandı',
                      style: TextStyle(
                        fontSize: 12,
                        color: reservation.status == ReservationStatus.cancelled
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
