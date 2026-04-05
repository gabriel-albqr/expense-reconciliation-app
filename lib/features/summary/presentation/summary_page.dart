import 'package:expense_reconciliation_app/core/models/person.dart';
import 'package:expense_reconciliation_app/core/models/purchase_split.dart';
import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({
    super.key,
    required this.people,
    required this.purchaseSplits,
    required this.onToggleThemeMode,
  });

  final List<Person> people;
  final List<PurchaseSplit> purchaseSplits;
  final VoidCallback onToggleThemeMode;

  Map<String, double> _buildTotalsByPerson() {
    final totals = <String, double>{};

    for (final split in purchaseSplits) {
      totals[split.personId] = (totals[split.personId] ?? 0) + split.amount;
    }

    return totals;
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final totalsByPerson = _buildTotalsByPerson();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo'),
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
      body: people.isEmpty
          ? const Center(child: Text('Nenhuma pessoa cadastrada ainda.'))
          : ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];
                final total = totalsByPerson[person.id] ?? 0;

                return ListTile(
                  title: Text(person.name),
                  trailing: Text(
                    _formatCurrency(total),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                );
              },
            ),
    );
  }
}
