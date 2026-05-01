import '../../data/models/auth_models.dart';
import '../repositories/auth_repository.dart';

class RefreshShopStatusUseCase {
  RefreshShopStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthStatusModel> call() {
    return _repository.refreshStatus();
  }
}
