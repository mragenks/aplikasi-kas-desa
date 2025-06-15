import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';

// Jangan lupa import model kita
import 'transaction_model.dart';

class DatabaseHelper {
  // Nama database dan tabel kita
  static const _databaseName = "KasDesa.db";
  static const _databaseVersion = 1;
  static const table = 'transactions';

  // Kolom-kolom di dalam tabel
  static const columnId = 'id';
  static const columnDescription = 'description';
  static const columnAmount = 'amount';
  static const columnType = 'type';
  static const columnDate = 'date';

  // Menjadikan class ini sebagai singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Hanya boleh ada satu koneksi database di seluruh aplikasi
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Method ini akan membuka database (atau membuatnya jika belum ada)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // Perintah SQL untuk membuat tabel saat database pertama kali dibuat
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId TEXT PRIMARY KEY,
            $columnDescription TEXT NOT NULL,
            $columnAmount REAL NOT NULL,
            $columnType TEXT NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
  }

  // Method untuk memasukkan data (Create)
  Future<int> insert(Transaction transaction) async {
    Database db = await instance.database;
    // Ubah objek Transaction menjadi Map<String, dynamic>
    Map<String, dynamic> row = {
      columnId: transaction.id,
      columnDescription: transaction.description,
      columnAmount: transaction.amount,
      // Simpan enum sebagai string
      columnType: transaction.type.toString(), 
      // Simpan DateTime sebagai string format ISO 8601
      columnDate: transaction.date.toIso8601String(), 
    };
    return await db.insert(table, row);
  }

  // Method untuk mengambil semua data (Read)
  Future<List<Transaction>> getAllTransactions() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table, orderBy: "$columnDate DESC");

    // Ubah List<Map> menjadi List<Transaction>
    return List.generate(maps.length, (i) {
      return Transaction(
        id: maps[i][columnId],
        description: maps[i][columnDescription],
        amount: maps[i][columnAmount],
        // Ubah string kembali menjadi enum
        type: maps[i][columnType] == TransactionType.pemasukan.toString() 
              ? TransactionType.pemasukan 
              : TransactionType.pengeluaran,
        // Ubah string ISO 8601 kembali menjadi DateTime
        date: DateTime.parse(maps[i][columnDate]),
      );
    });
  }
}