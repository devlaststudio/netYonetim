import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'template_management_dialog.dart';
import 'recipient_group_management_dialog.dart';

class MessageComposerPanel extends StatefulWidget {
  final bool isDesktop;

  const MessageComposerPanel({super.key, required this.isDesktop});

  @override
  State<MessageComposerPanel> createState() => _MessageComposerPanelState();
}

class _MessageComposerPanelState extends State<MessageComposerPanel> {
  int _selectedChannel = 0; // 0: SMS, 1: WhatsApp, 2: E-posta
  int _selectedTemplate = 0; // 0: Borç Bildirimi, 1: Genel Duyuru
  final List<int> _selectedGroups = [
    0,
    2,
  ]; // 0: Aktif Malikler, 1: Kiracılar, 2: Borçlu Sakinler

  bool _addDebtLink = true;
  bool _mergeSms = false;
  bool _includeExecutionDebts = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GÖNDERİM KANALI
            _buildSectionTitle('1. GÖNDERİM KANALI'),
            const SizedBox(height: 12),
            _buildChannelSelector(),
            const SizedBox(height: 32),

            // 2. HIZLI ŞABLONLAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildSectionTitle('2. HIZLI ŞABLONLAR')),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const TemplateManagementDialog(),
                    );
                  },
                  child: const Text(
                    'Tümünü Gör',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTemplatesSelector(),
            const SizedBox(height: 32),

            // 3. ALICI GRUPLARI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildSectionTitle('3. ALICI GRUPLARI')),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          const RecipientGroupManagementDialog(),
                    );
                  },
                  child: const Text(
                    'Tümünü Gör',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildGroupsSelector(),
            const SizedBox(height: 32),

            // 4. MESAJ DETAYLARI
            _buildSectionTitle('4. MESAJ DETAYLARI'),
            const SizedBox(height: 12),
            _buildMessageDetails(),

            if (widget.isDesktop) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {}, // Action hooked up later
                  icon: const Icon(Icons.send_rounded),
                  label: const Text(
                    'Seçilen Kişilere Gönder',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'İşlem geri alınamaz. Gönderim raporları raporlar panelinde görüntülenebilir.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildChannelSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildChannelOption(0, Icons.sms, 'SMS'),
          _buildChannelOption(1, Icons.chat, 'WhatsApp'),
          _buildChannelOption(2, Icons.email, 'E-posta'),
        ],
      ),
    );
  }

  Widget _buildChannelOption(int index, IconData icon, String label) {
    final isSelected = _selectedChannel == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedChannel = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesSelector() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 8, right: 16),
        child: Row(
          children: [
            _buildTemplateCard(
              0,
              Icons.account_balance_wallet,
              AppColors.primary,
              'Borç Bildirimi',
              'Aidat ve ek ödemeler',
            ),
            const SizedBox(width: 12),
            _buildTemplateCard(
              1,
              Icons.campaign,
              AppColors.warning,
              'Genel Duyuru',
              'Bakım, kesinti vb.',
            ),
            const SizedBox(width: 12),
            _buildTemplateCard(
              2,
              Icons.celebration,
              AppColors.secondary,
              'Özel Gün',
              'Kutlama mesajları',
            ),
            const SizedBox(width: 12),
            _buildTemplateCard(
              3,
              Icons.groups,
              Colors.blue,
              'Toplantı Çağrısı',
              'Genel kurul daveti',
            ),
            const SizedBox(width: 12),
            _buildTemplateCard(
              4,
              Icons.gavel,
              AppColors.error,
              'İcra Bildirimi',
              'Yasal süreç başlatma',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    int index,
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedTemplate == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTemplate = index),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsSelector() {
    return Container(
      height: 240, // Fixed height to allow scrolling inner content
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildGroupCard(
            0,
            'Aktif Malikler',
            'Tapu sahibi sakinler',
            '124 Kişi',
          ),
          const SizedBox(height: 12),
          _buildGroupCard(1, 'Kiracılar', 'Aktif ikamet edenler', '86 Kişi'),
          const SizedBox(height: 12),
          _buildGroupCard(
            2,
            'Borçlu Sakinler',
            'Ödemesi gecikenler',
            '42 Kişi',
          ),
          const SizedBox(height: 12),
          _buildGroupCard(
            3,
            'Yönetim Kurulu',
            'Site yönetim kurulu üyeleri',
            '5 Kişi',
          ),
          const SizedBox(height: 12),
          _buildGroupCard(
            4,
            'Tüm Sakinler',
            'Sitede yaşayan herkes',
            '210 Kişi',
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    int index,
    String title,
    String subtitle,
    String count,
  ) {
    final isSelected = _selectedGroups.contains(index);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGroups.remove(index);
          } else {
            _selectedGroups.add(index);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.6),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Custom checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageDetails() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildCheckboxOption(
          'Borç dökümü görüntüleme linki ekle.',
          _addDebtLink,
          (val) => setState(() => _addDebtLink = val ?? false),
        ),
        _buildCheckboxOption(
          "Aynı kişiye giden sms'leri (tutarları) birleştir.",
          _mergeSms,
          (val) => setState(() => _mergeSms = val ?? false),
        ),
        _buildCheckboxOption(
          'İcraya verilen borçları toplama dahil et.',
          _includeExecutionDebts,
          (val) => setState(() => _includeExecutionDebts = val ?? false),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
