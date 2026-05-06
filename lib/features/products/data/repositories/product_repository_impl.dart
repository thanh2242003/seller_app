import '../models/product_models.dart';
import '../sources/products_remote_data_source.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({ProductsRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ProductsRemoteDataSource();

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<ProductsListResultModel> getDraftProducts({
    int page = 1,
    int limit = 10,
  }) {
    return _remoteDataSource.getDraftProducts(page: page, limit: limit);
  }

  @override
  Future<ProductsListResultModel> getPublishedProducts({
    int page = 1,
    int limit = 10,
  }) {
    return _remoteDataSource.getPublishedProducts(page: page, limit: limit);
  }

  @override
  Future<ProductsListResultModel> getDeletedProducts({
    int page = 1,
    int limit = 10,
  }) {
    return _remoteDataSource.getDeletedProducts(page: page, limit: limit);
  }

  @override
  Future<ProductDetailModel> createProduct({
    required CreateProductRequest request,
  }) {
    return _remoteDataSource.createProduct(request: request);
  }

  @override
  Future<ProductDetailModel> getProductDetail(String productId) {
    return _remoteDataSource.getProductDetail(productId);
  }

  @override
  Future<ProductDetailModel> updateProduct({
    required String productId,
    required Map<String, dynamic> updates,
  }) {
    return _remoteDataSource.updateProduct(
      productId: productId,
      updates: updates,
    );
  }

  @override
  Future<ProductDetailModel> publishProduct(String productId) {
    return _remoteDataSource.publishProduct(productId);
  }

  @override
  Future<ProductDetailModel> unpublishProduct(String productId) {
    return _remoteDataSource.unpublishProduct(productId);
  }

  @override
  Future<ProductDetailModel> softDeleteProduct(String productId) {
    return _remoteDataSource.softDeleteProduct(productId);
  }

  @override
  Future<ProductDetailModel> restoreProduct(String productId) {
    return _remoteDataSource.restoreProduct(productId);
  }

  @override
  Future<void> deleteProduct(String productId) {
    return _remoteDataSource.deleteProduct(productId);
  }

  @override
  Future<void> permanentlyDeleteProduct(String productId) {
    return _remoteDataSource.permanentlyDeleteProduct(productId);
  }
}
