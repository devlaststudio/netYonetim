import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../manager/definitions/property_definitions_screen.dart';
import '../../core/constants/responsive_breakpoints.dart';
import '../../core/navigation/dashboard_embed_scope.dart';
import '../../data/providers/app_provider.dart';
import 'widgets/collapsible_sidebar.dart';

import '../members/member_list_screen.dart';
import '../members/smart_member_query_screen.dart';
import '../properties/property_list_screen.dart';

import '../manager/finance/summary_screen.dart';
import '../manager/finance/charges_wizard_codex_screen.dart';
import '../manager/finance/scheduled_charges_tracking_screen.dart';

import '../manager/finance/collections_center_screen.dart';
import '../manager/finance/cash_expenses_screen.dart';
import '../manager/finance/transfers_screen.dart';
import '../manager/finance/bank_reconciliation_screen.dart';
import '../manager/finance/accrual_movements_screen.dart';
import '../manager/finance/cash_movements_screen.dart';
import '../manager/finance/unit_statement_screen.dart';
import '../manager/finance/vendor_statement_screen.dart';

import '../manager/reports/bulk_reports_screen.dart';

import '../manager/ops/notifications_center_screen.dart';
import '../manager/ops/sms_notifications_screen.dart';
import '../manager/ops/site_settings_screen.dart';
import '../manager/ops/staff_roles_screen.dart';
import '../manager/ops/task_tracking_screen.dart';
import '../manager/ops/decision_book_screen.dart';
import '../manager/ops/file_archive_screen.dart';
import '../manager/ops/meter_reading_screen.dart';
import '../manager/ops/legacy_members_screen.dart';

