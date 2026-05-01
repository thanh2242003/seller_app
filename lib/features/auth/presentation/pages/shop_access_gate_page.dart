import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/app_session.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/refresh_shop_status_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../seller_shell/presentation/pages/seller_shell.dart';

class ShopAccessGatePage extends StatefulWidget {
  const ShopAccessGatePage({
    super.key,
    required this.status,
    required this.shopName,
  });

  final AuthStatusModel status;
  final String shopName;

  @override
  State<ShopAccessGatePage> createState() => _ShopAccessGatePageState();
}

class _ShopAccessGatePageState extends State<ShopAccessGatePage> {
  Future<void> _refreshStatus() async {
    await context.read<AuthCubit>().refreshStatus();
  }

  Future<void> _signOut() async {
    await context.read<AuthCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) {
        final repository = AuthRepositoryImpl();
        return AuthCubit(
          signInUseCase: SignInUseCase(repository),
          signUpUseCase: SignUpUseCase(repository),
          refreshShopStatusUseCase: RefreshShopStatusUseCase(repository),
          signOutUseCase: SignOutUseCase(repository),
        );
      },
      child: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.isSuccess != current.isSuccess ||
            previous.action != current.action,
        listener: (context, state) {
          if (state.isSuccess && state.action == AuthAction.refreshStatus) {
            final status = state.status;
            if (status != null && status.isActive) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const SellerShell()),
                (route) => false,
              );
            }
          }

          if (state.isSuccess && state.action == AuthAction.signOut) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          final statusFromSession = AppSession.instance.status == null
              ? null
              : AuthStatusModel(
                  status: AppSession.instance.status!,
                  isActive: AppSession.instance.isActive,
                  isBlocked: AppSession.instance.isBlocked,
                  isPending: AppSession.instance.isPending,
                  verify: AppSession.instance.isVerified,
                  verifiedAt: widget.status.verifiedAt,
                  verifiedBy: widget.status.verifiedBy,
                  blockedAt: widget.status.blockedAt,
                  blockedReason:
                      AppSession.instance.blockedReason ??
                      widget.status.blockedReason,
                );
          final status = state.status ?? statusFromSession ?? widget.status;
          final isRefreshing =
              state.isLoading && state.action == AuthAction.refreshStatus;
          final errorText = state.errorMessage;
          final colorScheme = Theme.of(context).colorScheme;
          final accentColor = status.isBlocked
              ? Colors.redAccent
              : status.isPending
              ? Colors.orange
              : colorScheme.primary;

          return Scaffold(
            appBar: AppBar(title: const Text('Shop Status')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: accentColor.withValues(alpha: 0.12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.shopName, style: AppTextStyle.h2),
                          const SizedBox(height: 8),
                          Text(
                            _statusTitle(status),
                            style: AppTextStyle.bodyLarge.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _statusDescription(status),
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(label: 'Status', value: status.status),
                    _InfoRow(
                      label: 'Verified',
                      value: status.verify ? 'Yes' : 'No',
                    ),
                    _InfoRow(
                      label: 'Blocked reason',
                      value: status.blockedReason.isEmpty
                          ? '-'
                          : status.blockedReason,
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isRefreshing ? null : _refreshStatus,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isRefreshing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Check status again'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _signOut,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Sign out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusTitle(AuthStatusModel status) {
    if (status.isBlocked) {
      return 'Blocked';
    }
    if (status.isPending) {
      return 'Pending verification';
    }
    return 'Active';
  }

  String _statusDescription(AuthStatusModel status) {
    if (status.isBlocked) {
      return status.blockedReason.isEmpty
          ? 'Your shop account is blocked by admin.'
          : 'Your shop account is blocked. Reason: ${status.blockedReason}';
    }
    if (status.isPending) {
      return 'Your shop account is waiting for admin verification.';
    }
    return 'Your shop is ready and can access all protected APIs.';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: AppTextStyle.buttonLarge),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyle.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
