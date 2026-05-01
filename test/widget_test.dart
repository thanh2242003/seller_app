import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seller_app/app/seller_app.dart';

void main() {
  testWidgets('shows seller splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SellerApp());

    expect(find.text('Seller App'), findsOneWidget);
    expect(find.byIcon(Icons.storefront_rounded), findsWidgets);
  });
}