import '../../core/widgets/lazy_indexed_stack.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  bool _isSidebarCollapsed = true;
  int _selectedSidebarIndex = 19; // Varsayılan sayfa: Özet

  /// Sidebar index → Sayfa widget eşleştirmesi
  /// Sıralama sidebar menü yapısını takip eder
  static final List<_SayfaTanimi> _sayfaListesi = [
    // ── Kişi ve Daire ──
    _SayfaTanimi(sidebarIndex: 10, sayfa: const MemberListScreen()),
    _SayfaTanimi(sidebarIndex: 11, sayfa: const PropertyListScreen()),
    _SayfaTanimi(sidebarIndex: 12, sayfa: const SmartMemberQueryScreen()),
    _SayfaTanimi(sidebarIndex: 13, sayfa: const LegacyMembersScreen()),

    // ── Borçlandırma Merkezi ──
    _SayfaTanimi(sidebarIndex: 29, sayfa: const ChargesWizardCodexScreen()),
    _SayfaTanimi(
      sidebarIndex: 35,
      sayfa: const ScheduledChargesTrackingScreen(),
    ),

    // ── Finans ──
    _SayfaTanimi(sidebarIndex: 19, sayfa: const SummaryScreen()),
    _SayfaTanimi(sidebarIndex: 21, sayfa: const CollectionsCenterScreen()),
    _SayfaTanimi(sidebarIndex: 22, sayfa: const CashExpensesScreen()),
    _SayfaTanimi(sidebarIndex: 23, sayfa: const TransfersScreen()),
    _SayfaTanimi(sidebarIndex: 24, sayfa: const BankReconciliationScreen()),
    _SayfaTanimi(sidebarIndex: 25, sayfa: const AccrualMovementsScreen()),
    _SayfaTanimi(sidebarIndex: 26, sayfa: const CashMovementsScreen()),
    _SayfaTanimi(sidebarIndex: 27, sayfa: const UnitStatementScreen()),
    _SayfaTanimi(sidebarIndex: 28, sayfa: const VendorStatementScreen()),

    // ── Raporlama ──
    _SayfaTanimi(sidebarIndex: 30, sayfa: const BulkReportsScreen()),

    // ── Bildirimler ──
    _SayfaTanimi(sidebarIndex: 31, sayfa: const NotificationsCenterScreen()),
    _SayfaTanimi(sidebarIndex: 32, sayfa: const SmsNotificationsScreen()),

    // ── Tanımlamalar ──
    _SayfaTanimi(sidebarIndex: 46, sayfa: const PropertyDefinitionsScreen()),
    _SayfaTanimi(sidebarIndex: 40, sayfa: const SiteSettingsScreen()),
    _SayfaTanimi(sidebarIndex: 41, sayfa: const StaffRolesScreen()),
    _SayfaTanimi(sidebarIndex: 43, sayfa: const DecisionBookScreen()),
    _SayfaTanimi(sidebarIndex: 44, sayfa: const FileArchiveScreen()),

    // ── İş Takibi ──
    _SayfaTanimi(sidebarIndex: 42, sayfa: const TaskTrackingScreen()),

    // ── Teknik İşlemler ──
    _SayfaTanimi(sidebarIndex: 45, sayfa: const MeterReadingScreen()),
  ];

  /// Sidebar index'ini LazyIndexedStack'teki sıralı index'e çevirir
  int get _aktifSayfaIndex {
    final idx = _sayfaListesi.indexWhere(
      (s) => s.sidebarIndex == _selectedSidebarIndex,
    );
    // Bulunamaz ise varsayılan olarak Özet sayfasını (index 19) göster
    return idx >= 0
        ? idx
        : _sayfaListesi.indexWhere((s) => s.sidebarIndex == 19);
  }

  void _onSidebarToggle() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _onSidebarItemSelect(int index) {
    setState(() {
      _selectedSidebarIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveBreakpoints.isMobileWidth(
          constraints.maxWidth,
        );

        return Scaffold(
          endDrawer: isMobile
              ? Drawer(
                  width: 280,
                  child: CollapsibleSidebar(
                    isCollapsed: false,
                    isDrawerMode: true,
                    selectedIndex: _selectedSidebarIndex,
                    onToggleCollapse: () {},
                    onItemSelected: (index) {
                      _onSidebarItemSelect(index);
                      Navigator.pop(context); // Drawer'ı kapat
                    },
                  ),
                )
              : null,
          body: Column(
            children: [
              // Özel Karşılama Başlığı
              _DashboardHeader(
                provider: provider,
                isMobile: isMobile,
                onMenuPressed: isMobile
                    ? () => Scaffold.of(context).openEndDrawer()
                    : null,
              ),

              // Ana içerik alanı
              Expanded(
                child: Row(
                  children: [
                    // Sidebar (sadece masaüstü)
                    if (!isMobile)
                      CollapsibleSidebar(
                        isCollapsed: _isSidebarCollapsed,
                        selectedIndex: _selectedSidebarIndex,
                        onToggleCollapse: _onSidebarToggle,
                        onItemSelected: _onSidebarItemSelect,
                      ),

                    // Sayfa içeriği — LazyIndexedStack ile tembel yükleme
                    Expanded(
                      child: DashboardEmbedScope(
                        hideAppBarBack: true,
                        child: LazyIndexedStack(
                          index: _aktifSayfaIndex,
                          children: _sayfaListesi.map((s) => s.sayfa).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sidebar index ile sayfa widget'ını eşleştiren yardımcı sınıf
class _SayfaTanimi {
  final int sidebarIndex;
  final Widget sayfa;

  const _SayfaTanimi({required this.sidebarIndex, required this.sayfa});
}

// ─── Dashboard Welcome Header ───────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final AppProvider provider;
  final bool isMobile;
  final VoidCallback? onMenuPressed;

  const _DashboardHeader({
    required this.provider,
    required this.isMobile,
    this.onMenuPressed,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = provider.currentUser;
    final isWideHeader = MediaQuery.of(context).size.width > 700;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F2F5),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E5EA), width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: isWideHeader
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Welcome + Site Info
                    Expanded(child: _buildWelcomeSection(context, user)),
                    const SizedBox(width: 16),
                    // Right: Staff contacts + actions
                    _buildStaffChips(context, isRow: true),
                    const SizedBox(width: 8),
                    _buildActionButtons(context),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Welcome + action buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildWelcomeSection(context, user)),
                        _buildActionButtons(context),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Bottom: Staff contacts
                    _buildStaffChips(context, isRow: false),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hoş geldin, ${user?.firstName ?? "Yönetici"}! 👋',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_city,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            if (provider.managedSites.length > 1)
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 4),
                onSelected: (siteId) {
                  final site = provider.managedSites.firstWhere(
                    (s) => s.id == siteId,
                  );
                  provider.selectSite(site);
                },
                itemBuilder: (context) {
                  return provider.managedSites.map((site) {
                    final isSelected = site.id == provider.selectedSite?.id;
                    return PopupMenuItem<String>(
                      value: site.id,
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 18,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  site.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  site.address,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        provider.selectedSiteName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: Text(
                  provider.selectedSiteName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user?.roleDisplayName ?? "",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaffChips(BuildContext context, {required bool isRow}) {
    final gorevliChip = _HeaderStaffChip(
      role: 'Görevli',
      name: 'Ali Demir',
      phone: '0532 111 22 33',
      icon: Icons.engineering,
      color: AppColors.primary,
      onCall: _makePhoneCall,
    );

    final guvenlikChip = _HeaderStaffChip(
      role: 'Güvenlik',
      name: 'Hasan Kara',
      phone: '0533 444 55 66',
      icon: Icons.shield_outlined,
      color: AppColors.success,
      onCall: _makePhoneCall,
    );

    if (isRow) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [gorevliChip, const SizedBox(width: 8), guvenlikChip],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [gorevliChip, guvenlikChip],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              if (provider.unreadAnnouncementsCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${provider.unreadAnnouncementsCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/announcements');
          },
        ),
        if (isMobile && onMenuPressed != null)
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
      ],
    );
  }
}

// ─── Staff Contact Chip for Header ──────────────────────────────────────────

class _HeaderStaffChip extends StatelessWidget {
  final String role;
  final String name;
  final String phone;
  final IconData icon;
  final Color color;
  final Future<void> Function(String) onCall;

  const _HeaderStaffChip({
    required this.role,
    required this.name,
    required this.phone,
    required this.icon,
    required this.color,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$role: $name',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => onCall(phone),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.phone,
                size: 14,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
