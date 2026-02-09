import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/ticket_model.dart';
import '../../data/providers/app_provider.dart';
import 'package:intl/intl.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Taleplerim')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Talep'),
      ),
      body: provider.tickets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz talep yok',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk talebinizi oluşturun',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateTicketSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Talep Oluştur'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 100,
              ),
              itemCount: provider.tickets.length,
              itemBuilder: (context, index) {
                final ticket = provider.tickets[index];
                return _TicketCard(
                  ticket: ticket,
                  onTap: () => _showTicketDetail(context, ticket),
                );
              },
            ),
    );
  }

  void _showCreateTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _CreateTicketSheet(),
    );
  }

  void _showTicketDetail(BuildContext context, TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TicketDetailSheet(ticket: ticket),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  Color get statusColor {
    switch (ticket.status) {
      case TicketStatus.open:
        return AppColors.info;
      case TicketStatus.inProgress:
        return AppColors.warning;
      case TicketStatus.resolved:
        return AppColors.success;
      case TicketStatus.closed:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        ticket.categoryDisplayName.substring(0, 2),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${ticket.categoryDisplayName} • #${ticket.id.split('-').last}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      ticket.statusDisplayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                      'tr_TR',
                    ).format(ticket.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (ticket.comments.isNotEmpty) ...[
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ticket.comments.length} yorum',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTicketSheet extends StatefulWidget {
  const _CreateTicketSheet();

  @override
  State<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<_CreateTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketCategory _selectedCategory = TicketCategory.ariza;
  TicketPriority _selectedPriority = TicketPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTicket() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();
      await provider.createTicket(
        category: _selectedCategory,
        priority: _selectedPriority,
        title: _titleController.text,
        description: _descriptionController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Talep oluşturuldu ✅'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Yeni Talep Oluştur',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Category
              Text('Kategori', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TicketCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  String label;
                  switch (category) {
                    case TicketCategory.ariza:
                      label = '🔧 Arıza';
                      break;
                    case TicketCategory.temizlik:
                      label = '🧹 Temizlik';
                      break;
                    case TicketCategory.guvenlik:
                      label = '🔒 Güvenlik';
                      break;
                    case TicketCategory.oneri:
                      label = '💡 Öneri';
                      break;
                    case TicketCategory.sikayet:
                      label = '⚠️ Şikayet';
                      break;
                    case TicketCategory.diger:
                      label = '📝 Diğer';
                      break;
                  }
                  return FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Priority
              Text('Öncelik', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TicketPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  String label;
                  Color color;
                  switch (priority) {
                    case TicketPriority.low:
                      label = 'Düşük';
                      color = AppColors.textSecondary;
                      break;
                    case TicketPriority.medium:
                      label = 'Normal';
                      color = AppColors.info;
                      break;
                    case TicketPriority.high:
                      label = 'Yüksek';
                      color = AppColors.warning;
                      break;
                    case TicketPriority.urgent:
                      label = 'Acil';
                      color = AppColors.error;
                      break;
                  }
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: color.withValues(alpha: 0.2),
                    labelStyle: TextStyle(color: isSelected ? color : null),
                    onSelected: (_) {
                      setState(() => _selectedPriority = priority);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Kısa bir başlık girin',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Detaylı açıklama yazın',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _createTicket,
                  child: const Text('Talep Oluştur'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketDetailSheet extends StatefulWidget {
  final TicketModel ticket;

  const _TicketDetailSheet({required this.ticket});

  @override
  State<_TicketDetailSheet> createState() => _TicketDetailSheetState();
}

class _TicketDetailSheetState extends State<_TicketDetailSheet> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final provider = context.read<AppProvider>();
      await provider.addTicketComment(
        widget.ticket.id,
        _commentController.text,
      );
      _commentController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final ticket = provider.tickets.firstWhere(
      (t) => t.id == widget.ticket.id,
      orElse: () => widget.ticket,
    );

    Color statusColor;
    switch (ticket.status) {
      case TicketStatus.open:
        statusColor = AppColors.info;
        break;
      case TicketStatus.inProgress:
        statusColor = AppColors.warning;
        break;
      case TicketStatus.resolved:
        statusColor = AppColors.success;
        break;
      case TicketStatus.closed:
        statusColor = AppColors.textSecondary;
        break;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        ticket.statusDisplayName,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#${ticket.id.split('-').last}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ticket.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${ticket.categoryDisplayName} • ${ticket.priorityDisplayName} öncelik',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormat(
                    'dd MMMM yyyy, HH:mm',
                    'tr_TR',
                  ).format(ticket.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // Comments
          Expanded(
            child: ticket.comments.isEmpty
                ? Center(
                    child: Text(
                      'Henüz yorum yok',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: ticket.comments.length,
                    itemBuilder: (context, index) {
                      final comment = ticket.comments[index];
                      return _CommentBubble(comment: comment);
                    },
                  ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Yorum yazın...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final TicketComment comment;

  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: comment.isStaff
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.userName,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: comment.isStaff ? AppColors.primary : null,
                ),
              ),
              if (comment.isStaff) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Yönetim',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                DateFormat('dd MMM, HH:mm').format(comment.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content),
        ],
      ),
    );
  }
}
