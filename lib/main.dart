import 'package:flutter/material.dart';

import 'app/seller_app.dart';
import 'provider/app_provider.dart';

void main() {
  runApp(const AppProvider(child: SellerApp()));
}
