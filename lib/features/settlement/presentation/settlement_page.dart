import 'package:expense_reconciliation_app/core/models/payment_source.dart';
import 'package:expense_reconciliation_app/core/models/person.dart';
import 'package:expense_reconciliation_app/core/models/purchase.dart';
import 'package:expense_reconciliation_app/core/models/purchase_split.dart';
import 'package:flutter/material.dart';

class SettlementPage extends StatelessWidget {
  const SettlementPage({
    super.key,
    required this.people,
    required this.purchases,
    required this.paymentSources,
    required this.purchaseSplits,
    required this.onToggleThemeMode,
  });

  final List<Person> people;
  final List<Purchase> purchases;
  final List<PaymentSource> paymentSources;
  final List<PurchaseSplit> purchaseSplits;
  final VoidCallback onToggleThemeMode;

  Map<String, double> _buildConsumedTotalsByPerson() {
    final totals = <String, double>{};

    for (final split in purchaseSplits) {
      totals[split.personId] = (totals[split.personId] ?? 0) + split.amount;
    }

    return totals;
  }

  Map<String, double> _buildPaidTotalsByPerson() {
    final totals = <String, double>{};
    final paymentSourcesById = <String, PaymentSource>{
      for (final source in paymentSources) source.id: source,
    };

    for (final purchase in purchases) {
      final source = paymentSourcesById[purchase.paymentSourceId];
      if (source == null) {
        continue;
      }

      totals[source.ownerId] = (totals[source.ownerId] ?? 0) + purchase.amount;
    }

    return totals;
  }

  String _formatCurrency(double amount, {bool forceSign = false}) {
    final isNegative = amount < 0;
    final absolute = amount.abs();
    final formatted = absolute.toStringAsFixed(2).replaceAll('.', ',');

    if (isNegative) {
      return '-R\$ $formatted';
    }

    if (forceSign) {
      return '+R\$ $formatted';
    }

    return 'R\$ $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final consumedByPerson = _buildConsumedTotalsByPerson();
    final paidByPerson = _buildPaidTotalsByPerson();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquidação'),
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
                final consumed = consumedByPerson[person.id] ?? 0;
                final paid = paidByPerson[person.id] ?? 0;
                final balance = paid - consumed;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(person.name),
                    subtitle: Text(
                      'Consumido: ${_formatCurrency(consumed)}\n'
                      'Pago: ${_formatCurrency(paid)}\n'
                      'Saldo: ${_formatCurrency(balance, forceSign: true)}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
