import 'package:flutter_test/flutter_test.dart';

import 'package:expense_reconciliation_app/app/app.dart';

void main() {
  testWidgets('Home exibe secoes principais', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseReconciliationApp());

    expect(find.text('Reconciliação de Despesas'), findsOneWidget);
    expect(find.text('Pessoas'), findsOneWidget);
    expect(find.text('Cartões'), findsOneWidget);
    expect(find.text('Compras'), findsOneWidget);
    expect(find.text('Resumo Mensal'), findsOneWidget);
  });
}
