import '../repositories/shop_profile_repository.dart';

class ShopProfileSignOutUseCase {
  ShopProfileSignOutUseCase(this._repository);

  final ShopProfileRepository _repository;

  Future<void> call() {
    return _repository.signOut();
  }
}
