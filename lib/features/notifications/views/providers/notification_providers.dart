import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_services.dart';
import '../../data/models/notification_model.dart';
import '../../../auth/providers/auth_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  final service = ref.watch(notificationServiceProvider);
  return service.getNotificationsStream(user.id);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(userNotificationsProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
