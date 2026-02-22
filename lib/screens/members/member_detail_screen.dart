import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/member_mock_data.dart';
import 'member_add_screen.dart';

class MemberDetailScreen extends StatelessWidget {
  final MemberData member;
  final MemberData? tenant;

  const MemberDetailScreen({super.key, required this.member, this.tenant});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (tenant != null)
              ? '${member.block} Blok - No: ${member.unitNo} Detayı'
              : member.fullName.toUpperCase(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions_car, size: 14),
                  label: const Text('Plaka Kayıtları'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.people, size: 14),
                  label: const Text('İkamet Edenler'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.folder,
                    size: 14,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'İcra Dosyaları',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    side: const BorderSide(color: AppColors.error, width: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Profile Cards (Malik and Tenant side by side or stacked)
            LayoutBuilder(
              builder: (context, constraints) {
                if (tenant != null) {
                  // We have both an Owner and a Tenant
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildProfileCard(
                            context,
                            member,
                            currencyFormat,
                            'Malik',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildProfileCard(
                            context,
                            tenant!,
                            currencyFormat,
                            'Kiracı',
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildProfileCard(
                          context,
                          member,
                          currencyFormat,
                          'Malik',
                        ),
                        const SizedBox(height: 16),
                        _buildProfileCard(
                          context,
                          tenant!,
                          currencyFormat,
                          'Kiracı',
                        ),
                      ],
                    );
                  }
                } else {
                  return _buildProfileCard(
                    context,
                    member,
                    currencyFormat,
                    null,
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            // Action Buttons Row
            // Action Buttons Row
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          _ActionButton(
                            label: 'Not Ekle',
                            icon: Icons.note_add,
                            color: AppColors.secondary,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            label: 'Ödeme Yap',
                            icon: Icons.payment,
                            color: AppColors.primary,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ActionButton(
                            label: 'Borçlandır',
                            icon: Icons.money_off,
                            color: AppColors.accent,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            label: 'Tahsilat İşle',
                            icon: Icons.receipt,
                            color: AppColors.info,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    _ActionButton(
                      label: 'Not Ekle',
                      icon: Icons.note_add,
                      color: AppColors.secondary,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Ödeme Yap',
                      icon: Icons.payment,
                      color: AppColors.primary,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Borçlandır',
                      icon: Icons.money_off,
                      color: AppColors.accent,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Tahsilat İşle',
                      icon: Icons.receipt,
                      color: AppColors.info,
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Financial Summary Cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          _FinancialCard(
                            title: 'Bakiye',
                            value:
                                '${currencyFormat.format(member.balance)} (A)',
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.08,
                            ),
                            textColor: AppColors.textPrimary,
                          ),
                          _FinancialCard(
                            title: 'Aidat',
                            value:
                                '${currencyFormat.format(member.aidatBalance)} (A)',
                            color: AppColors.primary.withValues(alpha: 0.08),
                            textColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _FinancialCard(
                            title: 'Yakıt',
                            value:
                                '${currencyFormat.format(member.yakitBalance)} (A)',
                            color: AppColors.secondary.withValues(alpha: 0.08),
                            textColor: AppColors.secondary,
                          ),
                          _FinancialCard(
                            title: 'Demirbaş',
                            value:
                                '${currencyFormat.format(member.demirbasBalance)} (A)',
                            color: AppColors.accent.withValues(alpha: 0.08),
                            textColor: AppColors.accent,
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    _FinancialCard(
                      title: 'Bakiye',
                      value: '${currencyFormat.format(member.balance)} (A)',
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      textColor: AppColors.textPrimary,
                    ),
                    _FinancialCard(
                      title: 'Aidat',
                      value:
                          '${currencyFormat.format(member.aidatBalance)} (A)',
                      color: AppColors.primary.withValues(alpha: 0.08),
                      textColor: AppColors.primary,
                    ),
                    _FinancialCard(
                      title: 'Yakıt',
                      value:
                          '${currencyFormat.format(member.yakitBalance)} (A)',
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      textColor: AppColors.secondary,
                    ),
                    _FinancialCard(
                      title: 'Demirbaş',
                      value:
                          '${currencyFormat.format(member.demirbasBalance)} (A)',
                      color: AppColors.accent.withValues(alpha: 0.08),
                      textColor: AppColors.accent,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Transactions Table
            // Transactions Section
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return _buildTransactionCardList(
                    context,
                    member.transactions,
                    dateFormat,
                    currencyFormat,
                  );
                } else {
                  return _buildTransactionTable(
                    context,
                    member.transactions,
                    dateFormat,
                    currencyFormat,
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Notes section
            if (member.notes.isNotEmpty) ...[
              Text('📝 Notlar', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...member.notes.map(
                (note) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.note,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      note.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(note.content),
                    trailing: Text(
                      dateFormat.format(note.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    MemberData m,
    NumberFormat currencyFormat,
    String? roleLabel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (roleLabel != null)
                  Text(
                    roleLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                else
                  const SizedBox(),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberAddScreen(initialMember: m),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Güncelle'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 36,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        m.fullName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Phone & quick actions
                      _InfoRow(
                        icon: Icons.phone,
                        label: 'Telefon',
                        value: m.phone,
                        actions: const [
                          _QuickAction(
                            label: 'Metin Gönder',
                            icon: Icons.message,
                          ),
                          _QuickAction(
                            label: 'Bakiye Gönder',
                            icon: Icons.account_balance_wallet,
                          ),
                          _QuickAction(label: 'Şifre Gönder', icon: Icons.lock),
                          _QuickAction(
                            label: 'SMS Raporu',
                            icon: Icons.analytics,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Email
                      _InfoRow(
                        icon: Icons.email,
                        label: 'E-Posta',
                        value: m.email,
                        actions: const [
                          _QuickAction(label: 'Şifre Gönder', icon: Icons.lock),
                          _QuickAction(
                            label: 'E-Posta Gönder',
                            icon: Icons.email,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Balance
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bakiye',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          const Text(':  '),
                          Text(
                            '${currencyFormat.format(m.balance)} (A)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: m.balance > 0
                                  ? AppColors.error
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: m.status == MemberStatus.malik
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: m.status == MemberStatus.malik
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          m.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: m.status == MemberStatus.malik
                                ? AppColors.primary
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTable(
    BuildContext context,
    List<MemberTransaction> transactions,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                _TableHeader(text: 'Tarih', flex: 2),
                _TableHeader(text: 'Son Ödeme', flex: 2),
                _TableHeader(text: 'Blok', flex: 1),
                _TableHeader(text: 'No', flex: 1),
                _TableHeader(text: 'Açıklama', flex: 3),
                _TableHeader(text: 'Borç', flex: 2),
                _TableHeader(text: 'Ödenen', flex: 2),
                _TableHeader(text: 'Bakiye', flex: 2),
              ],
            ),
          ),

          // Summary row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                const Expanded(flex: 2, child: SizedBox()),
                const Expanded(flex: 1, child: SizedBox()),
                const Expanded(flex: 1, child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Toplam',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    currencyFormat.format(
                      transactions.fold<double>(0, (sum, t) => sum + t.debit),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    currencyFormat.format(
                      transactions.fold<double>(0, (sum, t) => sum + t.credit),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    currencyFormat.format(member.balance),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Transaction rows
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Henüz işlem kaydı bulunmuyor',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...transactions.map(
              (t) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        dateFormat.format(t.date),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        dateFormat.format(t.dueDate),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        t.block,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        t.unitNo,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        t.description,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        currencyFormat.format(t.debit),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        currencyFormat.format(t.credit),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        currencyFormat.format(t.balance),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionCardList(
    BuildContext context,
    List<MemberTransaction> transactions,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Henüz işlem kaydı bulunmuyor',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return Column(
      children: transactions.map((t) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(t.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${t.block} - ${t.unitNo}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          size: 14,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currencyFormat.format(t.debit),
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_downward,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currencyFormat.format(t.credit),
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Bakiye: ${currencyFormat.format(t.balance)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// --- Helper Widgets ---

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<_QuickAction> actions;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text('$label  :  ', style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: actions
                .map(
                  (a) => InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(a.icon, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          a.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;

  const _QuickAction({required this.label, required this.icon});
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(fontSize: 12, color: color)),
        style: OutlinedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.06),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color textColor;

  const _FinancialCard({
    required this.title,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: textColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;

  const _TableHeader({required this.text, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
