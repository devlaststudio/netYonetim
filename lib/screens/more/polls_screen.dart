import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/poll_model.dart';
import '../../data/providers/app_provider.dart';
import '../../core/theme/app_theme.dart';

class PollsScreen extends StatelessWidget {
  const PollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final polls = context.watch<AppProvider>().polls;

    return Scaffold(
      appBar: AppBar(title: const Text('Anketler')),
      body: polls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.poll_outlined,
                    size: 64,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aktif anket bulunmuyor',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: polls.length,
              itemBuilder: (context, index) {
                return _PollCard(poll: polls[index]);
              },
            ),
    );
  }
}

class _PollCard extends StatefulWidget {
  final PollModel poll;

  const _PollCard({required this.poll});

  @override
  State<_PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<_PollCard> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final hasVoted = widget.poll.hasVoted;
    final totalVotes = widget.poll.totalVotes;
    final isExpired = widget.poll.endDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isExpired || !widget.poll.isActive
                    ? Colors.grey.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isExpired || !widget.poll.isActive ? 'Tamamlandı' : 'Aktif',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isExpired || !widget.poll.isActive
                      ? Colors.grey
                      : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title & Desc
            Text(
              widget.poll.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.poll.description,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Options
            ...widget.poll.options.map((option) {
              if (hasVoted) {
                // Result View
                final percent = totalVotes == 0
                    ? 0.0
                    : (option.voteCount / totalVotes);
                final isSelected = widget.poll.selectedOptionId == option.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option.text,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            '${(percent * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: Colors.grey.shade100,
                          color: isSelected ? AppColors.primary : Colors.grey,
                          minHeight: 8,
                        ),
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Sizin Seçiminiz',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              } else {
                // Voting View
                return RadioListTile<String>(
                  title: Text(option.text),
                  value: option.id,
                  groupValue: _selectedOption,
                  onChanged: isExpired
                      ? null
                      : (value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                );
              }
            }),

            const SizedBox(height: 16),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam $totalVotes oy',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                if (!hasVoted && !isExpired && widget.poll.isActive)
                  ElevatedButton(
                    onPressed: _selectedOption == null
                        ? null
                        : () {
                            context.read<AppProvider>().votePoll(
                              pollId: widget.poll.id,
                              optionId: _selectedOption!,
                            );
                          },
                    child: const Text('Oy Ver'),
                  ),
                if (hasVoted)
                  Text(
                    'Oylamaya katıldınız',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
