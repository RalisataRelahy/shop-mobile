import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  /// Permissions demandées au premier lancement
  static Future<void> requestInitialPermissions() async {
    final permissions = <Permission>[
      Permission.notification,
      Permission.locationWhenInUse,
    ];

    final statuses = await permissions.request();

    _logPermissions(statuses);

    await _handlePermanentlyDenied(statuses);
  }

  /// Demande une permission spécifique
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  /// Vérifie si une permission est déjà accordée
  static Future<bool> hasPermission(Permission permission) async {
    return await permission.isGranted;
  }

  /// Vérifie si la localisation est disponible
  static Future<bool> hasLocationPermission() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Vérifie si les notifications sont autorisées
  static Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await Permission.notification.isGranted;
    }
    return true;
  }

  /// Demande uniquement la localisation
  static Future<bool> requestLocationPermission() async {
    return requestPermission(Permission.locationWhenInUse);
  }

  /// Demande uniquement les notifications
  static Future<bool> requestNotificationPermission() async {
    return requestPermission(Permission.notification);
  }

  /// Ouvre les paramètres de l'application
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Gestion des permissions définitivement refusées
  static Future<void> _handlePermanentlyDenied(
      Map<Permission, PermissionStatus> statuses,
      ) async {
    final permanentlyDenied = statuses.entries.where(
          (entry) => entry.value.isPermanentlyDenied,
    );

    if (permanentlyDenied.isNotEmpty) {
      debugPrint(
        "Certaines permissions sont définitivement refusées.",
      );

      // Si tu veux ouvrir automatiquement les paramètres :
      await openAppSettings();
    }
  }

  /// Affichage des états des permissions (Debug uniquement)
  static void _logPermissions(
      Map<Permission, PermissionStatus> statuses,
      ) {
    for (final entry in statuses.entries) {
      debugPrint(
        "${entry.key.toString().split('.').last} : ${entry.value}",
      );
    }
  }
}