import '../../data/models/auth_models.dart';

enum AuthAction { none, signIn, signUp, refreshStatus, signOut }

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isSuccess,
    required this.action,
    this.errorMessage,
    this.status,
    this.authResult,
  });

  final bool isLoading;
  final bool isSuccess;
  final AuthAction action;
  final String? errorMessage;
  final AuthStatusModel? status;
  final AuthResultModel? authResult;

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      isSuccess: false,
      action: AuthAction.none,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isSuccess,
    AuthAction? action,
    String? errorMessage,
    bool clearError = false,
    AuthStatusModel? status,
    bool clearStatus = false,
    AuthResultModel? authResult,
    bool clearAuthResult = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      action: action ?? this.action,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      status: clearStatus ? null : (status ?? this.status),
      authResult: clearAuthResult ? null : (authResult ?? this.authResult),
    );
  }
}
