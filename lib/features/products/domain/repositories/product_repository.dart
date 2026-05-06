import '../../data/models/product_models.dart';

abstract class ProductRepository {
  // Get product lists
  Future<ProductsListResultModel> getDraftProducts({
    int page = 1,
    int limit = 10,
  });

  Future<ProductsListResultModel> getPublishedProducts({
    int page = 1,
    int limit = 10,
  });

  Future<ProductsListResultModel> getDeletedProducts({
    int page = 1,
    int limit = 10,
  });

  // Create product
  Future<ProductDetailModel> createProduct({
    required CreateProductRequest request,
  });

  // Get product detail
  Future<ProductDetailModel> getProductDetail(String productId);

  // Update product
  Future<ProductDetailModel> updateProduct({
    required String productId,
    required Map<String, dynamic> updates,
  });

  // Publish / Unpublish
  Future<ProductDetailModel> publishProduct(String productId);
  Future<ProductDetailModel> unpublishProduct(String productId);

  // Soft delete / Restore
  Future<ProductDetailModel> softDeleteProduct(String productId);
  Future<ProductDetailModel> restoreProduct(String productId);

  // Delete product
  Future<void> deleteProduct(String productId);
  Future<void> permanentlyDeleteProduct(String productId);
}
