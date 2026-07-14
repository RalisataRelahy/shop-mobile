// ============================================================================
// OrderModel — version corrigée avec gestion des statuts
// ----------------------------------------------------------------------------

import 'order_item_model.dart';

enum DeliveryMode {
  pickup,
  delivery;

  String get value => this == DeliveryMode.pickup ? 'pickup' : 'delivery';

  static DeliveryMode fromString(String? raw) {
    switch (raw) {
      case 'delivery':
      case 'livraison':
        return DeliveryMode.delivery;
      case 'pickup':
      case 'recuperation':
      default:
        return DeliveryMode.pickup;
    }
  }
}

enum OrderStatus {
  nonConfirmer('non_confirmer'),
  recue('reçue'),
  enPreparation('en_preparation'),
  enCoursDeLivraison('en_cours_de_livraison'),
  livree('livree'),
  annulee('annulee');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String? raw) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == raw,
      orElse: () => OrderStatus.recue,
    );
  }
}

class OrderModel {
  final String id;
  final String clientId;
  final String clientPhone;
  final String clientName;
  final OrderStatus statut;
  final DeliveryMode deliveryMode;

  /// Rempli uniquement si [deliveryMode] == DeliveryMode.delivery.
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;

  /// Rempli uniquement si [deliveryMode] == DeliveryMode.pickup.
  /// Ex: "Dès que possible" ou "19h30".
  final String? pickupTime;

  final String paymentMethod;
  final int totalPrice;
  final String? note;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.clientId,
    required this.clientPhone,
    required this.clientName,
    required this.statut,
    required this.deliveryMode,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.pickupTime,
    required this.paymentMethod,
    required this.totalPrice,
    this.note,
    this.createdAt,
    this.items = const [],
  });

  bool get isPickup => deliveryMode == DeliveryMode.pickup;
  bool get isDelivery => deliveryMode == DeliveryMode.delivery;

  // --------------------------------------------------------------------
  // Helpers de parsing (tolérants aux types venant du backend)
  // --------------------------------------------------------------------
  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static String? _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final v = json[key];
      if (v != null) return v.toString();
    }
    return null;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      clientId: _pick(json, ['client_id', 'clientId']) ?? '',
      clientPhone: _pick(json, ['client_phone', 'clientPhone']) ?? '',
      clientName: _pick(json,['client_name', 'clientName'])??'',
      statut: OrderStatus.fromString(json['statut']?.toString()),
      deliveryMode: DeliveryMode.fromString(
        _pick(json, ['delivery_mode', 'deliveryMode']),
      ),
      deliveryAddress: _pick(json, ['delivery_address', 'deliveryAddress']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      pickupTime: _pick(json, ['pickup_time', 'pickupTime']),
      paymentMethod: _pick(json, ['payment_method', 'paymentMethod']) ?? '',
      totalPrice: _parseInt(
        json['total_price'] ?? json['totalPrice'],
      ),
      note: json['notes']?.toString() ?? json['note']?.toString(),
      createdAt: _parseDateTime(
        json['created_at'] ?? json['createdAt'],
      ),
      items: (json['order_items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_phone': clientPhone,
      'client_name':clientName,
      'statut': statut.value,
      'delivery_mode': deliveryMode.value,
      'delivery_address': deliveryAddress,
      'latitude': latitude,
      'longitude': longitude,
      'pickup_time': pickupTime,
      'payment_method': paymentMethod,
      'total_price': totalPrice,
      'notes': note,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? clientId,
    String? clientPhone,
    String? clientName,
    OrderStatus? statut,
    DeliveryMode? deliveryMode,
    String? deliveryAddress,
    double? latitude,
    double? longitude,
    String? pickupTime,
    String? paymentMethod,
    int? totalPrice,
    String? note,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientPhone: clientPhone ?? this.clientPhone,
      clientName: clientName??this.clientName,
      statut: statut ?? this.statut,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pickupTime: pickupTime ?? this.pickupTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalPrice: totalPrice ?? this.totalPrice,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderModel &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'OrderModel(id: $id, mode: ${deliveryMode.value}, total: $totalPrice, statut: ${statut.value})';
}
