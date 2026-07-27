import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Cette fonction s'exécute quand l'app est en arrière-plan ou fermée
  print("Message en arrière-plan reçu : ${message.notification?.title}");
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'notify-customer-channel',
    'Notifications Shop+',
    description: 'Canal pour les notifications de commandes et promotions',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> initialize() async {
    // 1. Demander les permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Configurer les notifications locales pour Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
     settings:initializationSettings, // Argument positionnel
      onDidReceiveNotificationResponse: (details) {
        // Gérer le clic sur la notification ici
        print("Notification cliquée : ${details.payload}");
      },
    );

    // 3. Gérer les messages quand l'application est ouverte (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Notification reçue au premier plan : ${message.notification?.title}");
      _showLocalNotification(message);
    });

    // 4. Gérer le clic sur la notification quand l'app est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Application ouverte via notification : ${message.notification?.title}");
    });

    // 5. Gérer le clic quand l'app était totalement fermée
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print("App démarrée via notification : ${initialMessage.notification?.title}");
    }

    // 6. Configurer le gestionnaire d'arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 7. Enregistrer le token FCM
    await _saveDeviceToken();
    
    // Écouter le rafraîchissement du token
    _fcm.onTokenRefresh.listen((newToken) => _updateTokenInSupabase(newToken));
  }

  Future<void> _saveDeviceToken() async {
    try {
      // On ajoute un timeout de 5s pour éviter de bloquer l'app au démarrage
      String? token = await _fcm.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (token != null) {
        print("FCM TOKEN : $token");
        await _updateTokenInSupabase(token);
      }
    } catch (e) {
      print("Erreur lors de la récupération du token FCM : $e");
    }
  }

  Future<void> _updateTokenInSupabase(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.from("customer_devices").upsert({
          "user_id": user.id,
          "fcm_token": token,
        },onConflict: 'user_id');
      } catch (e) {
        print("Erreur lors de l'enregistrement du token FCM : $e");
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        id:notification.hashCode, // Positional
        title:notification.title,    // Positional
        body:notification.body,     // Positional
        notificationDetails:NotificationDetails(   // Positional
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            icon: android.smallIcon,
          ),
        ),
        payload: message.data.toString(), // Named
      );
    }else return;
  }
}
