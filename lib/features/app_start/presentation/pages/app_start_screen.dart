import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/app_session.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/presentation/pages/shop_access_gate_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../seller_shell/presentation/pages/seller_shell.dart';
import 'onboarding_page.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), () {
      unawaited(_routeNext());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _routeNext() async {
    if (!mounted) {
      return;
    }

    final repository = AuthRepositoryImpl();
    AuthStatusModel? status;

    try {
      status = await repository.restoreSession();
    } catch (_) {
      status = null;
    }

    Widget nextPage;
    if (!AppSession.instance.isAuthenticated || status == null) {
      nextPage = const OnboardingPage();
    } else if (status.isActive) {
      nextPage = const SellerShell();
    } else {
      nextPage = ShopAccessGatePage(
        status: status,
        shopName: AppSession.instance.shopName,
      );
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => nextPage));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.12),
              AppColors.lightBackground,
              const Color(0xFFF4F7F5),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text('Seller App', style: AppTextStyle.h1),
              const SizedBox(height: 8),
              Text(
                'Manage orders, products and notifications in one place.',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
