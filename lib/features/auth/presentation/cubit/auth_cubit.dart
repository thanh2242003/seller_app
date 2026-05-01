import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/auth_models.dart';
import '../../domain/usecases/refresh_shop_status_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required RefreshShopStatusUseCase refreshShopStatusUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _signInUseCase = signInUseCase,
       _signUpUseCase = signUpUseCase,
       _refreshShopStatusUseCase = refreshShopStatusUseCase,
       _signOutUseCase = signOutUseCase,
       super(AuthState.initial());

  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final RefreshShopStatusUseCase _refreshShopStatusUseCase;
  final SignOutUseCase _signOutUseCase;

  Future<void> signIn({required String email, required String password}) async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        action: AuthAction.signIn,
        clearError: true,
      ),
    );

    try {
      final result = await _signInUseCase(email: email, password: password);
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          action: AuthAction.signIn,
          authResult: result.authResult,
          status: result.status,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          action: AuthAction.signIn,
          errorMessage: _toMessage(error),
        ),
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        action: AuthAction.signUp,
        clearError: true,
      ),
    );

    try {
      final result = await _signUpUseCase(
        name: name,
        email: email,
        password: password,
      );
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          action: AuthAction.signUp,
          authResult: result.authResult,
          status: result.status,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          action: AuthAction.signUp,
          errorMessage: _toMessage(error),
        ),
      );
    }
  }

  Future<void> refreshStatus() async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        action: AuthAction.refreshStatus,
        clearError: true,
      ),
    );

    try {
      final status = await _refreshShopStatusUseCase();
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          action: AuthAction.refreshStatus,
          status: status,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          action: AuthAction.refreshStatus,
          errorMessage: _toMessage(error),
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        action: AuthAction.signOut,
        clearError: true,
      ),
    );

    try {
      await _signOutUseCase();
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          action: AuthAction.signOut,
          clearError: true,
          clearStatus: true,
          clearAuthResult: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          action: AuthAction.signOut,
          errorMessage: _toMessage(error),
        ),
      );
    }
  }

  String _toMessage(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }
}
