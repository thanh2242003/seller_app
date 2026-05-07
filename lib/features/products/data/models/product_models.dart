class ProductException implements Exception {
  ProductException(this.code, this.message, [this.metadata]);

  final int code;
  final String message;
  final dynamic metadata;

  @override
  String toString() => message;
}

// ============ Product Color Model ============
class ProductColorModel {
  ProductColorModel({required this.title, required this.rgb});

  final String title;
  final List<int> rgb;

  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    return ProductColorModel(
      title: json['title']?.toString() ?? '',
      rgb:
          (json['rgb'] as List?)?.map((e) => _intValue(e)).toList() ??
          [0, 0, 0],
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'rgb': rgb};
}

// ============ Product Variant Model ============
class ProductVariantModel {
  ProductVariantModel({
    this.id,
    required this.color,
    required this.size,
    required this.stock,
  });

  final String? id;
  final String color;
  final String size;
  final int stock;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['_id']?.toString(),
      color: json['color']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      stock: _intValue(json['stock']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'color': color,
    'size': size,
    'stock': stock,
  };
}

// ============ Product Create/Update Request Model ============
class CreateProductRequest {
  CreateProductRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.categoryId,
    required this.gender,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.variants,
  });

  final String title;
  final String description;
  final int price;
  final int discountedPrice;
  final String categoryId;
  final int gender;
  final List<String> images;
  final List<String> sizes;
  final List<ProductColorModel> colors;
  final List<ProductVariantModel> variants;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'price': price,
    'discountedPrice': discountedPrice,
    'categoryId': categoryId,
    'gender': gender,
    'images': images,
    'sizes': sizes,
    'colors': colors.map((c) => c.toJson()).toList(),
    'variants': variants.map((v) => v.toJson()).toList(),
  };
}

