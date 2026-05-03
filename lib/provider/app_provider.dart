import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../features/orders/presentation/cubit/orders_cubit.dart';
import '../features/shop_profile/presentation/cubit/shop_profile_cubit.dart';

// repositories & usecases
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/sign_in_usecase.dart';
import '../features/auth/domain/usecases/sign_up_usecase.dart';
import '../features/auth/domain/usecases/refresh_shop_status_usecase.dart';
import '../features/auth/domain/usecases/sign_out_usecase.dart';

import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/usecases/get_dashboard_usecase.dart';

import '../features/orders/data/repositories/orders_repository_impl.dart';
import '../features/orders/domain/usecases/get_orders_usecase.dart';

import '../features/shop_profile/data/repositories/shop_profile_repository_impl.dart';
import '../features/shop_profile/domain/usecases/get_shop_status_usecase.dart';
import '../features/shop_profile/domain/usecases/sign_out_usecase.dart';

/// A convenience widget that wraps the app with a `MultiBlocProvider`.
///
/// Example:
/// ```dart
/// runApp(AppProvider(
///   providers: [
///     BlocProvider(create: (_) => AuthCubit()),
///   ],
///   child: const MyApp(),
/// ));
/// ```
class AppProvider extends StatelessWidget {
  final Widget child;
  final List<BlocProvider> providers;

  const AppProvider({
    super.key,
    required this.child,
    this.providers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers.isEmpty ? appBlocProviders : providers,
      child: child,
    );
  }
}

/// Default list of `BlocProvider`s for the app features.
final List<BlocProvider> appBlocProviders = [
  BlocProvider<AuthCubit>(
    create: (_) {
      final repo = AuthRepositoryImpl();
      return AuthCubit(
        signInUseCase: SignInUseCase(repo),
        signUpUseCase: SignUpUseCase(repo),
        refreshShopStatusUseCase: RefreshShopStatusUseCase(repo),
        signOutUseCase: SignOutUseCase(repo),
      );
    },
  ),
  BlocProvider<DashboardCubit>(
    create: (_) {
      final repo = DashboardRepositoryImpl();
      return DashboardCubit(getDashboardUseCase: GetDashboardUseCase(repo));
    },
  ),
  BlocProvider<OrdersCubit>(
    create: (_) {
      final repo = OrdersRepositoryImpl();
      return OrdersCubit(getOrdersUseCase: GetOrdersUseCase(repo));
    },
  ),
  BlocProvider<ShopProfileCubit>(
    create: (_) {
      final repo = ShopProfileRepositoryImpl();
      return ShopProfileCubit(
        getShopStatusUseCase: GetShopStatusUseCase(repo),
        signOutUseCase: ShopProfileSignOutUseCase(repo),
      );
    },
  ),
];
