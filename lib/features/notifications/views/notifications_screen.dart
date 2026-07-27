import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';
import 'providers/notification_providers.dart';

import '../data/models/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Ids en cours de traitement (suppression / lecture) pour éviter le double-tap
  // et gérer le rollback visuel en cas d'échec réseau.
  final Set<String> _pendingIds = {};
  final Set<String> _optimisticallyDeletedIds = {};

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount non lue${unreadCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          notificationsAsync.when(
            data: (notifications) {
              final visible = _visibleNotifications(notifications);
              if (visible.isEmpty) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.mediumGrey),
                onSelected: (value) {
                  if (value == 'read_all') _markAllAsRead(context);
                  if (value == 'clear_all') _confirmClearAll(context);
                },
                itemBuilder: (context) => [
                  if (unreadCount > 0)
                    const PopupMenuItem(
                      value: 'read_all',
                      child: Row(
                        children: [
                          Icon(
                            Icons.done_all,
                            size: 20,
                            color: AppColors.darkGrey,
                          ),
                          SizedBox(width: 10),
                          Text('Tout marquer comme lu'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_sweep_outlined,
                          size: 20,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Tout vider', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          final visible = _visibleNotifications(notifications);

          if (visible.isEmpty) return _buildEmptyState();

          final sections = _groupByDate(visible);

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async => ref.invalidate(userNotificationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = sections[sectionIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        section.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mediumGrey,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    ...section.items.map((notification) {
                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red.shade400,
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => _deleteNotification(notification),
                        child: _NotificationTile(
                          notification: notification,
                          isPending: _pendingIds.contains(notification.id),
                          onTap: () => _markAsRead(notification),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          );
        },
        loading: () => _buildLoadingSkeleton(),
        error: (err, stack) => _buildErrorState(err),
      ),
    );
  }

  List<NotificationModel> _visibleNotifications(List<NotificationModel> all) {
    return all.where((n) => !_optimisticallyDeletedIds.contains(n.id)).toList();
  }

  List<_NotificationSection> _groupByDate(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayItems = <NotificationModel>[];
    final yesterdayItems = <NotificationModel>[];
    final olderItems = <NotificationModel>[];

    for (final n in notifications) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (d == today) {
        todayItems.add(n);
      } else if (d == yesterday) {
        yesterdayItems.add(n);
      } else {
        olderItems.add(n);
      }
    }

    return [
      if (todayItems.isNotEmpty)
        _NotificationSection('Aujourd\'hui', todayItems),
      if (yesterdayItems.isNotEmpty)
        _NotificationSection('Hier', yesterdayItems),
      if (olderItems.isNotEmpty)
        _NotificationSection('Plus ancien', olderItems),
    ];
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead || _pendingIds.contains(notification.id)) return;
    setState(() => _pendingIds.add(notification.id));
    try {
      await ref.read(notificationServiceProvider).markAsRead(notification.id);
    } catch (e) {
      if (mounted) _showErrorSnackBar('Impossible de marquer comme lu');
    } finally {
      if (mounted) setState(() => _pendingIds.remove(notification.id));
    }
  }

  Future<void> _markAllAsRead(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(notificationServiceProvider).markAllAsRead(user.id);
    } catch (e) {
      if (mounted) _showErrorSnackBar('Échec du marquage global');
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    setState(() => _optimisticallyDeletedIds.add(notification.id));
    try {
      await ref
          .read(notificationServiceProvider)
          .deleteNotification(notification.id);
    } catch (e) {
      // Rollback : on la refait apparaître si la suppression a échoué côté serveur
      if (mounted) {
        setState(() => _optimisticallyDeletedIds.remove(notification.id));
        _showErrorSnackBar('La suppression a échoué, réessaie');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Vider les notifications ?'),
        content: const Text(
          'Toutes vos notifications seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              try {
                await ref
                    .read(notificationServiceProvider)
                    .clearAllNotifications(user.id);
              } catch (e) {
                if (mounted)
                  _showErrorSnackBar('Échec de la suppression globale');
              }
            },
            child: const Text(
              'Vider tout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 56,
                color: AppColors.primaryGreen.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tu seras averti ici dès qu\'il y aura du nouveau.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mediumGrey.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.mediumGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger les notifications',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$err',
              style: const TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(userNotificationsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _shimmerBox(width: 40, height: 40, radius: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: double.infinity, height: 14, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 180, height: 12, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _NotificationSection {
  final String label;
  final List<NotificationModel> items;
  _NotificationSection(this.label, this.items);
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final bool isPending;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    this.isPending = false,
  });

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final timeStr = DateFormat('HH:mm').format(date);

    if (target == today) return timeStr;
    return DateFormat('dd/MM à HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return InkWell(
      onTap: isPending ? null : onTap,
      child: AnimatedOpacity(
        opacity: isPending ? 0.5 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isRead ? Colors.transparent : AppColors.primaryGreen,
                width: 3,
              ),
            ),
            color: isRead
                ? Colors.transparent
                : AppColors.primaryGreen.withOpacity(0.05),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isRead
                    ? AppColors.lightGrey
                    : AppColors.primaryGreen,
                child: Icon(
                  Icons.notifications_outlined,
                  color: isRead ? AppColors.mediumGrey : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _relativeDate(notification.createdAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
