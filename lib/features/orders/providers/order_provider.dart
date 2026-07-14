import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/orders/data/services/order_service.dart';
import 'package:shop_good/features/orders/data/models/order_model.dart';
import 'package:shop_good/features/cart/data/models/cart_item_model.dart';

import 'package:shop_good/features/orders/data/models/order_item_model.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(orderServiceProvider).getUserOrdersStream(user.id);
});

final orderItemsProvider = FutureProvider.family<List<OrderItemModel>, String>((ref, orderId) async {
  return ref.watch(orderServiceProvider).getOrderItems(orderId);
});

final orderControllerProvider = AsyncNotifierProvider<OrderController, void>(() {
  return OrderController();
});

class OrderController extends AsyncNotifier<void> {
  late final OrderService _service;

  @override
  Future<void> build() async {
    _service = ref.watch(orderServiceProvider);
  }

  Future<void> placeOrder({
    required OrderModel order,
    required List<CartItemModel> items,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.createOrder(order, items));
  }
  Future<void> canceledOrder({
    required OrderModel order,
    required OrderStatus status,
  })async{
    state=const AsyncLoading();
    state=await AsyncValue.guard(()=>_service.updateOrderStatus(order.id, status));
}
}
