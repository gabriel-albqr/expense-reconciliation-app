import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_reconciliation_app/app/app.dart';

void main() {
  testWidgets('Home exibe secoes principais', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ExpenseReconciliationApp());

    expect(find.text('Controle de Despesas'), findsOneWidget);
    expect(find.text('Pessoas'), findsOneWidget);
    expect(find.text('Cartões'), findsOneWidget);
    expect(find.text('Compras'), findsOneWidget);
    expect(find.text('Resumo Mensal'), findsOneWidget);

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });
}
