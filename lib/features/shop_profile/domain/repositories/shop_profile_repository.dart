import '../../data/models/shop_profile_models.dart';

abstract class ShopProfileRepository {
  Future<ShopProfileStatusModel> getShopStatus();

  Future<void> signOut();
}
