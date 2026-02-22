import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_breakpoints.dart';
import '../../../core/navigation/dashboard_embed_scope.dart';
import 'widgets/message_composer_panel.dart';
import 'widgets/recipient_grid_panel.dart';

class SmsNotificationsScreen extends StatefulWidget {
  const SmsNotificationsScreen({super.key});

  @override
  State<SmsNotificationsScreen> createState() => _SmsNotificationsScreenState();
}

class _SmsNotificationsScreenState extends State<SmsNotificationsScreen> {
  // Common state between composer and grid could live here
  int _selectedRecipientCount = 0;

  void _onRecipientSelectionChanged(int count) {
    setState(() {
      _selectedRecipientCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveBreakpoints.isMobileWidth(
          constraints.maxWidth,
        );

        if (isMobile) {
          // Mobile Layout: Composer on top, button at bottom, Grid accessed separately or stacked
          return _buildMobileLayout();
        } else {
          // Desktop Layout: Side-by-side
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    // Dashboard içine gömüldüğünde AppBar'ı gizle
    final isEmbedded = DashboardEmbedScope.hideBackButton(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isEmbedded
          ? null
          : AppBar(
              title: const Text('Toplu İletişim (SMS/E-posta)'),
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel: Form area (approx 35% width)
          const Expanded(
            flex: 35,
            child: MessageComposerPanel(isDesktop: true),
          ),

          // Vertical Divider
          Container(width: 1, color: AppColors.border.withValues(alpha: 0.5)),

          // Right Panel: Recipients Grid (approx 65% width)
          Expanded(
            flex: 65,
            child: RecipientGridPanel(
              onSelectionChanged: _onRecipientSelectionChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    // Dashboard içine gömüldüğünde AppBar'ı gizle
    final isEmbedded = DashboardEmbedScope.hideBackButton(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isEmbedded
          ? null
          : AppBar(
              title: const Text(
                'Toplu İletişim',
                style: TextStyle(fontSize: 18),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MessageComposerPanel(isDesktop: false),

            // On mobile, the grid could be a separate section below
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Alıcı Listesi ($_selectedRecipientCount Kişi Seçili)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Let it take its natural height
            RecipientGridPanel(
              onSelectionChanged: _onRecipientSelectionChanged,
              isMobile: true,
            ),
            const SizedBox(height: 80), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _selectedRecipientCount > 0 ? () {} : null,
              icon: const Icon(Icons.send_rounded),
              label: Text('$_selectedRecipientCount Kişiye Gönder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
