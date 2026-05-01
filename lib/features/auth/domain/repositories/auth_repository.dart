import '../../data/models/auth_models.dart';

typedef AuthFlowResult = ({AuthResultModel authResult, AuthStatusModel status});

abstract class AuthRepository {
  Future<AuthFlowResult> signIn({
    required String email,
    required String password,
  });

  Future<AuthFlowResult> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthStatusModel> refreshStatus();

  Future<void> signOut();
}
