import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_model.dart';

class AddTransactionPage extends StatefulWidget {
  final double currentBalance;
  // Parameter opsional untuk transaksi yang akan diedit
  final Transaction? existingTransaction;

  const AddTransactionPage({
    super.key,
    required this.currentBalance,
    this.existingTransaction,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  late TransactionType _selectedType;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    // Cek apakah kita dalam mode edit atau tambah saat halaman pertama kali dibuka
    _isEditMode = widget.existingTransaction != null;

    if (_isEditMode) {
      // Jika mode edit, isi form dengan data yang sudah ada
      final tx = widget.existingTransaction!;
      _descriptionController.text = tx.description;
      _amountController.text = tx.amount.toStringAsFixed(0); // Hapus desimal
      _selectedType = tx.type;
    } else {
      // Jika mode tambah, default-nya adalah pengeluaran
      _selectedType = TransactionType.pengeluaran;
    }
  }

  // Method yang dijalankan saat tombol simpan ditekan
  void _submitData() {
    final String description = _descriptionController.text;
    final double? amount = double.tryParse(_amountController.text);

    // Validasi 1: Pastikan form tidak kosong
    if (description.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keterangan dan jumlah tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validasi 2: Pengecekan saldo yang sudah diperbaiki
    if (_selectedType == TransactionType.pengeluaran) {
      // Hitung "saldo yang tersedia" seolah-olah transaksi ini belum ada.
      double availableBalance = widget.currentBalance;
      if (_isEditMode) {
        // Jika transaksi aslinya pemasukan, kurangi saldo untuk "membatalkannya".
        if (widget.existingTransaction!.type == TransactionType.pemasukan) {
          availableBalance -= widget.existingTransaction!.amount;
        }
        // Jika transaksi aslinya pengeluaran, tambahkan kembali saldo untuk "membatalkannya".
        else {
          availableBalance += widget.existingTransaction!.amount;
        }
      }

      // Sekarang, cek dengan saldo yang benar-benar tersedia
      if (amount > availableBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saldo tidak mencukupi untuk transaksi ini!'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Hentikan proses
      }
    }

    // Jika semua validasi lolos, lanjutkan proses simpan
    if (_isEditMode) {
      final updatedTransaction = Transaction(
        id: widget.existingTransaction!.id,
        description: description,
        amount: amount,
        type: _selectedType,
        date: widget.existingTransaction!.date,
      );
      Navigator.pop(context, updatedTransaction); // Kirim kembali objek yang sudah di-update
    } else {
      final newTransaction = Transaction(
        id: DateTime.now().toString(),
        description: description,
        amount: amount,
        type: _selectedType,
        date: DateTime.now(),
      );
      Navigator.pop(context, newTransaction); // Kirim kembali objek baru
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi Baru'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Saldo saat ini: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.currentBalance)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[800]),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Keterangan Transaksi'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Jumlah (Rp)'),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Pengeluaran'),
                    selected: _selectedType == TransactionType.pengeluaran,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = TransactionType.pengeluaran;
                      });
                    },
                    selectedColor: Colors.red[100],
                  ),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Pemasukan'),
                    selected: _selectedType == TransactionType.pemasukan,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = TransactionType.pemasukan;
                      });
                    },
                    selectedColor: Colors.green[100],
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child:
                    Text(_isEditMode ? 'SIMPAN PERUBAHAN' : 'SIMPAN TRANSAKSI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}