// ============ Product Detail Model ============
class ProductDetailModel {
  ProductDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.shopId,
    required this.categoryId,
    required this.gender,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.variants,
    required this.isDraft,
    required this.isPublished,
    required this.isDeleted,
    required this.salesNumber,
    required this.ratings,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final int price;
  final int discountedPrice;
  final String shopId;
  final String categoryId;
  final int gender;
  final List<String> images;
  final List<String> sizes;
  final List<ProductColorModel> colors;
  final List<ProductVariantModel> variants;
  final bool isDraft;
  final bool isPublished;
  final bool isDeleted;
  final int salesNumber;
  final double ratings;
  final List<dynamic> reviews;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _intValue(json['price']),
      discountedPrice: _intValue(json['discountedPrice']),
      shopId: json['product_shop']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      gender: _intValue(json['gender']),
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      sizes: (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      colors: ((json['colors'] as List?) ?? [])
          .map((e) => ProductColorModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      variants: ((json['variants'] as List?) ?? [])
          .map(
            (e) => ProductVariantModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      isDraft: json['isDraft'] == true,
      isPublished: json['isPublished'] == true,
      isDeleted: json['isDeleted'] == true,
      salesNumber: _intValue(json['salesNumber']),
      ratings: _doubleValue(json['ratings']),
      reviews: json['reviews'] ?? [],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

// ============ Product Summary (for lists) ============
class ProductSummaryModel {
  ProductSummaryModel({
    required this.id,
    required this.title,
    required this.price,
    required this.discountedPrice,
    required this.shopId,
    required this.isDraft,
    required this.isPublished,
    required this.isDeleted,
    required this.variantCount,
    required this.salesNumber,
    required this.ratings,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int price;
  final int discountedPrice;
  final String shopId;
  final bool isDraft;
  final bool isPublished;
  final bool isDeleted;
  final int variantCount;
  final int salesNumber;
  final double ratings;
  final DateTime? createdAt;

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: _intValue(json['price']),
      discountedPrice: _intValue(json['discountedPrice']),
      shopId: json['product_shop']?.toString() ?? '',
      isDraft: json['isDraft'] == true,
      isPublished: json['isPublished'] == true,
      isDeleted: json['isDeleted'] == true,
      variantCount: _intValue(
        json['variants'] is List ? (json['variants'] as List).length : 0,
      ),
      salesNumber: _intValue(json['salesNumber']),
      ratings: _doubleValue(json['ratings']),
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

// ============ Product List Result ============
class ProductsListResultModel {
  ProductsListResultModel({required this.products, required this.pagination});

  final List<ProductSummaryModel> products;
  final PaginationModel pagination;

  factory ProductsListResultModel.fromJson(Map<String, dynamic> json) {
    List<ProductSummaryModel> productsList = [];
    PaginationModel pagination = PaginationModel.empty();

    final metadata = json['metadata'];

    // Case 1: metadata is directly an array (draft/published response)
    if (metadata is List) {
      productsList = metadata
          .map(
            (e) => ProductSummaryModel.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList();
    }
    // Case 2: metadata is an object with products and pagination (deleted response)
    else if (metadata is Map<String, dynamic>) {
      // Get products from metadata.products
      final metadataProducts = metadata['products'];
      if (metadataProducts is List) {
        productsList = metadataProducts
            .map(
              (e) => ProductSummaryModel.fromJson(
                Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
              ),
            )
            .toList();
      }

      // Get pagination from metadata.pagination
      final metadataPagination = metadata['pagination'];
      if (metadataPagination is Map<String, dynamic>) {
        pagination = PaginationModel.fromJson(metadataPagination);
      }
    }
    // Case 3: Fallback to direct products list (legacy format)
    else {
      final directProducts = json['products'];
      if (directProducts is List) {
        productsList = directProducts
            .map(
              (e) => ProductSummaryModel.fromJson(
                Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
              ),
            )
            .toList();
      }

      final directPagination = json['pagination'];
      if (directPagination is Map<String, dynamic>) {
        pagination = PaginationModel.fromJson(directPagination);
      }
    }

    return ProductsListResultModel(
      products: productsList,
      pagination: pagination,
    );
  }
}

// ============ Pagination Model ============
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
    // Safely extract values, handling both int and string types
    int parsePage = 1;
    int parseLimit = 10;
    int parseTotal = 0;
    int parsePages = 0;

    // Parse page
    final pageValue = json['page'];
    if (pageValue is String) {
      parsePage = int.tryParse(pageValue) ?? 1;
    } else if (pageValue is int) {
      parsePage = pageValue;
    } else if (pageValue is num) {
      parsePage = pageValue.toInt();
    }

    // Parse limit
    final limitValue = json['limit'];
    if (limitValue is String) {
      parseLimit = int.tryParse(limitValue) ?? 10;
    } else if (limitValue is int) {
      parseLimit = limitValue;
    } else if (limitValue is num) {
      parseLimit = limitValue.toInt();
    }

    // Parse total
    final totalValue = json['total'];
    if (totalValue is String) {
      parseTotal = int.tryParse(totalValue) ?? 0;
    } else if (totalValue is int) {
      parseTotal = totalValue;
    } else if (totalValue is num) {
      parseTotal = totalValue.toInt();
    }

    // Parse totalPages (API field name)
    final totalPagesValue = json['totalPages'] ?? json['pages'];
    if (totalPagesValue is String) {
      parsePages = int.tryParse(totalPagesValue) ?? 0;
    } else if (totalPagesValue is int) {
      parsePages = totalPagesValue;
    } else if (totalPagesValue is num) {
      parsePages = totalPagesValue.toInt();
    }

    return PaginationModel(
      page: parsePage,
      limit: parseLimit,
      total: parseTotal,
      pages: parsePages,
    );
  }

  factory PaginationModel.empty() {
    return PaginationModel(page: 1, limit: 10, total: 0, pages: 0);
  }
}

// ============ Category Model ============
class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.isActive,
  });

  final String id;
  final String name;
  final String? slug;
  final String? description;
  final bool? isActive;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      isActive: json['isActive'] as bool?,
    );
  }
}

// ============ Helper Functions ============
int _intValue(dynamic value) {
  if (value == null) {
    return 0;
  }
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  if (value is num) {
    return value.toInt();
  }
  // Fallback for any other type
  return int.tryParse(value.toString()) ?? 0;
}

double _doubleValue(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}
