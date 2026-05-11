import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_models.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product_usecases.dart';
import 'product_state.dart';

class CreateProductCubit extends Cubit<ProductDetailState> {
  CreateProductCubit({
    required CreateProductUseCase createProductUseCase,
    ProductRepository? repository,
  }) : _createProductUseCase = createProductUseCase,
       _repository = repository ?? ProductRepositoryImpl(),
       super(ProductDetailState.initial()) {
    loadCategories();
  }

  final CreateProductUseCase _createProductUseCase;
  final ProductRepository _repository;

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(isLoading: false, categories: categories));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> createProduct({
    required String title,
    required String description,
    required int price,
    required int discountedPrice,
    required String categoryId,
    required int gender,
    required List<String> imagePaths,
    required List<String> sizes,
    required List<ProductColorModel> colors,
    required List<ProductVariantModel> variants,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final request = CreateProductRequest(
        title: title,
        description: description,
        price: price,
        discountedPrice: discountedPrice,
        categoryId: categoryId,
        gender: gender,
        imagePaths: imagePaths,
        sizes: sizes,
        colors: colors,
        variants: variants,
      );

      final product = await _createProductUseCase(request: request);
      emit(
        state.copyWith(
          isSaving: false,
          product: product,
          saveSuccess: true,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: _toMessage(error)));
    }
  }

  void reset() {
    emit(ProductDetailState.initial());
    loadCategories();
  }

  String _toMessage(Object error) {
    if (error is ProductException) {
      return error.message;
    }
    return error.toString();
  }
}
