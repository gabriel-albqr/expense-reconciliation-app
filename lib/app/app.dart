import 'package:expense_reconciliation_app/core/navigation/app_routes.dart';
import 'package:expense_reconciliation_app/core/theme/app_theme.dart';
import 'package:expense_reconciliation_app/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';

class ExpenseReconciliationApp extends StatelessWidget {
  const ExpenseReconciliationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Despesas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.home) {
          return MaterialPageRoute<void>(
            builder: (_) => const HomePage(),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.section) {
          final sectionTitle = settings.arguments as String? ?? 'Seção';
          return MaterialPageRoute<void>(
            builder: (_) => SectionPlaceholderPage(title: sectionTitle),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      },
    );
  }
}
