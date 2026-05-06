class DashboardException implements Exception {
  DashboardException(this.code, this.message, [this.metadata]);

  final int code;
  final String message;
  final dynamic metadata;

  @override
  String toString() => message;
}

class DashboardMetricsModel {
  DashboardMetricsModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.ordersByStatus,
    required this.topSellingProducts,
    required this.lowStockInventory,
  });

  final int totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final Map<String, OrderStatusModel> ordersByStatus;
  final List<TopSellingProductModel> topSellingProducts;
  final List<LowStockProductModel> lowStockInventory;

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    final overview = _jsonMap(json['overview']);

    return DashboardMetricsModel(
      totalRevenue: _intValue(
        overview.containsKey('totalRevenue')
            ? overview['totalRevenue']
            : json['totalRevenue'],
      ),
      totalOrders: _intValue(
        overview.containsKey('totalOrders')
            ? overview['totalOrders']
            : json['totalOrders'],
      ),
      totalProducts: _intValue(
        overview.containsKey('totalProducts')
            ? overview['totalProducts']
            : json['totalProducts'],
      ),
      totalCustomers: _intValue(
        overview.containsKey('totalCustomers')
            ? overview['totalCustomers']
            : json['totalCustomers'],
      ),
      ordersByStatus: Map<String, OrderStatusModel>.fromEntries(
        (json['ordersByStatus'] as Map<String, dynamic>? ?? {}).entries.map(
          (entry) => MapEntry(
            entry.key,
            OrderStatusModel.fromJson(_jsonMap(entry.value)),
          ),
        ),
      ),
      topSellingProducts: ((json['topSellingProducts'] as List<dynamic>?) ?? [])
          .map(
            (item) => TopSellingProductModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      lowStockInventory:
          ((json['lowStockInventory'] as List<dynamic>?) ??
                  (json['lowStockProducts'] as List<dynamic>?) ??
                  [])
              .map(
                (item) => LowStockProductModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
    );
  }

  static Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
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

class OrderStatusModel {
  OrderStatusModel({required this.count, required this.revenue});

  final int count;
  final int revenue;

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      count: DashboardMetricsModel._intValue(json['count']),
      revenue: DashboardMetricsModel._intValue(json['revenue']),
    );
  }
}

class TopSellingProductModel {
  TopSellingProductModel({
    required this.productId,
    required this.title,
    required this.totalSold,
    required this.totalRevenue,
    required this.productImage,
  });

  final String productId;
  final String title;
  final int totalSold;
  final int totalRevenue;
  final String productImage;

  factory TopSellingProductModel.fromJson(Map<String, dynamic> json) {
    return TopSellingProductModel(
      productId:
          (json['_id'] ?? json['productId'] ?? json['id'])?.toString() ?? '',
      title: (json['productTitle'] ?? json['title'])?.toString() ?? '',
      totalSold: DashboardMetricsModel._intValue(json['totalSold']),
      totalRevenue: DashboardMetricsModel._intValue(
        json['totalRevenue'] ?? json['revenue'],
      ),
      productImage: json['productImage']?.toString() ?? '',
    );
  }
}

class LowStockProductModel {
  LowStockProductModel({
    required this.productId,
    required this.title,
    required this.currentStock,
  });

  final String productId;
  final String title;
  final int currentStock;

  factory LowStockProductModel.fromJson(Map<String, dynamic> json) {
    return LowStockProductModel(
      productId:
          (json['_id'] ?? json['productId'] ?? json['id'])?.toString() ?? '',
      title: (json['productTitle'] ?? json['title'])?.toString() ?? '',
      currentStock: DashboardMetricsModel._intValue(
        json['currentStock'] ?? json['stock'],
      ),
    );
  }
}
