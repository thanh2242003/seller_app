import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_models.dart';
import '../../domain/usecases/product_usecases.dart';
import 'product_state.dart';

class CreateProductCubit extends Cubit<ProductDetailState> {
  CreateProductCubit({required CreateProductUseCase createProductUseCase})
    : _createProductUseCase = createProductUseCase,
      super(ProductDetailState.initial());

  final CreateProductUseCase _createProductUseCase;

  Future<void> createProduct({
    required String title,
    required String description,
    required int price,
    required int discountedPrice,
    required String categoryId,
    required int gender,
    required List<String> images,
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
        images: images,
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
  }

  String _toMessage(Object error) {
    if (error is ProductException) {
      return error.message;
    }
    return error.toString();
  }
}
