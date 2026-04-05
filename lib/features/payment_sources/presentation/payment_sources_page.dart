import 'package:expense_reconciliation_app/core/models/payment_source.dart';
import 'package:expense_reconciliation_app/core/models/person.dart';
import 'package:flutter/material.dart';

class PaymentSourcesPage extends StatefulWidget {
  const PaymentSourcesPage({
    super.key,
    required this.people,
    required this.onToggleThemeMode,
  });

  final List<Person> people;
  final VoidCallback onToggleThemeMode;

  @override
  State<PaymentSourcesPage> createState() => _PaymentSourcesPageState();
}

class _PaymentSourcesPageState extends State<PaymentSourcesPage> {
  final List<PaymentSource> _paymentSources = <PaymentSource>[];

  Future<void> _showAddPaymentSourceDialog() async {
    var typedName = '';
    var selectedOwnerId = widget.people.isNotEmpty
        ? widget.people.first.id
        : '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Fonte de Pagamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Nome do cartão/conta',
                ),
                onChanged: (value) {
                  typedName = value;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedOwnerId.isEmpty ? null : selectedOwnerId,
                decoration: const InputDecoration(
                  labelText: 'Pessoa responsável',
                ),
                items: widget.people
                    .map(
                      (person) => DropdownMenuItem<String>(
                        value: person.id,
                        child: Text(person.name),
                      ),
                    )
                    .toList(),
                onChanged: widget.people.isEmpty
                    ? null
                    : (value) {
                        selectedOwnerId = value ?? selectedOwnerId;
                      },
              ),
              if (widget.people.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Adicione pessoas primeiro para vincular um dono.',
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => _addPaymentSource(typedName, selectedOwnerId),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _addPaymentSource(String rawName, String ownerId) {
    final name = rawName.trim();
    if (name.isEmpty || ownerId.isEmpty) {
      return;
    }

    final paymentSource = PaymentSource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      ownerId: ownerId,
    );

    setState(() {
      _paymentSources.add(paymentSource);
    });

    Navigator.of(context).pop();
  }

  void _removePaymentSource(String paymentSourceId) {
    setState(() {
      _paymentSources.removeWhere((source) => source.id == paymentSourceId);
    });
  }

  String _ownerNameFor(String ownerId) {
    for (final person in widget.people) {
      if (person.id == ownerId) {
        return person.name;
      }
    }

    return 'Dono não encontrado';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fontes de Pagamento'),
        actions: [
          IconButton(
            onPressed: widget.onToggleThemeMode,
            tooltip: isDarkMode ? 'Ativar tema claro' : 'Ativar tema escuro',
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: _paymentSources.isEmpty
          ? const Center(
              child: Text('Nenhuma fonte de pagamento adicionada ainda.'),
            )
          : ListView.builder(
              itemCount: _paymentSources.length,
              itemBuilder: (context, index) {
                final source = _paymentSources[index];
                return ListTile(
                  title: Text(source.name),
                  subtitle: Text(_ownerNameFor(source.ownerId)),
                  trailing: IconButton(
                    onPressed: () => _removePaymentSource(source.id),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remover',
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentSourceDialog,
        tooltip: 'Adicionar fonte de pagamento',
        child: const Icon(Icons.add),
      ),
    );
  }
}
