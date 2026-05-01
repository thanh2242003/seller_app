import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/shop_profile_models.dart';
import '../../../../core/services/app_session.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/repositories/shop_profile_repository_impl.dart';
import '../../domain/usecases/get_shop_status_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../cubit/shop_profile_cubit.dart';
import '../cubit/shop_profile_state.dart';
import '../../../auth/presentation/pages/login_page.dart';

class ShopProfilePage extends StatefulWidget {
  const ShopProfilePage({super.key});

  @override
  State<ShopProfilePage> createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<ShopProfilePage> {
  Future<void> _reload(BuildContext context) {
    return context.read<ShopProfileCubit>().reload();
  }

  Future<void> _signOut(BuildContext context) {
    return context.read<ShopProfileCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShopProfileCubit>(
      create: (_) {
        final repository = ShopProfileRepositoryImpl();
        return ShopProfileCubit(
          getShopStatusUseCase: GetShopStatusUseCase(repository),
          signOutUseCase: ShopProfileSignOutUseCase(repository),
        )..load();
      },
      child: BlocConsumer<ShopProfileCubit, ShopProfileState>(
        listenWhen: (previous, current) =>
            previous.signOutSuccess != current.signOutSuccess,
        listener: (context, state) {
          if (!state.signOutSuccess) {
            return;
          }
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
        builder: (context, state) {
          final status = state.status;

          if (state.isLoading && status == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null && status == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Profile')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text(state.errorMessage!, style: AppTextStyle.bodyLarge),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _reload(context),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (status == null) {
            return const Scaffold(body: SizedBox.shrink());
          }

          final colorScheme = Theme.of(context).colorScheme;
          final accentColor = status.isBlocked
              ? Colors.redAccent
              : status.isPending
              ? Colors.orange
              : colorScheme.primary;

          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: RefreshIndicator(
              onRefresh: () => _reload(context),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor.withValues(alpha: 0.16),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppSession.instance.shopName,
                                style: AppTextStyle.h2,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _statusLabel(status),
                                style: AppTextStyle.bodyLarge.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingCard(
                    icon: Icons.email_rounded,
                    title: 'Shop email',
                    subtitle: AppSession.instance.email ?? '-',
                  ),
                  const SizedBox(height: 12),
                  _SettingCard(
                    icon: Icons.verified_rounded,
                    title: 'Verification',
                    subtitle: status.verify ? 'Verified' : 'Not verified',
                  ),
                  const SizedBox(height: 12),
                  _SettingCard(
                    icon: Icons.shield_rounded,
                    title: 'Current status',
                    subtitle: status.status,
                  ),
                  const SizedBox(height: 12),
                  if (status.isBlocked)
                    _SettingCard(
                      icon: Icons.block_rounded,
                      title: 'Blocked reason',
                      subtitle: status.blockedReason.isEmpty
                          ? '-'
                          : status.blockedReason,
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _reload(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Refresh status'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.isSigningOut
                          ? null
                          : () => _signOut(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign out'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(ShopProfileStatusModel status) {
    if (status.isBlocked) {
      return 'Blocked';
    }
    if (status.isPending) {
      return 'Pending verification';
    }
    return 'Active';
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.buttonLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
