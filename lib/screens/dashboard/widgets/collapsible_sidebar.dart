import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_breakpoints.dart';

class CollapsibleSidebar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  final bool isCollapsed;
  final bool isDrawerMode;
  final VoidCallback onToggleCollapse;

  const CollapsibleSidebar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onToggleCollapse,
    this.isDrawerMode = false,
  });

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  // Define menu structure with optional children and specific IDs
  final List<MenuItem> _menuItems = [
    MenuItem(
      id: -10,
      title: 'Kişi ve Daire',
      icon: Icons.people_alt_outlined,
      children: [
        MenuItem(id: 10, title: 'Üye Listesi', icon: Icons.person_outline),
        MenuItem(
          id: 11,
          title: 'Taşınmaz Listesi',
          icon: Icons.apartment_outlined,
        ),
        MenuItem(
          id: 12,
          title: 'Smart Üye Sorgu',
          icon: Icons.manage_search_rounded,
        ),
        MenuItem(
          id: 13,
          title: 'Eski Üye Görünümü',
          icon: Icons.history_outlined,
        ),
      ],
    ),
    MenuItem(
      id: -15,
      title: 'Borçlandırma Merkezi',
      icon: Icons.request_quote_outlined,
      children: [
        MenuItem(
          id: 29,
          title: 'Borçlandırma Oluştur',
          icon: Icons.auto_awesome_outlined,
        ),
        MenuItem(
          id: 35,
          title: 'Zamanlanmış Takip',
          icon: Icons.schedule_outlined,
        ),
      ],
    ),
    MenuItem(
      id: -20,
      title: 'Finans',
      icon: Icons.account_balance_wallet_outlined,
      children: [
        MenuItem(id: 19, title: 'Özet', icon: Icons.dashboard_outlined),
        MenuItem(id: 21, title: 'Tahsilat', icon: Icons.payments_outlined),
        MenuItem(id: 22, title: 'Kasa Giderleri', icon: Icons.money_off),
        MenuItem(id: 23, title: 'Virman / Transfer', icon: Icons.swap_horiz),
        MenuItem(
          id: 24,
          title: 'Banka Eşleştirme',
          icon: Icons.account_balance_outlined,
        ),
        MenuItem(
          id: 25,
          title: 'Tahakkuk Hareketleri',
          icon: Icons.timeline_outlined,
        ),
        MenuItem(
          id: 26,
          title: 'Kasa Hareketleri',
          icon: Icons.receipt_long_outlined,
        ),
        MenuItem(
          id: 27,
          title: 'Daire Hesap Ekstresi',
          icon: Icons.home_work_outlined,
        ),
        MenuItem(
          id: 28,
          title: 'Cari Hesap Ekstresi',
          icon: Icons.business_center_outlined,
        ),
      ],
    ),
    MenuItem(
      id: -30,
      title: 'Raporlama',
      icon: Icons.bar_chart_outlined,
      children: [
        MenuItem(id: 30, title: 'Toplu Raporlar', icon: Icons.query_stats),
      ],
    ),
    MenuItem(
      id: -31,
      title: 'Bildirimler',
      icon: Icons.notifications_none_outlined,
      children: [
        MenuItem(
          id: 31,
          title: 'Toplu Bildirim',
          icon: Icons.campaign_outlined,
        ),
        MenuItem(
          id: 32,
          title: 'Toplu İletişim (SMS/Mail)',
          icon: Icons.quickreply_outlined,
        ),
      ],
    ),
    MenuItem(
      id: -40,
      title: 'Tanımlamalar',
      icon: Icons.settings_outlined,
      children: [
        MenuItem(
          id: 46,
          title: 'Taşınmaz ve Üye Tanımları',
          icon: Icons.business_outlined,
        ),
        MenuItem(id: 40, title: 'Site Ayarları', icon: Icons.settings),
        MenuItem(id: 41, title: 'Personel Yetkileri', icon: Icons.badge),
        MenuItem(id: 43, title: 'Karar Defteri', icon: Icons.gavel_outlined),
        MenuItem(id: 44, title: 'Dosya Arşivi', icon: Icons.folder_outlined),
      ],
    ),
    MenuItem(
      id: -42,
      title: 'İş Takibi',
      icon: Icons.work_outline,
      children: [
        MenuItem(id: 42, title: 'Görev ve Arama Notları', icon: Icons.task),
      ],
    ),
    MenuItem(
      id: -45,
      title: 'Teknik İşlemler',
      icon: Icons.engineering_outlined,
      children: [
        MenuItem(id: 45, title: 'Sayaç Okuma', icon: Icons.speed_outlined),
      ],
    ),
  ];

  // Track expanded state of items with children
  final Map<String, bool> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.isDrawerMode
          ? double.infinity
          : (widget.isCollapsed ? 70 : 260),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        border: widget.isDrawerMode
            ? null
            : const Border(
                right: BorderSide(color: Color(0xFFE2E5EA), width: 1),
              ),
      ),
      child: widget.isDrawerMode
          ? _buildSidebarContent(context)
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: widget.isCollapsed ? 70 : 260,
                child: _buildSidebarContent(context),
              ),
            ),
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Column(
      children: [
        // Header
        _buildHeader(context),

        // Menu Items
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 8 : 12,
              vertical: 8,
            ),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              return _buildMenuCard(_menuItems[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: widget.isCollapsed ? 8 : 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F2F5),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E5EA), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: widget.isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.isCollapsed)
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Menü',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          if (!widget.isDrawerMode)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onToggleCollapse,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E5EA)),
                  ),
                  child: Icon(
                    widget.isCollapsed
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuItem item) {
    final bool hasChildren = item.children != null && item.children!.isNotEmpty;
    final bool isChildSelected =
        hasChildren &&
        item.children!.any((child) => child.id == widget.selectedIndex);

    // Auto-expand if child is selected
    if (isChildSelected && !_expandedItems.containsKey(item.title)) {
      _expandedItems[item.title] = true;
    }

    final bool isExpanded = _expandedItems[item.title] ?? false;

    // ── Collapsed mode: icon-only pill ──
    if (widget.isCollapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Tooltip(
          message: item.title,
          preferBelow: false,
          waitDuration: const Duration(milliseconds: 400),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onToggleCollapse,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isChildSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isChildSelected
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : const Color(0xFFE8EBF0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: isChildSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── Expanded mode: Card with children ──
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isChildSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : const Color(0xFFE8EBF0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Card Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expandedItems[item.title] = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isChildSelected || isExpanded
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          size: 17,
                          color: isChildSelected || isExpanded
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: isChildSelected || isExpanded
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: isChildSelected || isExpanded
                              ? AppColors.primary
                              : const Color(0xFFB0B7C3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Children (animated)
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                children: [
                  const Divider(height: 1, indent: 14, endIndent: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: hasChildren
                          ? item.children!
                                .map((child) => _buildChildItem(child))
                                .toList()
                          : [],
                    ),
                  ),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildItem(MenuItem child) {
    final bool isSelected = widget.selectedIndex == child.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleLeafItemTap(child.id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                child.icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  child.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLeafItemTap(int itemId) {
    widget.onItemSelected(itemId);

    if (widget.isDrawerMode) {
      return;
    }

    final isCompact = ResponsiveBreakpoints.isMobileWidth(
      MediaQuery.sizeOf(context).width,
    );
    if (isCompact && !widget.isCollapsed) {
      widget.onToggleCollapse();
    }
  }
}

class MenuItem {
  final int id;
  final String title;
  final IconData icon;
  final List<MenuItem>? children;

  MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    this.children,
  });
}
