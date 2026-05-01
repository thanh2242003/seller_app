import '../../../../core/services/app_session.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_models.dart';
import '../sources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    TokenStorage? tokenStorage,
  }) : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
       _tokenStorage = tokenStorage ?? TokenStorage();

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthFlowResult> signIn({
    required String email,
    required String password,
  }) async {
    final authResult = await _remoteDataSource.signIn(
      email: email,
      password: password,
    );
    await _saveAuthenticatedSession(authResult: authResult);
    final status = await refreshStatus();
    return (authResult: authResult, status: status);
  }

  @override
  Future<AuthFlowResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final authResult = await _remoteDataSource.signUp(
      name: name,
      email: email,
      password: password,
    );
    await _saveAuthenticatedSession(authResult: authResult);
    final status = await refreshStatus();
    return (authResult: authResult, status: status);
  }

  @override
  Future<AuthStatusModel> refreshStatus() async {
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

  Future<void> _saveAuthenticatedSession({
    required AuthResultModel authResult,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: authResult.tokens.accessToken,
      refreshToken: authResult.tokens.refreshToken,
    );
    await _tokenStorage.saveUserId(authResult.shop.id);

    AppSession.instance.setAuthenticated(
      userId: authResult.shop.id,
      shopName: authResult.shop.name,
      email: authResult.shop.email,
      status: authResult.shop.status,
      isVerified: authResult.shop.verify,
    );
  }
}
