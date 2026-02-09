import 'package:flutter/material.dart';
import 'placeholder_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Yönetim Kadrosu',
      icon: Icons.people_alt,
    );
  }
}
