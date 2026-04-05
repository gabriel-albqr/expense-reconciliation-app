import 'package:expense_reconciliation_app/core/models/person.dart';
import 'package:flutter/material.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({
    super.key,
    required this.people,
    required this.onAddPerson,
    required this.onRemovePerson,
    required this.onToggleThemeMode,
  });

  final List<Person> people;
  final ValueChanged<String> onAddPerson;
  final ValueChanged<String> onRemovePerson;
  final VoidCallback onToggleThemeMode;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  Future<void> _showAddPersonDialog() async {
    var typedName = '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Pessoa'),
          content: TextField(
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Nome'),
            onChanged: (value) {
              typedName = value;
            },
            onSubmitted: (_) => _addPerson(typedName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => _addPerson(typedName),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _addPerson(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) {
      return;
    }

    widget.onAddPerson(name);

    setState(() {});

    Navigator.of(context).pop();
  }

  void _removePerson(String personId) {
    widget.onRemovePerson(personId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas'),
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
      body: widget.people.isEmpty
          ? const Center(child: Text('Nenhuma pessoa adicionada ainda.'))
          : ListView.builder(
              itemCount: widget.people.length,
              itemBuilder: (context, index) {
                final person = widget.people[index];
                return ListTile(
                  title: Text(person.name),
                  trailing: IconButton(
                    onPressed: () => _removePerson(person.id),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remover',
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPersonDialog,
        tooltip: 'Adicionar pessoa',
        child: const Icon(Icons.add),
      ),
    );
  }
}
