import 'package:expense_reconciliation_app/core/navigation/app_routes.dart';
import 'package:expense_reconciliation_app/core/database/database_helper.dart';
import 'package:expense_reconciliation_app/core/models/payment_source.dart';
import 'package:expense_reconciliation_app/core/models/person.dart';
import 'package:expense_reconciliation_app/core/models/purchase.dart';
import 'package:expense_reconciliation_app/core/models/purchase_split.dart';
import 'package:expense_reconciliation_app/core/theme/app_theme.dart';
import 'package:expense_reconciliation_app/core/theme/theme_mode_storage.dart';
import 'package:expense_reconciliation_app/features/home/presentation/home_page.dart';
import 'package:expense_reconciliation_app/features/payment_sources/presentation/payment_sources_page.dart';
import 'package:expense_reconciliation_app/features/purchases/presentation/purchases_page.dart';
import 'package:expense_reconciliation_app/features/people/presentation/people_page.dart';
import 'package:expense_reconciliation_app/features/settlement/presentation/settlement_page.dart';
import 'package:expense_reconciliation_app/features/summary/presentation/summary_page.dart';
import 'package:flutter/material.dart';

class ExpenseReconciliationApp extends StatefulWidget {
  const ExpenseReconciliationApp({super.key});

  @override
  State<ExpenseReconciliationApp> createState() =>
      _ExpenseReconciliationAppState();
}

class _ExpenseReconciliationAppState extends State<ExpenseReconciliationApp> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final ThemeModeStorage _themeModeStorage = ThemeModeStorage();
  ThemeMode _themeMode = ThemeMode.light;
  final List<Person> _people = <Person>[];
  final List<PaymentSource> _paymentSources = <PaymentSource>[];
  final List<Purchase> _purchases = <Purchase>[];
  final List<PurchaseSplit> _purchaseSplits = <PurchaseSplit>[];

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadStoredData();
  }

  Future<void> _loadThemeMode() async {
    final savedMode = await _themeModeStorage.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _themeMode = savedMode;
    });
  }

  Future<void> _toggleThemeMode() async {
    final nextMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    setState(() {
      _themeMode = nextMode;
    });

    await _themeModeStorage.save(nextMode);
  }

  Future<void> _loadStoredData() async {
    if (!_databaseHelper.persistenceEnabled) {
      return;
    }

    await _databaseHelper.database;

    final people = await _databaseHelper.getPeople();
    final paymentSources = await _databaseHelper.getPaymentSources();
    final purchases = await _databaseHelper.getPurchases();
    final purchaseSplits = await _databaseHelper.getPurchaseSplits();

    if (!mounted) {
      return;
    }

    setState(() {
      _people
        ..clear()
        ..addAll(people);
      _paymentSources
        ..clear()
        ..addAll(paymentSources);
      _purchases
        ..clear()
        ..addAll(purchases);
      _purchaseSplits
        ..clear()
        ..addAll(purchaseSplits);
    });
  }

  Future<void> _addPerson(String name) async {
    final person = Person(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    setState(() {
      _people.add(person);
    });

    await _databaseHelper.insertPerson(person);
  }

  Future<void> _removePerson(String personId) async {
    setState(() {
      _people.removeWhere((person) => person.id == personId);
      _paymentSources.removeWhere((source) => source.ownerId == personId);
      _purchaseSplits.removeWhere((split) => split.personId == personId);
    });

    await Future.wait([
      _databaseHelper.deletePerson(personId),
      _databaseHelper.deletePaymentSourcesByOwnerId(personId),
      _databaseHelper.deletePurchaseSplitsByPersonId(personId),
    ]);
  }

  Future<void> _addPaymentSource(String name, String ownerId) async {
    final paymentSource = PaymentSource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      ownerId: ownerId,
    );

    setState(() {
      _paymentSources.add(paymentSource);
    });

    await _databaseHelper.insertPaymentSource(paymentSource);
  }

  Future<void> _removePaymentSource(String paymentSourceId) async {
    setState(() {
      _paymentSources.removeWhere((source) => source.id == paymentSourceId);
    });

    await _databaseHelper.deletePaymentSource(paymentSourceId);
  }

  Future<void> _addPurchase(
    Purchase purchase,
    List<PurchaseSplit> splits,
  ) async {
    setState(() {
      _purchases.add(purchase);
      _purchaseSplits.addAll(splits);
    });

    await _databaseHelper.insertPurchase(purchase);
    for (final split in splits) {
      await _databaseHelper.insertPurchaseSplit(split);
    }
  }

  Future<void> _removePurchase(String purchaseId) async {
    setState(() {
      _purchases.removeWhere((purchase) => purchase.id == purchaseId);
      _purchaseSplits.removeWhere((split) => split.purchaseId == purchaseId);
    });

    await _databaseHelper.deletePurchase(purchaseId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Despesas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.home) {
          return MaterialPageRoute<void>(
            builder: (_) => HomePage(
              onToggleThemeMode: () {
                _toggleThemeMode();
              },
            ),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.section) {
          final sectionTitle = settings.arguments as String? ?? 'Seção';
          return MaterialPageRoute<void>(
            builder: (_) => SectionPlaceholderPage(
              title: sectionTitle,
              onToggleThemeMode: () {
                _toggleThemeMode();
              },
            ),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.people) {
          return MaterialPageRoute<void>(
            builder: (_) => PeoplePage(
              people: _people,
              onAddPerson: _addPerson,
              onRemovePerson: _removePerson,
              onToggleThemeMode: () {
                _toggleThemeMode();
              },
            ),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.paymentSources) {
          return MaterialPageRoute<void>(
            builder: (_) => PaymentSourcesPage(
              people: _people,
              paymentSources: _paymentSources,
              onAddPaymentSource: _addPaymentSource,
              onRemovePaymentSource: _removePaymentSource,
              onToggleThemeMode: () {
                _toggleThemeMode();
              },
            ),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.purchases) {
          return MaterialPageRoute<void>(
            builder: (_) => PurchasesPage(
              purchases: _purchases,
              people: _people,
              paymentSources: _paymentSources,
              purchaseSplits: _purchaseSplits,
              onAddPurchase: _addPurchase,
              onRemovePurchase: _removePurchase,
              onToggleThemeMode: () {
                _toggleThemeMode();
              },
            ),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.summary) {
          return MaterialPageRoute<void>(
            builder: (_) => SummaryPage(
              people: _people,
              purchaseSplits: _purchaseSplits,
              onToggleThemeMode: () {
                _toggleThemeMode();
              },
            ),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.settlement) {
          return MaterialPageRoute<void>(
            builder: (_) => SettlementPage(
              people: _people,
              purchases: _purchases,
              paymentSources: _paymentSources,
              purchaseSplits: _purchaseSplits,
              onToggleThemeMode: () {
                _toggleThemeMode();
              },
            ),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => HomePage(
            onToggleThemeMode: () {
              _toggleThemeMode();
            },
          ),
          settings: settings,
        );
      },
    );
  }
}
