import 'package:expense_reconciliation_app/core/models/payment_source.dart';
import 'package:expense_reconciliation_app/core/models/person.dart';
import 'package:expense_reconciliation_app/core/models/purchase.dart';
import 'package:expense_reconciliation_app/core/models/purchase_split.dart';
import 'package:flutter/material.dart';

enum PurchaseAssignmentMode { individual, shared }

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({
    super.key,
    required this.purchases,
    required this.people,
    required this.paymentSources,
    required this.purchaseSplits,
    required this.onAddPurchase,
    required this.onRemovePurchase,
    required this.onToggleThemeMode,
  });

  final List<Purchase> purchases;
  final List<Person> people;
  final List<PaymentSource> paymentSources;
  final List<PurchaseSplit> purchaseSplits;
  final void Function(Purchase purchase, List<PurchaseSplit> splits)
  onAddPurchase;
  final ValueChanged<String> onRemovePurchase;
  final VoidCallback onToggleThemeMode;

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  Future<void> _showAddPurchaseDialog() async {
    var title = '';
    var amount = '';
    final date = DateTime.now();
    var mode = PurchaseAssignmentMode.individual;
    var selectedPaymentSourceId = widget.paymentSources.isNotEmpty
        ? widget.paymentSources.first.id
        : '';
    var selectedPersonId = widget.people.isNotEmpty
        ? widget.people.first.id
        : '';
    final selectedSharedPersonIds = <String>{};

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova Compra'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Título'),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Valor'),
                      onChanged: (value) {
                        amount = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPaymentSourceId.isEmpty
                          ? null
                          : selectedPaymentSourceId,
                      decoration: const InputDecoration(
                        labelText: 'Fonte de pagamento',
                      ),
                      items: widget.paymentSources
                          .map(
                            (paymentSource) => DropdownMenuItem<String>(
                              value: paymentSource.id,
                              child: Text(paymentSource.name),
                            ),
                          )
                          .toList(),
                      onChanged: widget.paymentSources.isEmpty
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedPaymentSourceId =
                                    value ?? selectedPaymentSourceId;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    const Text('Tipo de compra'),
                    const SizedBox(height: 8),
                    SegmentedButton<PurchaseAssignmentMode>(
                      segments: const [
                        ButtonSegment<PurchaseAssignmentMode>(
                          value: PurchaseAssignmentMode.individual,
                          label: Text('Individual'),
                        ),
                        ButtonSegment<PurchaseAssignmentMode>(
                          value: PurchaseAssignmentMode.shared,
                          label: Text('Compartilhada'),
                        ),
                      ],
                      selected: <PurchaseAssignmentMode>{mode},
                      onSelectionChanged: (selection) {
                        setDialogState(() {
                          mode = selection.first;
                        });
                      },
                    ),
                    if (mode == PurchaseAssignmentMode.individual)
                      DropdownButtonFormField<String>(
                        initialValue: selectedPersonId.isEmpty
                            ? null
                            : selectedPersonId,
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
                                setDialogState(() {
                                  selectedPersonId = value ?? selectedPersonId;
                                });
                              },
                      ),
                    if (mode == PurchaseAssignmentMode.shared)
                      ...widget.people.map((person) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(person.name),
                          value: selectedSharedPersonIds.contains(person.id),
                          onChanged: widget.people.isEmpty
                              ? null
                              : (checked) {
                                  setDialogState(() {
                                    if (checked ?? false) {
                                      selectedSharedPersonIds.add(person.id);
                                    } else {
                                      selectedSharedPersonIds.remove(person.id);
                                    }
                                  });
                                },
                        );
                      }),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Data: ${_formatDate(date)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (widget.paymentSources.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Adicione fontes de pagamento primeiro para registrar compras.',
                        ),
                      ),
                    if (widget.people.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Adicione pessoas primeiro para definir responsabilidade da compra.',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => _addPurchase(
                    title: title,
                    amount: amount,
                    date: date,
                    paymentSourceId: selectedPaymentSourceId,
                    mode: mode,
                    individualPersonId: selectedPersonId,
                    sharedPersonIds: selectedSharedPersonIds.toList(),
                  ),
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addPurchase({
    required String title,
    required String amount,
    required DateTime date,
    required String paymentSourceId,
    required PurchaseAssignmentMode mode,
    required String individualPersonId,
    required List<String> sharedPersonIds,
  }) {
    final purchaseTitle = title.trim();
    final parsedAmount = double.tryParse(amount.replaceAll(',', '.'));

    if (purchaseTitle.isEmpty ||
        parsedAmount == null ||
        paymentSourceId.isEmpty) {
      return;
    }

    final responsiblePersonIds = mode == PurchaseAssignmentMode.individual
        ? <String>[individualPersonId]
        : sharedPersonIds;

    final validResponsibleIds = responsiblePersonIds
        .where((id) => id.isNotEmpty)
        .toList();

    if (validResponsibleIds.isEmpty) {
      return;
    }

    final purchaseId = DateTime.now().millisecondsSinceEpoch.toString();

    final splits = _buildEqualSplits(
      purchaseId: purchaseId,
      totalAmount: parsedAmount,
      personIds: validResponsibleIds,
    );

    widget.onAddPurchase(
      Purchase(
        id: purchaseId,
        title: purchaseTitle,
        amount: parsedAmount,
        date: date,
        paymentSourceId: paymentSourceId,
      ),
      splits,
    );

    setState(() {});

    Navigator.of(context).pop();
  }

  List<PurchaseSplit> _buildEqualSplits({
    required String purchaseId,
    required double totalAmount,
    required List<String> personIds,
  }) {
    final totalCents = (totalAmount * 100).round();
    final baseCents = totalCents ~/ personIds.length;
    final remainder = totalCents % personIds.length;
    final splits = <PurchaseSplit>[];

    for (var index = 0; index < personIds.length; index++) {
      final extraCent = index < remainder ? 1 : 0;
      final amount = (baseCents + extraCent) / 100;
      splits.add(
        PurchaseSplit(
          id: '${purchaseId}_${personIds[index]}',
          purchaseId: purchaseId,
          personId: personIds[index],
          amount: amount,
        ),
      );
    }

    return splits;
  }

  void _removePurchase(String purchaseId) {
    widget.onRemovePurchase(purchaseId);
    setState(() {});
  }

  String _paymentSourceNameFor(String paymentSourceId) {
    for (final paymentSource in widget.paymentSources) {
      if (paymentSource.id == paymentSourceId) {
        return paymentSource.name;
      }
    }

    return 'Cartão desconhecido';
  }

  String _formatAmount(double amount) {
    final formatted = amount.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _purchaseTypeFor(String purchaseId) {
    final splitCount = widget.purchaseSplits
        .where((split) => split.purchaseId == purchaseId)
        .length;

    if (splitCount <= 1) {
      return 'Individual';
    }

    return 'Compartilhada';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
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
      body: widget.purchases.isEmpty
          ? const Center(child: Text('Nenhuma compra adicionada ainda.'))
          : ListView.builder(
              itemCount: widget.purchases.length,
              itemBuilder: (context, index) {
                final purchase = widget.purchases[index];
                return ListTile(
                  title: Text(purchase.title),
                  subtitle: Text(
                    '${_formatAmount(purchase.amount)} • ${_paymentSourceNameFor(purchase.paymentSourceId)} • ${_formatDate(purchase.date)} • ${_purchaseTypeFor(purchase.id)}',
                  ),
                  trailing: IconButton(
                    onPressed: () => _removePurchase(purchase.id),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remover',
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPurchaseDialog,
        tooltip: 'Adicionar compra',
        child: const Icon(Icons.add),
      ),
    );
  }
}
