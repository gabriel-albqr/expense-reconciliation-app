import 'package:expense_reconciliation_app/core/models/payment_source.dart';
import 'package:expense_reconciliation_app/core/models/purchase.dart';
import 'package:flutter/material.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({
    super.key,
    required this.purchases,
    required this.paymentSources,
    required this.onAddPurchase,
    required this.onRemovePurchase,
    required this.onToggleThemeMode,
  });

  final List<Purchase> purchases;
  final List<PaymentSource> paymentSources;
  final ValueChanged<Purchase> onAddPurchase;
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
    var selectedPaymentSourceId = widget.paymentSources.isNotEmpty
        ? widget.paymentSources.first.id
        : '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Compra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                          selectedPaymentSourceId =
                              value ?? selectedPaymentSourceId;
                        },
                ),
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
              ),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _addPurchase({
    required String title,
    required String amount,
    required DateTime date,
    required String paymentSourceId,
  }) {
    final purchaseTitle = title.trim();
    final parsedAmount = double.tryParse(amount.replaceAll(',', '.'));

    if (purchaseTitle.isEmpty ||
        parsedAmount == null ||
        paymentSourceId.isEmpty) {
      return;
    }

    widget.onAddPurchase(
      Purchase(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: purchaseTitle,
        amount: parsedAmount,
        date: date,
        paymentSourceId: paymentSourceId,
      ),
    );

    setState(() {});

    Navigator.of(context).pop();
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
                    '${_formatAmount(purchase.amount)} • ${_paymentSourceNameFor(purchase.paymentSourceId)} • ${_formatDate(purchase.date)}',
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
