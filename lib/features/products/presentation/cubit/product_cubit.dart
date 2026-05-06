import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_models.dart';
import '../../domain/usecases/product_usecases.dart';
import 'product_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit({
    required GetDraftProductsUseCase getDraftProductsUseCase,
    required GetPublishedProductsUseCase getPublishedProductsUseCase,
    required GetDeletedProductsUseCase getDeletedProductsUseCase,
  }) : _getDraftProductsUseCase = getDraftProductsUseCase,
       _getPublishedProductsUseCase = getPublishedProductsUseCase,
       _getDeletedProductsUseCase = getDeletedProductsUseCase,
       super(ProductsState.initial());

  final GetDraftProductsUseCase _getDraftProductsUseCase;
  final GetPublishedProductsUseCase _getPublishedProductsUseCase;
  final GetDeletedProductsUseCase _getDeletedProductsUseCase;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final drafts = await _getDraftProductsUseCase();
      final published = await _getPublishedProductsUseCase();

      emit(
        state.copyWith(
          isLoading: false,
          draftResult: drafts,
          publishedResult: published,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> reload() => load();

  Future<void> selectTab(ProductTab tab) async {
    emit(state.copyWith(currentTab: tab));

    try {
      switch (tab) {
        case ProductTab.drafts:
          if (state.draftResult == null) {
            emit(state.copyWith(isLoading: true));
            final result = await _getDraftProductsUseCase();
            emit(state.copyWith(isLoading: false, draftResult: result));
          }
        case ProductTab.published:
          if (state.publishedResult == null) {
            emit(state.copyWith(isLoading: true));
            final result = await _getPublishedProductsUseCase();
            emit(state.copyWith(isLoading: false, publishedResult: result));
          }
        case ProductTab.deleted:
          if (state.deletedResult == null) {
            emit(state.copyWith(isLoading: true));
            final result = await _getDeletedProductsUseCase();
            emit(state.copyWith(isLoading: false, deletedResult: result));
          }
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> loadMore() async {
    final currentResult = state.currentResult;
    if (currentResult == null) return;

    final nextPage = currentResult.pagination.page + 1;
    if (nextPage > currentResult.pagination.pages) return;

    try {
      ProductsListResultModel result;
      switch (state.currentTab) {
        case ProductTab.drafts:
          result = await _getDraftProductsUseCase(page: nextPage);
          final updated = ProductsListResultModel(
            products: [...currentResult.products, ...result.products],
            pagination: result.pagination,
          );
          emit(state.copyWith(draftResult: updated));
        case ProductTab.published:
          result = await _getPublishedProductsUseCase(page: nextPage);
          final updated = ProductsListResultModel(
            products: [...currentResult.products, ...result.products],
            pagination: result.pagination,
          );
          emit(state.copyWith(publishedResult: updated));
        case ProductTab.deleted:
          result = await _getDeletedProductsUseCase(page: nextPage);
          final updated = ProductsListResultModel(
            products: [...currentResult.products, ...result.products],
            pagination: result.pagination,
          );
          emit(state.copyWith(deletedResult: updated));
      }
    } catch (error) {
      emit(state.copyWith(errorMessage: _toMessage(error)));
    }
  }

  String _toMessage(Object error) {
    if (error is ProductException) {
      return error.message;
    }
    return error.toString();
  }
}

// ============ Product Detail Cubit ============

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({
    required GetProductDetailUseCase getProductDetailUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required PublishProductUseCase publishProductUseCase,
    required UnpublishProductUseCase unpublishProductUseCase,
    required SoftDeleteProductUseCase softDeleteProductUseCase,
    required RestoreProductUseCase restoreProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
    required PermanentlyDeleteProductUseCase permanentlyDeleteProductUseCase,
  }) : _getProductDetailUseCase = getProductDetailUseCase,
       _updateProductUseCase = updateProductUseCase,
       _publishProductUseCase = publishProductUseCase,
       _unpublishProductUseCase = unpublishProductUseCase,
       _softDeleteProductUseCase = softDeleteProductUseCase,
       _restoreProductUseCase = restoreProductUseCase,
       _deleteProductUseCase = deleteProductUseCase,
       _permanentlyDeleteProductUseCase = permanentlyDeleteProductUseCase,
       super(ProductDetailState.initial());

  final GetProductDetailUseCase _getProductDetailUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final PublishProductUseCase _publishProductUseCase;
  final UnpublishProductUseCase _unpublishProductUseCase;
  final SoftDeleteProductUseCase _softDeleteProductUseCase;
  final RestoreProductUseCase _restoreProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;
  final PermanentlyDeleteProductUseCase _permanentlyDeleteProductUseCase;

  Future<void> load(String productId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final product = await _getProductDetailUseCase(productId);
      emit(
        state.copyWith(isLoading: false, product: product, clearError: true),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final updated = await _updateProductUseCase(
        productId: productId,
        updates: updates,
      );
      emit(
        state.copyWith(
          isSaving: false,
          product: updated,
          saveSuccess: true,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> publishProduct(String productId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final updated = await _publishProductUseCase(productId);
      emit(
        state.copyWith(isSaving: false, product: updated, saveSuccess: true),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> unpublishProduct(String productId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final updated = await _unpublishProductUseCase(productId);
      emit(
        state.copyWith(isSaving: false, product: updated, saveSuccess: true),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> softDeleteProduct(String productId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final updated = await _softDeleteProductUseCase(productId);
      emit(
        state.copyWith(isSaving: false, product: updated, saveSuccess: true),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> restoreProduct(String productId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final updated = await _restoreProductUseCase(productId);
      emit(
        state.copyWith(isSaving: false, product: updated, saveSuccess: true),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _deleteProductUseCase(productId);
      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> permanentlyDeleteProduct(String productId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _permanentlyDeleteProductUseCase(productId);
      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: _toMessage(error)));
    }
  }

  String _toMessage(Object error) {
    if (error is ProductException) {
      return error.message;
    }
    return error.toString();
  }
}
