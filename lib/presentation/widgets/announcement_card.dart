import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart' as app_utils;
import '../../data/models/announcement_model.dart';
import 'pwd_badge.dart';

/// Card widget for displaying a single announcement
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
    this.onFavorite,
    this.onPlayVoice,
    this.isFavorite = false,
    this.showPwdBadge = true,
  });

  final AnnouncementModel announcement;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onPlayVoice;
  final bool isFavorite;
  final bool showPwdBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = announcement.parsedTime != null
        ? app_utils.AppDateUtils.formatRelative(announcement.parsedTime!)
        : announcement.time;

    // Enhanced color scheme for better visibility
    Color? cardColor;
    Color? borderColor;
    Color? priorityBgColor;
    Color? priorityTextColor;
    
    switch (announcement.priority.toLowerCase()) {
      case 'high':
      case 'emergency':
        cardColor = Colors.red.shade900.withOpacity(0.15);
        borderColor = Colors.red.shade700;
        priorityBgColor = Colors.red.shade700;
        priorityTextColor = Colors.white;
        break;
      case 'medium':
        cardColor = Colors.orange.shade900.withOpacity(0.15);
        borderColor = Colors.orange.shade700;
        priorityBgColor = Colors.orange.shade700;
        priorityTextColor = Colors.white;
        break;
      case 'low':
      default:
        cardColor = Colors.green.shade900.withOpacity(0.15);
        borderColor = Colors.green.shade700;
        priorityBgColor = Colors.green.shade700;
        priorityTextColor = Colors.white;
        break;
    }

    // Get announcement text with fallback
    final announcementText = announcement.speechRecognized.trim().isEmpty
        ? 'No announcement text available'
        : announcement.speechRecognized;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      elevation: announcement.priority.toLowerCase() != 'low' ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor ?? AppColors.cardDark.withOpacity(0.3), 
          width: announcement.priority.toLowerCase() != 'low' ? 2.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showPwdBadge && announcement.isPWD)
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: PwdBadge(),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced priority badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, 
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: priorityBgColor ?? AppColors.cardDark.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: borderColor?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    announcement.priority.toLowerCase() == 'high' || announcement.priority.toLowerCase() == 'emergency'
                                        ? Icons.priority_high
                                        : (announcement.priority.toLowerCase() == 'medium' 
                                           ? Icons.warning_amber_rounded
                                           : Icons.info_outline),
                                    size: 14,
                                    color: priorityTextColor ?? AppColors.textSecondaryDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    announcement.priority.toUpperCase(),
                                    style: TextStyle(
                                      color: priorityTextColor ?? AppColors.textSecondaryDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                timeStr,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onFavorite != null)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite ? AppColors.primary : null,
                      ),
                      onPressed: onFavorite,
                    ),
                  if (onPlayVoice != null)
                    Consumer(
                      builder: (context, ref, _) => IconButton(
                        icon: const Icon(Icons.volume_up_outlined),
                        onPressed: () {
                          AccessibilityHelper.vibrate(ref);
                          onPlayVoice!();
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              // Enhanced text formatting
              Text(
                announcementText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                  color: announcement.speechRecognized.trim().isEmpty
                      ? AppColors.textSecondaryDark
                      : null,
                ),
              ),
              if (announcement.ticket != null) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      icon: Icons.train,
                      label: 'Train ${announcement.ticket!.trainNo}',
                    ),
                    _Chip(
                      icon: Icons.layers,
                      label: 'Platform ${announcement.ticket!.platform}',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
