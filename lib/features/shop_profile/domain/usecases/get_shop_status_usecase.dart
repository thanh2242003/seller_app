import '../../data/models/shop_profile_models.dart';
import '../repositories/shop_profile_repository.dart';

class GetShopStatusUseCase {
  GetShopStatusUseCase(this._repository);

  final ShopProfileRepository _repository;

  Future<ShopProfileStatusModel> call() {
    return _repository.getShopStatus();
  }
}
