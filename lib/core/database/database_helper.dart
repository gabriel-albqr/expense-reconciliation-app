import 'package:expense_reconciliation_app/core/models/payment_source.dart';
import 'package:expense_reconciliation_app/core/models/person.dart';
import 'package:expense_reconciliation_app/core/models/purchase.dart';
import 'package:expense_reconciliation_app/core/models/purchase_split.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const _databaseName = 'expense_reconciliation.db';

  bool persistenceEnabled = true;
  Database? _database;

  Future<Database> get database async {
    if (!persistenceEnabled) {
      throw StateError('Persistence is disabled.');
    }

    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, _databaseName);

    _database = await openDatabase(dbPath, version: 1, onCreate: _onCreate);

    return _database!;
  }

  Future<void> close() async {
    if (!persistenceEnabled) {
      return;
    }

    final database = _database;
    _database = null;

    if (database != null && database.isOpen) {
      await database.close();
    }
  }

  Future<void> reset() async {
    if (!persistenceEnabled) {
      return;
    }

    await close();

    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, _databaseName);
    await deleteDatabase(dbPath);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE people (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_sources (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        ownerId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE purchases (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        paymentSourceId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_splits (
        id TEXT PRIMARY KEY,
        purchaseId TEXT NOT NULL,
        personId TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  Future<int> insertPerson(Person person) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.insert('people', _personToMap(person));
  }

  Future<List<Person>> getPeople() async {
    if (!persistenceEnabled) {
      return <Person>[];
    }

    final db = await database;
    final maps = await db.query('people');
    return maps.map(_personFromMap).toList();
  }

  Future<int> deletePerson(String id) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.delete('people', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertPaymentSource(PaymentSource paymentSource) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.insert('payment_sources', _paymentSourceToMap(paymentSource));
  }

  Future<List<PaymentSource>> getPaymentSources() async {
    if (!persistenceEnabled) {
      return <PaymentSource>[];
    }

    final db = await database;
    final maps = await db.query('payment_sources');
    return maps.map(_paymentSourceFromMap).toList();
  }

  Future<int> deletePaymentSource(String id) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.delete('payment_sources', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePaymentSourcesByOwnerId(String ownerId) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.delete(
      'payment_sources',
      where: 'ownerId = ?',
      whereArgs: [ownerId],
    );
  }

  Future<int> insertPurchase(Purchase purchase) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.insert('purchases', _purchaseToMap(purchase));
  }

  Future<List<Purchase>> getPurchases() async {
    if (!persistenceEnabled) {
      return <Purchase>[];
    }

    final db = await database;
    final maps = await db.query('purchases');
    return maps.map(_purchaseFromMap).toList();
  }

  Future<int> deletePurchase(String id) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.transaction((txn) async {
      await txn.delete(
        'purchase_splits',
        where: 'purchaseId = ?',
        whereArgs: [id],
      );
      return txn.delete('purchases', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> insertPurchaseSplit(PurchaseSplit purchaseSplit) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.insert('purchase_splits', _purchaseSplitToMap(purchaseSplit));
  }

  Future<List<PurchaseSplit>> getPurchaseSplits() async {
    if (!persistenceEnabled) {
      return <PurchaseSplit>[];
    }

    final db = await database;
    final maps = await db.query('purchase_splits');
    return maps.map(_purchaseSplitFromMap).toList();
  }

  Future<int> deletePurchaseSplitsByPersonId(String personId) async {
    if (!persistenceEnabled) {
      return 0;
    }

    final db = await database;
    return db.delete(
      'purchase_splits',
      where: 'personId = ?',
      whereArgs: [personId],
    );
  }

  Map<String, Object?> _personToMap(Person person) {
    return <String, Object?>{'id': person.id, 'name': person.name};
  }

  Person _personFromMap(Map<String, Object?> map) {
    return Person(id: map['id']! as String, name: map['name']! as String);
  }

  Map<String, Object?> _paymentSourceToMap(PaymentSource paymentSource) {
    return <String, Object?>{
      'id': paymentSource.id,
      'name': paymentSource.name,
      'ownerId': paymentSource.ownerId,
    };
  }

  PaymentSource _paymentSourceFromMap(Map<String, Object?> map) {
    return PaymentSource(
      id: map['id']! as String,
      name: map['name']! as String,
      ownerId: map['ownerId']! as String,
    );
  }

  Map<String, Object?> _purchaseToMap(Purchase purchase) {
    return <String, Object?>{
      'id': purchase.id,
      'title': purchase.title,
      'amount': purchase.amount,
      'date': purchase.date.toIso8601String(),
      'paymentSourceId': purchase.paymentSourceId,
    };
  }

  Purchase _purchaseFromMap(Map<String, Object?> map) {
    return Purchase(
      id: map['id']! as String,
      title: map['title']! as String,
      amount: (map['amount']! as num).toDouble(),
      date: DateTime.parse(map['date']! as String),
      paymentSourceId: map['paymentSourceId']! as String,
    );
  }

  Map<String, Object?> _purchaseSplitToMap(PurchaseSplit purchaseSplit) {
    return <String, Object?>{
      'id': purchaseSplit.id,
      'purchaseId': purchaseSplit.purchaseId,
      'personId': purchaseSplit.personId,
      'amount': purchaseSplit.amount,
    };
  }

  PurchaseSplit _purchaseSplitFromMap(Map<String, Object?> map) {
    return PurchaseSplit(
      id: map['id']! as String,
      purchaseId: map['purchaseId']! as String,
      personId: map['personId']! as String,
      amount: (map['amount']! as num).toDouble(),
    );
  }
}
