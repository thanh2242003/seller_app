class OrdersException implements Exception {
  OrdersException(this.code, this.message, [this.metadata]);

  final int code;
  final String message;
  final dynamic metadata;

  @override
  String toString() => message;
}

class OrdersResultModel {
  OrdersResultModel({required this.orders, required this.pagination});

  final List<OrderSummaryModel> orders;
  final PaginationModel pagination;

  factory OrdersResultModel.fromJson(Map<String, dynamic> json) {
    return OrdersResultModel(
      orders: ((json['orders'] as List<dynamic>?) ?? [])
          .map(
            (item) => OrderSummaryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      pagination: PaginationModel.fromJson(
        Map<String, dynamic>.from(json['pagination'] as Map),
      ),
    );
  }
}

class PaginationModel {
  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  final int page;
  final int limit;
  final int total;
  final int pages;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: _intValue(json['page']),
      limit: _intValue(json['limit']),
      total: _intValue(json['total']),
      pages: _intValue(json['pages']),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class OrderSummaryModel {
  OrderSummaryModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.status,
    required this.items,
    required this.finalPrice,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String shopId;
  final String status;
  final List<OrderSummaryItemModel> items;
  final int finalPrice;
  final String address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      items: ((json['items'] as List<dynamic>?) ?? [])
          .map(
            (item) => OrderSummaryItemModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      finalPrice: _intValue(json['finalPrice']),
      address: json['address']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class OrderSummaryItemModel {
  OrderSummaryItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  final String productId;
  final int quantity;
  final int price;

  factory OrderSummaryItemModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryItemModel(
      productId: json['productId']?.toString() ?? '',
      quantity: OrderSummaryModel._intValue(json['quantity']),
      price: OrderSummaryModel._intValue(json['price']),
    );
  }
}

class OrderDetailModel {
  OrderDetailModel({
    required this.id,
    required this.customer,
    required this.receiverName,
    required this.receiverPhone,
    required this.shopId,
    required this.status,
    required this.items,
    required this.finalPrice,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final OrderCustomerModel customer;
  final String receiverName;
  final String receiverPhone;
  final String shopId;
  final String status;
  final List<OrderDetailItemModel> items;
  final int finalPrice;
  final String address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['_id']?.toString() ?? '',
      customer: OrderCustomerModel.fromJson(
        Map<String, dynamic>.from(json['userId'] as Map),
      ),
      receiverName: json['receiverName']?.toString() ?? '',
      receiverPhone: json['receiverPhone']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      items: ((json['items'] as List<dynamic>?) ?? [])
          .map(
            (item) => OrderDetailItemModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      finalPrice: OrderSummaryModel._intValue(json['finalPrice']),
      address: json['address']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class OrderCustomerModel {
  OrderCustomerModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  final String id;
  final String name;
  final String phone;

  factory OrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return OrderCustomerModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class OrderDetailItemModel {
  OrderDetailItemModel({
    required this.product,
    required this.quantity,
    required this.color,
    required this.size,
  });

  final OrderProductModel product;
  final int quantity;
  final String color;
  final String size;

  factory OrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailItemModel(
      product: OrderProductModel.fromJson(
        json['productId'] is Map
            ? Map<String, dynamic>.from(json['productId'] as Map)
            : <String, dynamic>{'id': json['productId']?.toString() ?? ''},
      ),
      quantity: OrderSummaryModel._intValue(json['quantity']),
      color: json['color']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
    );
  }
}

class OrderProductModel {
  OrderProductModel({
    required this.id,
    required this.title,
    required this.images,
    required this.price,
  });

  final String id;
  final String title;
  final List<String> images;
  final int price;

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      images: ((json['images'] as List<dynamic>?) ?? [])
          .map((item) => item.toString())
          .toList(),
      price: OrderSummaryModel._intValue(json['price']),
    );
  }
}
