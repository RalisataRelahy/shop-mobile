class OrderItemModel {
  final String id;
  final String orderId;
  final String? productId;
  final String? comboId;
  final String itemName;
  final String? variantId;
  final String? notes;
  final int quantity;
  final int unitPrice;

  OrderItemModel({
    required this.id,
    required this.orderId,
    this.productId,
    this.comboId,
    required this.itemName,
    this.variantId,
    this.notes,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['products'] as Map<String, dynamic>?;
    final combo = json['combo'] as Map<String, dynamic>?;
    final variant = json['product_variants'] as Map<String,dynamic>?;
    return OrderItemModel(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      productId: json['product_id']?.toString(),
      comboId: json['combo_id']?.toString(),
      itemName: product?['name']?.toString() ?? combo?['name']?.toString() ?? "Article inconnu",
      variantId: json['variant_id']?.toString(),
      notes: variant?['name']?.toString() ?? json['notes']?.toString(),
      quantity: json['quantity'] ?? 1,
      unitPrice: int.tryParse(json['unit_price'].toString()) ?? 0,
    );
  }
  String get displayName {
    if(notes != null && notes!.isNotEmpty){
      return "$itemName ($notes)";
    }
    return itemName;
  }

  int get totalPrice => unitPrice * quantity;

  Map<String,dynamic> toJson(){
    return {
      "id": id,
      "order_id": orderId,
      "product_id": productId,
      "combo_id": comboId,
      "variant_id": variantId,
      "notes": notes,
      "quantity": quantity,
      "unit_price": unitPrice,
    };
  }
}