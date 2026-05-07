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

  Future<AuthStatusModel?> restoreSession() async {
    final session = await _tokenStorage.loadSession();
    if (session == null) {
      return null;
    }

    AppSession.instance.setAuthenticated(
      userId: session.userId,
      shopName: session.shopName,
      email: session.email,
      status: session.status,
      isVerified: session.isVerified,
      blockedReason: session.blockedReason,
    );

    try {
      return await refreshStatus();
    } catch (error) {
      if (error is AuthException && error.code == 401) {
        final refreshed = await _remoteDataSource.refreshTokens();
        await _saveAuthenticatedSession(authResult: refreshed);
        return await refreshStatus();
      }
      await signOut();
      rethrow;
    }
  }

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
    try {
      final status = await _remoteDataSource.getShopStatus();
      AppSession.instance.updateStatus(
        status: status.status,
        isVerified: status.verify,
        blockedReason: status.blockedReason,
      );
      return status;
    } catch (error) {
      if (error is AuthException && error.code == 401) {
        final refreshed = await _remoteDataSource.refreshTokens();
        await _saveAuthenticatedSession(authResult: refreshed);
        final status = await _remoteDataSource.getShopStatus();
        AppSession.instance.updateStatus(
          status: status.status,
          isVerified: status.verify,
          blockedReason: status.blockedReason,
        );
        return status;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clearTokens();
    AppSession.instance.signOut();
  }

  Future<void> _saveAuthenticatedSession({
    required AuthResultModel authResult,
  }) async {
    await _tokenStorage.saveSession(
      accessToken: authResult.tokens.accessToken,
      refreshToken: authResult.tokens.refreshToken,
      userId: authResult.shop.id,
      shopName: authResult.shop.name,
      email: authResult.shop.email,
      status: authResult.shop.status,
      isVerified: authResult.shop.verify,
    );

    AppSession.instance.setAuthenticated(
      userId: authResult.shop.id,
      shopName: authResult.shop.name,
      email: authResult.shop.email,
      status: authResult.shop.status,
      isVerified: authResult.shop.verify,
    );
  }
}
