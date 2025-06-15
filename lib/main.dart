import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // Import untuk cek platform
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    hide Transaction; // Import FFI

import 'add_transaction_page.dart';
import 'transaction_model.dart';
import 'database_helper.dart';

Future<void> main() async {
  // 1. Ubah main menjadi async
  // 2. Pastikan Flutter siap sebelum cek platform
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inisialisasi FFI hanya untuk platform desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 4. Jalankan aplikasi seperti biasa
  runApp(const AplikasiKasDesa());
}

class AplikasiKasDesa extends StatelessWidget {
  const AplikasiKasDesa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kas Desa',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Daftar transaksi sekarang diinisialisasi sebagai list kosong.
  // Data akan diisi dari database.
  List<Transaction> _transactions = [];

  // Variabel untuk membantu agar loading tidak berkedip
  bool _isLoading = true;

  // initState adalah method yang dijalankan PERTAMA KALI saat halaman ini dibuat.
  // Sempurna untuk memuat data awal.
  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  // Method untuk mengambil data dari database dan memperbarui UI
  Future<void> _refreshTransactions() async {
    // Kita tambahkan try-catch untuk menangkap error
    try {
      print("Mencoba mengambil data dari database...");
      final data = await DatabaseHelper.instance.getAllTransactions();
      setState(() {
        _transactions = data;
        _isLoading = false; // Hentikan loading jika berhasil
      });
      print("Data berhasil diambil. Jumlah transaksi: ${data.length}");
    } catch (error) {
      print("--- TERJADI ERROR SAAT MENGAMBIL DATA ---");
      print(error);
      print("---------------------------------------");
      setState(() {
        _isLoading = false; // Tetap hentikan loading meski ada error
      });
    }
  }

  // Method untuk pindah halaman dan menangani data baru
  void _goToAddTransactionPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // KIRIMKAN NILAI SALDO SAAT INI KE HALAMAN TAMBAH
        builder: (context) => AddTransactionPage(currentBalance: _totalBalance),
      ),
    );

    if (result != null && result is Transaction) {
      await DatabaseHelper.instance.insert(result);
      _refreshTransactions();
    }
  }

  // Getter untuk menghitung total saldo
  double get _totalBalance {
    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.pemasukan) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kas Desa Singodutan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading // Jika masih loading, tampilkan spinner
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ... (Kartu Saldo dan Judul Riwayat masih sama)
                Card(
                  margin: const EdgeInsets.all(16.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Kas Saat Ini',
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.black54)),
                        const SizedBox(height: 8.0),
                        Text(
                          NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0)
                              .format(_totalBalance),
                          style: const TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Riwayat Transaksi',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ),
                ),
                // Jika tidak ada transaksi, tampilkan pesan
                _transactions.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            'Belum ada transaksi.\nTekan tombol + untuk memulai.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (ctx, index) {
                            // ... (ListTile masih sama persis seperti sebelumnya)
                            final tx = _transactions[index];
                            bool isPemasukan =
                                tx.type == TransactionType.pemasukan;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              child: ListTile(
                                leading: Icon(
                                    isPemasukan
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: isPemasukan
                                        ? Colors.green
                                        : Colors.red),
                                title: Text(tx.description),
                                subtitle: Text(DateFormat('d MMMM yyyy, HH:mm')
                                    .format(tx.date)),
                                trailing: Text(
                                  '${isPemasukan ? '+' : '-'} ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(tx.amount)}',
                                  style: TextStyle(
                                      color: isPemasukan
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddTransactionPage(context),
        tooltip: 'Tambah Transaksi',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
