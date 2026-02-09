import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/app_provider.dart';
import '../../data/models/technician_model.dart';
import 'technician_profile_screen.dart';
import '../../core/theme/app_theme.dart';

class TechnicianListScreen extends StatelessWidget {
  final TechnicianCategory category;
  final String categoryName;

  const TechnicianListScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final technicians = provider.technicians
        .where((t) => t.category == category)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: technicians.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu kategoride kayıtlı usta bulunmuyor.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                final technician = technicians[index];
                return _TechnicianCard(technician: technician);
              },
            ),
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  final TechnicianModel technician;

  const _TechnicianCard({required this.technician});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TechnicianProfileScreen(technician: technician),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Photo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(technician.photoUrl),
                    fit: BoxFit.cover,
                    onError: (_, __) {
                      // Fallback icon if image fails
                    },
                  ),
                  color: Colors.grey.shade200,
                ),
                child: technician.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),

              // Info
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${technician.rating} (${technician.reviewCount} Yorum)',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: technician.skills.take(3).map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
