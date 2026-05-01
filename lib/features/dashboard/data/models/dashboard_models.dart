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
    required this.lowStockProducts,
  });

  final int totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final Map<String, int> ordersByStatus;
  final List<TopSellingProductModel> topSellingProducts;
  final List<LowStockProductModel> lowStockProducts;

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsModel(
      totalRevenue: _intValue(json['totalRevenue']),
      totalOrders: _intValue(json['totalOrders']),
      totalProducts: _intValue(json['totalProducts']),
      totalCustomers: _intValue(json['totalCustomers']),
      ordersByStatus: Map<String, int>.fromEntries(
        (json['ordersByStatus'] as Map<String, dynamic>? ?? {}).entries.map(
          (entry) => MapEntry(entry.key, _intValue(entry.value)),
        ),
      ),
      topSellingProducts: ((json['topSellingProducts'] as List<dynamic>?) ?? [])
          .map(
            (item) => TopSellingProductModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      lowStockProducts: ((json['lowStockProducts'] as List<dynamic>?) ?? [])
          .map(
            (item) => LowStockProductModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
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

class TopSellingProductModel {
  TopSellingProductModel({
    required this.productId,
    required this.title,
    required this.totalSold,
    required this.revenue,
  });

  final String productId;
  final String title;
  final int totalSold;
  final int revenue;

  factory TopSellingProductModel.fromJson(Map<String, dynamic> json) {
    return TopSellingProductModel(
      productId: json['productId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      totalSold: DashboardMetricsModel._intValue(json['totalSold']),
      revenue: DashboardMetricsModel._intValue(json['revenue']),
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
      productId: json['productId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      currentStock: DashboardMetricsModel._intValue(json['currentStock']),
    );
  }
}
