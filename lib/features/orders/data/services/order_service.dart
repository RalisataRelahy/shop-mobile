import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shop_good/features/orders/data/models/order_model.dart';
import 'package:shop_good/features/cart/data/models/cart_item_model.dart';
import 'package:shop_good/features/orders/data/models/order_item_model.dart';

import '../../../menu/data/models/menu_models.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createOrder(OrderModel order, List<CartItemModel> items) async {
    try {
      // 1. Créer la commande principale
      final orderResponse = await _supabase
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();

      final String orderId = orderResponse['id'];

      // 2. Créer les lignes de commande (items)
      final itemsData = items.map((item) {
        final product = item.item;
        String productId = product.cartId;
        String? variantId;
        String noteValue = ""; // Par défaut vide pour respecter la contrainte NOT NULL

        // Si c'est un produit avec variante, on extrait les infos
        if (product is MenuVariantCartItem) {
          productId = product.menu.id;
          variantId = product.variant.id;
          noteValue = product.variant.name;
        }

        return {
          'order_id': orderId,
          'product_id': productId,
          'variant_id': variantId,
          'quantity': item.quantity,
          'unit_price': product.cartPrice,
          'notes': noteValue,
        };
      }).toList();

      await _supabase.from('order_items').insert(itemsData);
    } catch (e) {
      print('ERREUR CREATE_ORDER: $e');
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('client_id', userId)
        .order('created_at')
        .map((data) => data.map((json) => OrderModel.fromJson(json)).toList());
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      // Jointure avec la table products pour récupérer le nom et le prix
      final response = await _supabase
          .from('order_items')
          .select('''
      *,
      products(name),
      variante:variant_id(id,name,price),
      combo:combo_id(id,name,image_url)
    ''')
          .eq('order_id', orderId);
      print("Reponse==================$response");
      return (response as List)
          .map((json) => OrderItemModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des articles: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _supabase
          .from('orders')
          .update({'statut': status.value})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }
}
