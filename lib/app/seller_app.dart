import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/app_start/presentation/pages/app_start_screen.dart';

class SellerApp extends StatelessWidget {
  const SellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seller App',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: ThemeMode.system,
      home: const AppStartScreen(),
    );
  }
}
