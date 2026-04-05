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
    expect(find.text('Resumo'), findsOneWidget);
    await tester.drag(find.byType(GridView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('Liquidação'), findsOneWidget);

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });

  testWidgets('People permite adicionar e remover pessoa', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ExpenseReconciliationApp());

    await tester.tap(find.text('Pessoas'));
    await tester.pumpAndSettle();

    expect(find.text('Pessoas'), findsOneWidget);
    expect(find.text('Nenhuma pessoa adicionada ainda.'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsNothing);
    expect(find.text('Nenhuma pessoa adicionada ainda.'), findsOneWidget);
  });

  testWidgets('Cartoes usa pessoas cadastradas para vincular dono', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ExpenseReconciliationApp());

    await tester.tap(find.text('Pessoas'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cartões'));
    await tester.pumpAndSettle();

    expect(find.text('Fontes de Pagamento'), findsOneWidget);
    expect(
      find.text('Nenhuma fonte de pagamento adicionada ainda.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Nubank');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Nubank'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Nubank'), findsNothing);
    expect(
      find.text('Nenhuma fonte de pagamento adicionada ainda.'),
      findsOneWidget,
    );
  });

  testWidgets('Compras usa fontes de pagamento cadastradas', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ExpenseReconciliationApp());

    await tester.tap(find.text('Pessoas'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cartões'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Nubank');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(GridView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compras'));
    await tester.pumpAndSettle();

    expect(find.text('Compras'), findsOneWidget);
    expect(find.text('Nenhuma compra adicionada ainda.'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Almoço');
    await tester.enterText(find.byType(TextField).at(1), '25,50');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Almoço'), findsOneWidget);
    expect(find.textContaining('R\$ 25,50'), findsOneWidget);
    expect(find.textContaining('Nubank'), findsOneWidget);
    expect(find.textContaining('Individual'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Almoço'), findsNothing);
    expect(find.text('Nenhuma compra adicionada ainda.'), findsOneWidget);
  });

  testWidgets('Compra compartilhada indica tipo compartilhada', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ExpenseReconciliationApp());

    await tester.tap(find.text('Pessoas'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bruno');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cartões'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'C6');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(GridView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compras'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Mercado');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.tap(find.text('Compartilhada'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CheckboxListTile).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile).at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Mercado'), findsOneWidget);
    expect(find.textContaining('Compartilhada'), findsOneWidget);
  });

  testWidgets('Resumo soma total por pessoa com base nos splits', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ExpenseReconciliationApp());

    await tester.tap(find.text('Pessoas'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bruno');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cartões'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nubank');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(GridView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compras'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Mercado');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.tap(find.text('Compartilhada'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resumo'));
    await tester.pumpAndSettle();

    expect(find.text('Resumo'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
    expect(find.text('R\$ 50,00'), findsNWidgets(2));
  });

  testWidgets('Liquidação mostra consumido pago e saldo por pessoa', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ExpenseReconciliationApp());

    await tester.tap(find.text('Pessoas'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bruno');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cartões'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nubank');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(GridView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compras'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Mercado');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.tap(find.text('Compartilhada'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(GridView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liquidação'));
    await tester.pumpAndSettle();

    expect(find.text('Liquidação'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
    expect(find.textContaining('Consumido: R\$ 50,00'), findsNWidgets(2));
    expect(find.textContaining('Pago: R\$ 100,00'), findsOneWidget);
    expect(find.textContaining('Pago: R\$ 0,00'), findsOneWidget);
    expect(find.textContaining('Saldo: +R\$ 50,00'), findsOneWidget);
    expect(find.textContaining('Saldo: -R\$ 50,00'), findsOneWidget);
    expect(find.text('Quem deve para quem'), findsOneWidget);
    expect(find.text('Bruno deve R\$ 50,00 para Ana'), findsOneWidget);
  });
}
