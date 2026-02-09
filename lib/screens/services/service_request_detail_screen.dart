import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/service_request_model.dart';
import '../../data/models/technician_model.dart';
import '../../data/providers/app_provider.dart';
import '../../core/theme/app_theme.dart';

class ServiceRequestDetailScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const ServiceRequestDetailScreen({super.key, required this.request});

  @override
  State<ServiceRequestDetailScreen> createState() =>
      _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState
    extends State<ServiceRequestDetailScreen> {
  late ServiceRequestModel _request;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  void _completeRequest() {
    _showRatingDialog();
  }

  void _cancelRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Talebi İptal Et'),
        content: const Text('Bu talebi iptal etmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(ServiceRequestStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Hizmeti Değerlendir'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Hizmetten ne kadar memnun kaldınız?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Yorumunuzu buraya yazın...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Vazgeç'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus(
                    ServiceRequestStatus.completed,
                    rating: rating,
                    comment: commentController.text,
                  );
                },
                child: const Text('Tamamla ve Puanla'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(
    ServiceRequestStatus status, {
    double? rating,
    String? comment,
  }) async {
    final provider = context.read<AppProvider>();
    await provider.updateServiceRequest(
      requestId: _request.id,
      status: status,
      rating: rating,
      reviewComment: comment,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Talep güncellendi')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates
    final provider = context.watch<AppProvider>();
    try {
      _request = provider.serviceRequests.firstWhere(
        (r) => r.id == widget.request.id,
      );
    } catch (_) {
      // Handle case where request might be removed (unlikely here)
    }

    final technician = provider.technicians.firstWhere(
      (t) => t.id == _request.technicianId,
      orElse: () => TechnicianModel(
        id: 'unknown',
        name: 'Bilinmeyen Usta',
        category: TechnicianCategory.other,
        photoUrl: '', // Will fail gracefully
        rating: 0,
        reviewCount: 0,
        phoneNumber: '',
        biography: '',
        skills: [],
        reviews: [],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Talep Detayı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Technician Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: technician.photoUrl.isNotEmpty
                        ? NetworkImage(technician.photoUrl)
                        : null,
                    child: technician.photoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technician.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          technician.categoryDisplayName,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Request Status
          _StatusCard(status: _request.status),
          const SizedBox(height: 24),

          // Details
          Text(
            'Talep Bilgileri',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Randevu Tarihi',
                  value: DateFormat(
                    'd MMMM yyyy HH:mm',
                    'tr_TR',
                  ).format(_request.appointmentDate),
                ),
                const Divider(),
                _DetailRow(
                  icon: Icons.description,
                  label: 'Açıklama',
                  value: _request.description,
                ),
                if (_request.rating != null) ...[
                  const Divider(),
                  _DetailRow(
                    icon: Icons.star,
                    label: 'Puanınız',
                    value: '${_request.rating} / 5.0',
                    valueColor: Colors.amber,
                  ),
                ],
                if (_request.reviewComment != null) ...[
                  const Divider(),
                  _DetailRow(
                    icon: Icons.comment,
                    label: 'Yorumunuz',
                    value: _request.reviewComment!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _request.status == ServiceRequestStatus.pending ||
              _request.status == ServiceRequestStatus.inProgress ||
              _request.status == ServiceRequestStatus.approved
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_request.status != ServiceRequestStatus.cancelled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Hizmeti Tamamla & Puanla'),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (_request.status == ServiceRequestStatus.pending)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _cancelRequest,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Talebi İptal Et'),
                      ),
                    ),
                ],
              ),
            )
          : null,
    );
  }
}

class _StatusCard extends StatelessWidget {
  final ServiceRequestStatus status;

  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case ServiceRequestStatus.pending:
        color = Colors.orange;
        label = 'Talep Bekliyor';
        icon = Icons.hourglass_empty;
        break;
      case ServiceRequestStatus.approved:
        color = Colors.blue;
        label = 'Onaylandı - Usta Yolda';
        icon = Icons.thumb_up;
        break;
      case ServiceRequestStatus.inProgress:
        color = Colors.purple;
        label = 'İşlem Devam Ediyor';
        icon = Icons.construction;
        break;
      case ServiceRequestStatus.completed:
        color = Colors.green;
        label = 'Tamamlandı';
        icon = Icons.check_circle;
        break;
      case ServiceRequestStatus.cancelled:
        color = Colors.red;
        label = 'İptal Edildi';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
