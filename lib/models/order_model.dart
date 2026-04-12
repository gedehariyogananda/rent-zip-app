class OrderModel {
  final int? id;
  final int? userId;
  final String? codeBooking;
  final String? status;
  final String? qris;
  final String? total;
  final String? tglSewa;
  final String? tglPengembalian;
  final String? createdAt;
  final Map<String, dynamic>? user;
  final List<OrderItemModel>? items;

  OrderModel({
    this.id,
    this.userId,
    this.codeBooking,
    this.status,
    this.qris,
    this.total,
    this.tglSewa,
    this.tglPengembalian,
    this.createdAt,
    this.user,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      codeBooking: json['code_booking'] as String?,
      status: json['status'] as String?,
      qris: json['qris'] as String?,
      total: json['total']?.toString(),
      tglSewa: json['tgl_sewa'] as String?,
      tglPengembalian: json['tgl_pengembalian'] as String?,
      createdAt: json['created_at'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => OrderItemModel.fromJson(e))
                .toList()
          : null,
    );
  }
}

class OrderItemModel {
  final int? id;
  final int? orderId;
  final int? costumId;
  final int? pcs;
  final String? price;
  final OrderCostumModel? costum;

  OrderItemModel({
    this.id,
    this.orderId,
    this.costumId,
    this.pcs,
    this.price,
    this.costum,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      costumId: json['costum_id'] as int?,
      pcs: json['pcs'] as int?,
      price: json['price']?.toString(),
      costum: json['costum'] != null
          ? OrderCostumModel.fromJson(json['costum'])
          : null,
    );
  }
}

class OrderCostumModel {
  final int? id;
  final String? name;
  final String? photoUrl;
  final String? size;
  final String? priceday;

  OrderCostumModel({
    this.id,
    this.name,
    this.photoUrl,
    this.size,
    this.priceday,
  });

  factory OrderCostumModel.fromJson(Map<String, dynamic> json) {
    return OrderCostumModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      size: json['size'] as String?,
      priceday: json['priceday']?.toString(),
    );
  }
}
