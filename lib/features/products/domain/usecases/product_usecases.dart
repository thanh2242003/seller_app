import '../../data/models/product_models.dart';
import '../repositories/product_repository.dart';

class GetDraftProductsUseCase {
  GetDraftProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductsListResultModel> call({int page = 1, int limit = 10}) {
    return _repository.getDraftProducts(page: page, limit: limit);
  }
}

class GetPublishedProductsUseCase {
  GetPublishedProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductsListResultModel> call({int page = 1, int limit = 10}) {
    return _repository.getPublishedProducts(page: page, limit: limit);
  }
}

class GetDeletedProductsUseCase {
  GetDeletedProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductsListResultModel> call({int page = 1, int limit = 10}) {
    return _repository.getDeletedProducts(page: page, limit: limit);
  }
}

class CreateProductUseCase {
  CreateProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductDetailModel> call({required CreateProductRequest request}) {
    return _repository.createProduct(request: request);
  }
}

class GetProductDetailUseCase {
  GetProductDetailUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductDetailModel> call(String productId) {
    return _repository.getProductDetail(productId);
  }
}

class UpdateProductUseCase {
  UpdateProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductDetailModel> call({
    required String productId,
    required Map<String, dynamic> updates,
  }) {
    return _repository.updateProduct(productId: productId, updates: updates);
  }
}

class PublishProductUseCase {
  PublishProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductDetailModel> call(String productId) {
    return _repository.publishProduct(productId);
  }
}

class UnpublishProductUseCase {
  UnpublishProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductDetailModel> call(String productId) {
    return _repository.unpublishProduct(productId);
  }
}

class SoftDeleteProductUseCase {
  SoftDeleteProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductDetailModel> call(String productId) {
    return _repository.softDeleteProduct(productId);
  }
}

class RestoreProductUseCase {
  RestoreProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<ProductDetailModel> call(String productId) {
    return _repository.restoreProduct(productId);
  }
}

class DeleteProductUseCase {
  DeleteProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<void> call(String productId) {
    return _repository.deleteProduct(productId);
  }
}

class PermanentlyDeleteProductUseCase {
  PermanentlyDeleteProductUseCase(this._repository);
  final ProductRepository _repository;

  Future<void> call(String productId) {
    return _repository.permanentlyDeleteProduct(productId);
  }
}
