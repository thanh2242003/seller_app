import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/shop_profile_models.dart';
import '../../domain/usecases/get_shop_status_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'shop_profile_state.dart';

class ShopProfileCubit extends Cubit<ShopProfileState> {
  ShopProfileCubit({
    required GetShopStatusUseCase getShopStatusUseCase,
    required ShopProfileSignOutUseCase signOutUseCase,
  }) : _getShopStatusUseCase = getShopStatusUseCase,
       _signOutUseCase = signOutUseCase,
       super(ShopProfileState.initial());

  final GetShopStatusUseCase _getShopStatusUseCase;
  final ShopProfileSignOutUseCase _signOutUseCase;

  Future<void> load() async {
    emit(
      state.copyWith(isLoading: true, signOutSuccess: false, clearError: true),
    );

    try {
      final status = await _getShopStatusUseCase();
      emit(state.copyWith(isLoading: false, status: status, clearError: true));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> reload() => load();

  Future<void> signOut() async {
    emit(
      state.copyWith(
        isSigningOut: true,
        signOutSuccess: false,
        clearError: true,
      ),
    );

    try {
      await _signOutUseCase();
      emit(
        state.copyWith(
          isSigningOut: false,
          signOutSuccess: true,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSigningOut: false,
          signOutSuccess: false,
          errorMessage: _toMessage(error),
        ),
      );
    }
  }

  String _toMessage(Object error) {
    if (error is ShopProfileException) {
      return error.message;
    }
    return 'Failed to load shop status.';
  }
}
