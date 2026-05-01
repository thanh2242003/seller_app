import '../models/shop_profile_models.dart';
import '../sources/shop_profile_remote_data_source.dart';
import '../../../../core/services/app_session.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/shop_profile_repository.dart';

class ShopProfileRepositoryImpl implements ShopProfileRepository {
  ShopProfileRepositoryImpl({
    ShopProfileRemoteDataSource? remoteDataSource,
    TokenStorage? tokenStorage,
  }) : _remoteDataSource = remoteDataSource ?? ShopProfileRemoteDataSource(),
       _tokenStorage = tokenStorage ?? TokenStorage();

  final ShopProfileRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<ShopProfileStatusModel> getShopStatus() async {
    final status = await _remoteDataSource.getShopStatus();
    AppSession.instance.updateStatus(
      status: status.status,
      isVerified: status.verify,
      blockedReason: status.blockedReason,
    );
    return status;
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clearTokens();
    AppSession.instance.signOut();
  }
}
