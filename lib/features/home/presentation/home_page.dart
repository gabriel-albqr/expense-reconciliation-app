import 'package:expense_reconciliation_app/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onToggleThemeMode});

  final VoidCallback onToggleThemeMode;

  static final _sections = <_HomeSection>[
    _HomeSection(
      title: 'Pessoas',
      icon: Icons.people_alt_outlined,
      routeName: AppRoutes.people,
    ),
    _HomeSection(
      title: 'Cartões',
      icon: Icons.credit_card_outlined,
      routeName: AppRoutes.paymentSources,
    ),
    _HomeSection(
      title: 'Compras',
      icon: Icons.shopping_cart_outlined,
      routeName: AppRoutes.purchases,
    ),
    _HomeSection(title: 'Resumo Mensal', icon: Icons.calendar_month_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Despesas'),
        actions: [
          IconButton(
            onPressed: onToggleThemeMode,
            tooltip: isDarkMode ? 'Ativar tema claro' : 'Ativar tema escuro',
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comece por aqui',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: GridView.builder(
                itemCount: _sections.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final routeName =
                            section.routeName ?? AppRoutes.section;
                        Navigator.of(context).pushNamed(
                          routeName,
                          arguments: section.routeName == null
                              ? section.title
                              : null,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(section.icon, size: 30),
                            const Spacer(),
                            Text(
                              section.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionPlaceholderPage extends StatelessWidget {
  const SectionPlaceholderPage({
    super.key,
    required this.title,
    required this.onToggleThemeMode,
  });

  final String title;
  final VoidCallback onToggleThemeMode;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: onToggleThemeMode,
            tooltip: isDarkMode ? 'Ativar tema claro' : 'Ativar tema escuro',
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Tela de $title (placeholder)',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HomeSection {
  const _HomeSection({required this.title, required this.icon, this.routeName});

  final String title;
  final IconData icon;
  final String? routeName;
}
