import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../services/technician_list_screen.dart';
import '../../data/models/technician_model.dart';
import '../../data/models/service_request_model.dart';
import '../../data/providers/app_provider.dart';
import 'package:provider/provider.dart';
import '../services/service_request_detail_screen.dart';

class ServiceRecordsScreen extends StatefulWidget {
  const ServiceRecordsScreen({super.key});

  @override
  State<ServiceRecordsScreen> createState() => _ServiceRecordsScreenState();
}

class _ServiceRecordsScreenState extends State<ServiceRecordsScreen>
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
        title: const Text('Servis Hizmetleri'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hizmet Al'),
            Tab(text: 'Taleplerim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_ServiceCategoriesTab(), const _MyRequestsTab()],
      ),
    );
  }
}

class _ServiceCategoriesTab extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.water_drop,
      'title': 'Sıhhi Tesisat',
      'category': TechnicianCategory.plumbing,
      'color': Colors.blue,
    },
    {
      'icon': Icons.electrical_services,
      'title': 'Elektrik',
      'category': TechnicianCategory.electric,
      'color': Colors.orange,
    },
    {
      'icon': Icons.cleaning_services,
      'title': 'Temizlik',
      'category': TechnicianCategory.cleaning,
      'color': Colors.purple,
    },
    {
      'icon': Icons.format_paint,
      'title': 'Boya & Badana',
      'category': TechnicianCategory.painting,
      'color': Colors.redAccent,
    },
    {
      'icon': Icons.security,
      'title': 'Güvenlik / Çilingir',
      'category': TechnicianCategory.security,
      'color': Colors.indigo,
    },
    {
      'icon': Icons.chair,
      'title': 'Mobilya Montaj',
      'category': TechnicianCategory.furniture,
      'color': Colors.brown,
    },
    {
      'icon': Icons.handyman,
      'title': 'Diğer',
      'category': TechnicianCategory.other,
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TechnicianListScreen(
                  category: cat['category'] as TechnicianCategory,
                  categoryName: cat['title'] as String,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    size: 32,
                    color: cat['color'] as Color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cat['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MyRequestsTab extends StatelessWidget {
  const _MyRequestsTab();

  @override
  Widget build(BuildContext context) {
    // Watch provider
    final provider = context.watch<AppProvider>();
    final requests = provider.serviceRequests;

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz bir talebiniz bulunmuyor',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        // Find technician for display name
        // In a real app we'd join this, here we'll just try to find it or show ID
        // actually we don't have easy lookup map, so let's check provider technicians
        final technician = provider.technicians.firstWhere(
          (t) => t.id == request.technicianId,
          orElse: () => provider.technicians.isNotEmpty
              ? provider.technicians[0]
              : throw Exception('Technician not found'),
        );

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ServiceRequestDetailScreen(request: request),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        technician.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _StatusChip(status: request.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.event, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        // Simple formatting
                        '${request.appointmentDate.day}/${request.appointmentDate.month}/${request.appointmentDate.year} ${request.appointmentDate.hour}:${request.appointmentDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ServiceRequestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case ServiceRequestStatus.pending:
        color = Colors.orange;
        label = 'Bekliyor';
        break;
      case ServiceRequestStatus.approved:
        color = Colors.blue;
        label = 'Onaylandı';
        break;
      case ServiceRequestStatus.inProgress:
        color = Colors.purple;
        label = 'İşlemde';
        break;
      case ServiceRequestStatus.completed:
        color = Colors.green;
        label = 'Tamamlandı';
        break;
      case ServiceRequestStatus.cancelled:
        color = Colors.red;
        label = 'İptal';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
