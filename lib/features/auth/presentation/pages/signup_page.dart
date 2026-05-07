import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/refresh_shop_status_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../seller_shell/presentation/pages/seller_shell.dart';
import 'shop_access_gate_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AuthCubit _authCubit;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final repository = AuthRepositoryImpl();
    _authCubit = AuthCubit(
      signInUseCase: SignInUseCase(repository),
      signUpUseCase: SignUpUseCase(repository),
      refreshShopStatusUseCase: RefreshShopStatusUseCase(repository),
      signOutUseCase: SignOutUseCase(repository),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _authCubit.close();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _validationError = 'Please fill in all fields.';
      });
      return;
    }

    _authCubit.signUp(name: name, email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _authCubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.isSuccess != current.isSuccess ||
            previous.action != current.action,
        listener: (context, state) {
          if (!state.isSuccess || state.action != AuthAction.signUp) {
            return;
          }

          final status = state.status;
          final authResult = state.authResult;
          if (status == null || authResult == null) {
            return;
          }

          final isActive = status.isActive;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => isActive
                  ? const SellerShell()
                  : ShopAccessGatePage(
                      status: status,
                      shopName: authResult.shop.name,
                    ),
            ),
            (route) => false,
          );
        },
        builder: (context, state) {
          final colorScheme = Theme.of(context).colorScheme;
          final isLoading =
              state.isLoading && state.action == AuthAction.signUp;
          final errorText = _validationError ?? state.errorMessage;

          return Scaffold(
            appBar: AppBar(title: const Text('Create Shop Account')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Register your shop', style: AppTextStyle.h1),
                    const SizedBox(height: 10),
                    Text(
                      'Signup returns tokens, but the shop stays blocked until admin verification completes.',
                      style: AppTextStyle.bodyLarge.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      hint: 'My Cool Shop',
                      controller: _nameController,
                      prefixIcon: Icons.store_rounded,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      hint: 'shop@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      hint: 'SecurePassword123!',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _validationError = null;
                                });
                                _signUp();
                              },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create account'),
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
}
