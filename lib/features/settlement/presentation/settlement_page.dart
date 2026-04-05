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

  List<_SettlementTransfer> _buildTransfers(
    Map<String, double> consumedByPerson,
    Map<String, double> paidByPerson,
  ) {
    final balancesInCents = <String, int>{};

    for (final person in people) {
      final consumed = consumedByPerson[person.id] ?? 0;
      final paid = paidByPerson[person.id] ?? 0;
      final balance = paid - consumed;
      balancesInCents[person.id] = (balance * 100).round();
    }

    final creditors = <_BalanceBucket>[];
    final debtors = <_BalanceBucket>[];

    balancesInCents.forEach((personId, cents) {
      if (cents > 0) {
        creditors.add(_BalanceBucket(personId: personId, cents: cents));
      } else if (cents < 0) {
        debtors.add(_BalanceBucket(personId: personId, cents: -cents));
      }
    });

    final transfers = <_SettlementTransfer>[];
    var creditorIndex = 0;

    for (final debtor in debtors) {
      while (debtor.cents > 0 && creditorIndex < creditors.length) {
        final creditor = creditors[creditorIndex];
        final transferCents = debtor.cents < creditor.cents
            ? debtor.cents
            : creditor.cents;

        transfers.add(
          _SettlementTransfer(
            debtorId: debtor.personId,
            creditorId: creditor.personId,
            amount: transferCents / 100,
          ),
        );

        debtor.cents -= transferCents;
        creditor.cents -= transferCents;

        if (creditor.cents == 0) {
          creditorIndex++;
        }
      }
    }

    return transfers;
  }

  String _personNameFor(String personId) {
    for (final person in people) {
      if (person.id == personId) {
        return person.name;
      }
    }

    return 'Pessoa desconhecida';
  }

  String _buildTransferLabel(_SettlementTransfer transfer) {
    final debtorName = _personNameFor(transfer.debtorId);
    final creditorName = _personNameFor(transfer.creditorId);
    final amount = _formatCurrency(transfer.amount);
    return '$debtorName deve $amount para $creditorName';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final consumedByPerson = _buildConsumedTotalsByPerson();
    final paidByPerson = _buildPaidTotalsByPerson();
    final transfers = _buildTransfers(consumedByPerson, paidByPerson);
    final personCards = people.map((person) {
      final consumed = consumedByPerson[person.id] ?? 0;
      final paid = paidByPerson[person.id] ?? 0;
      final balance = paid - consumed;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    }).toList();

    final transferWidgets = <Widget>[
      const SizedBox(height: 12),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Quem deve para quem',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 8),
    ];

    if (transfers.isEmpty) {
      transferWidgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Tudo certo, ninguém deve nada'),
        ),
      );
    } else {
      for (final transfer in transfers) {
        transferWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(_buildTransferLabel(transfer)),
          ),
        );
      }
    }

    transferWidgets.add(const SizedBox(height: 12));

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
          : ListView(children: [...personCards, ...transferWidgets]),
    );
  }
}

class _BalanceBucket {
  _BalanceBucket({required this.personId, required this.cents});

  final String personId;
  int cents;
}

class _SettlementTransfer {
  _SettlementTransfer({
    required this.debtorId,
    required this.creditorId,
    required this.amount,
  });

  final String debtorId;
  final String creditorId;
  final double amount;
}
