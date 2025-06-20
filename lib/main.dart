import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'add_transaction_page.dart';
import 'database_helper.dart';
import 'transaction_model.dart';

// Enum untuk mendefinisikan pilihan filter yang tersedia
enum FilterType { semua, pemasukan, pengeluaran }

Future<void> main() async {
  // Pastikan Flutter siap sebelum cek platform
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi FFI hanya untuk platform desktop (Windows, Linux, macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Jalankan aplikasi
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
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
  List<Transaction> _allTransactions = []; // Menyimpan SEMUA transaksi
  List<Transaction> _filteredTransactions =
      []; // Menyimpan transaksi yang akan ditampilkan
  bool _isLoading = true;
  FilterType _currentFilter = FilterType.semua;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  // Fungsi untuk menampilkan dialog error di layar
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terjadi Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _refreshTransactions() async {
    try {
      final allData = await DatabaseHelper.instance.getAllTransactions();
      _applyFilter(allData);
    } catch (error) {
      _showErrorDialog(
          'Gagal memuat data dari database:\n\n${error.toString()}');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter(List<Transaction> allData) {
    List<Transaction> filteredData;
    if (_currentFilter == FilterType.pemasukan) {
      filteredData =
          allData.where((tx) => tx.type == TransactionType.pemasukan).toList();
    } else if (_currentFilter == FilterType.pengeluaran) {
      filteredData = allData
          .where((tx) => tx.type == TransactionType.pengeluaran)
          .toList();
    } else {
      filteredData = allData;
    }

    if (mounted) {
      setState(() {
        _allTransactions = allData;
        _filteredTransactions = filteredData;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateAndAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AddTransactionPage(currentBalance: _totalBalance)),
    );

    // --- BAGIAN PELACAKAN DIMULAI DI SINI ---

    // Cek 1: Apakah ada data yang kembali?
    if (result == null) {
      _showErrorDialog(
          "Proses Dibatalkan.\n\nTidak ada data yang kembali dari halaman tambah.");
      return; // Hentikan proses
    }

    // Cek 2: Apakah tipe datanya benar?
    if (result is! Transaction) {
      _showErrorDialog(
          "Error Tipe Data.\n\nData yang kembali bukan objek Transaksi. Tipe data yang diterima adalah: ${result.runtimeType}");
      return; // Hentikan proses
    }

    // Jika kedua cek di atas lolos, berarti data valid. Baru kita coba simpan.
    try {
      await DatabaseHelper.instance.insert(result);
      _refreshTransactions();
    } catch (error) {
      _showErrorDialog('Gagal menyimpan transaksi:\n\n${error.toString()}');
    }
  }

  Future<void> _navigateAndEditTransaction(Transaction transaction) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddTransactionPage(
                currentBalance: _totalBalance,
                existingTransaction: transaction)),
      );
      _refreshTransactions();
    } catch (error) {
      _showErrorDialog('Gagal memperbarui transaksi:\n\n${error.toString()}');
    }
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      await DatabaseHelper.instance.delete(id);
      _refreshTransactions();
    } catch (error) {
      _showErrorDialog('Gagal menghapus transaksi:\n\n${error.toString()}');
    }
  }

  double get _totalBalance {
    double total = 0.0;
    for (var tx in _allTransactions) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: _currentFilter == FilterType.semua,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _currentFilter = FilterType.semua);
                            _applyFilter(_allTransactions);
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Pemasukan'),
                        selected: _currentFilter == FilterType.pemasukan,
                        onSelected: (selected) {
                          if (selected) {
                            setState(
                                () => _currentFilter = FilterType.pemasukan);
                            _applyFilter(_allTransactions);
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Pengeluaran'),
                        selected: _currentFilter == FilterType.pengeluaran,
                        onSelected: (selected) {
                          if (selected) {
                            setState(
                                () => _currentFilter = FilterType.pengeluaran);
                            _applyFilter(_allTransactions);
                          }
                        },
                      ),
                    ],
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
                _filteredTransactions.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            'Tidak ada transaksi untuk ditampilkan.\nUbah filter atau tekan + untuk memulai.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (ctx, index) {
                            final tx = _filteredTransactions[index];
                            bool isPemasukan =
                                tx.type == TransactionType.pemasukan;
                            return Dismissible(
                              key: Key(tx.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Konfirmasi Hapus"),
                                      content: Text(
                                          'Apakah Anda yakin ingin menghapus transaksi "${tx.description}"?'),
                                      actions: <Widget>[
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("Batal")),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text("Hapus",
                                                style: TextStyle(
                                                    color: Colors.red))),
                                      ],
                                    );
                                  },
                                );
                              },
                              onDismissed: (direction) {
                                _deleteTransaction(tx.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${tx.description} telah dihapus')));
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 4.0),
                                child: ListTile(
                                  onTap: () => _navigateAndEditTransaction(tx),
                                  leading: Icon(
                                      isPemasukan
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: isPemasukan
                                          ? Colors.green
                                          : Colors.red),
                                  title: Text(tx.description),
                                  subtitle: Text(DateFormat('d MMMM y, HH:mm')
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
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddTransaction,
        tooltip: 'Tambah Transaksi',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
