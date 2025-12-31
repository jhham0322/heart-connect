import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import 'message_view_model.dart';

class MessageScreen extends ConsumerWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageListAsync = ref.watch(messageListProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.bgColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.rotateRight, size: 20, color: AppTheme.textSecondary),
            onPressed: () {
              ref.refresh(messageListProvider);
            },
          ),
        ],
      ),
      body: messageListAsync.when(
        data: (messages) {
          if (messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.envelopeOpen, size: 48, color: AppTheme.grayBtn),
                  SizedBox(height: 16),
                  Text(
                    "No messages from contacts.",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(messageListProvider);
            },
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = messages[index];
                return _buildMessageCard(context, ref, item);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, WidgetRef ref, MessageItem item) {
    return InkWell(
      onTap: () => _showDetailDialog(context, ref, item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.accentCoral.withOpacity(0.1),
                      child: Icon(FontAwesomeIcons.user, size: 14, color: AppTheme.accentCoral),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.contactName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.displayDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.message.body ?? "No content",
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, WidgetRef ref, MessageItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppTheme.bgColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.accentCoral.withOpacity(0.1),
                    child: Icon(FontAwesomeIcons.user, size: 18, color: AppTheme.accentCoral),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.contactName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (item.message.address != null && item.message.address != item.contactName)
                          Text(
                            item.message.address!,
                            style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatFullDate(item.message.date),
                  style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 12),
                ),
              ),
              const Divider(height: 32),
              
              // Body
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Text(
                    item.message.body ?? "No content",
                    style: const TextStyle(
                      fontSize: 16, 
                      height: 1.6, 
                      color: AppTheme.textPrimary
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close", style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.penToSquare, size: 16),
                    label: const Text("Write Card"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCoral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () async {
                      // 1. Save to history (Sync)
                      if (item.contact != null) {
                        await ref.read(messageActionsProvider).saveMessageToHistory(item.message, item.contact!);
                        
                        // 2. Navigate
                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          context.push('/write', extra: {
                            'contact': item.contact,
                            'originalMessage': item.message.body
                          });
                        }
                      } else {
                         Navigator.pop(context);
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("Cannot write card: Contact not found."))
                         );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}.${date.month}.${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
