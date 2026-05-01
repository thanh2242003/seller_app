import '../../data/models/shop_profile_models.dart';

class ShopProfileState {
  const ShopProfileState({
    required this.isLoading,
    required this.isSigningOut,
    required this.signOutSuccess,
    this.errorMessage,
    this.status,
  });

  final bool isLoading;
  final bool isSigningOut;
  final bool signOutSuccess;
  final String? errorMessage;
  final ShopProfileStatusModel? status;

  factory ShopProfileState.initial() {
    return const ShopProfileState(
      isLoading: false,
      isSigningOut: false,
      signOutSuccess: false,
    );
  }

  ShopProfileState copyWith({
    bool? isLoading,
    bool? isSigningOut,
    bool? signOutSuccess,
    String? errorMessage,
    bool clearError = false,
    ShopProfileStatusModel? status,
  }) {
    return ShopProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      signOutSuccess: signOutSuccess ?? this.signOutSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      status: status ?? this.status,
    );
  }
}
