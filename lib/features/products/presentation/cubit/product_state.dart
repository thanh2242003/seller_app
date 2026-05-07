import '../../data/models/product_models.dart';

enum ProductTab { drafts, published, deleted }

class ProductsState {
  const ProductsState({
    required this.isLoading,
    required this.currentTab,
    this.errorMessage,
    this.draftResult,
    this.publishedResult,
    this.deletedResult,
  });

  final bool isLoading;
  final ProductTab currentTab;
  final String? errorMessage;
  final ProductsListResultModel? draftResult;
  final ProductsListResultModel? publishedResult;
  final ProductsListResultModel? deletedResult;

  factory ProductsState.initial() {
    return const ProductsState(
      isLoading: false,
      currentTab: ProductTab.published,
    );
  }

  ProductsState copyWith({
    bool? isLoading,
    ProductTab? currentTab,
    String? errorMessage,
    bool clearError = false,
    ProductsListResultModel? draftResult,
    ProductsListResultModel? publishedResult,
    ProductsListResultModel? deletedResult,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      currentTab: currentTab ?? this.currentTab,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      draftResult: draftResult ?? this.draftResult,
      publishedResult: publishedResult ?? this.publishedResult,
      deletedResult: deletedResult ?? this.deletedResult,
    );
  }

  ProductsListResultModel? get currentResult {
    switch (currentTab) {
      case ProductTab.drafts:
        return draftResult;
      case ProductTab.published:
        return publishedResult;
      case ProductTab.deleted:
        return deletedResult;
    }
  }
}

// ============ Product Detail State ============

class ProductDetailState {
  const ProductDetailState({
    required this.isLoading,
    required this.isSaving,
    this.errorMessage,
    this.product,
    this.saveSuccess = false,
    this.categories = const [],
  });

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final ProductDetailModel? product;
  final bool saveSuccess;
  final List<CategoryModel> categories;

  factory ProductDetailState.initial() {
    return const ProductDetailState(isLoading: false, isSaving: false);
  }

  ProductDetailState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    ProductDetailModel? product,
    bool? saveSuccess,
    List<CategoryModel>? categories,
  }) {
    return ProductDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      product: product ?? this.product,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      categories: categories ?? this.categories,
    );
  }
}
