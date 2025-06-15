import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'package:intl/intl.dart'; // Kita butuh intl untuk format angka

class AddTransactionPage extends StatefulWidget {
  // 1. TAMBAHKAN VARIABEL UNTUK MENERIMA SALDO
  final double currentBalance;

  // 2. PERBARUI CONSTRUCTOR UNTUK MENERIMA PARAMETER
  const AddTransactionPage({
    super.key,
    required this.currentBalance, // Wajibkan parameter ini
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.pengeluaran;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi Baru'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3. TAMPILKAN KARTU INFORMASI SALDO
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Saldo saat ini: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.currentBalance)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue[800]),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // ... Kolom Isian dan ChoiceChip masih sama ...
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Keterangan Transaksi'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Jumlah (Rp)'),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Pengeluaran'),
                  selected: _selectedType == TransactionType.pengeluaran,
                  onSelected: (selected) { setState(() { _selectedType = TransactionType.pengeluaran; }); },
                  selectedColor: Colors.red[100],
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Pemasukan'),
                  selected: _selectedType == TransactionType.pemasukan,
                  onSelected: (selected) { setState(() { _selectedType = TransactionType.pemasukan; }); },
                  selectedColor: Colors.green[100],
                ),
              ],
            ),
            const SizedBox(height: 32.0),

            // Tombol Simpan
            ElevatedButton(
              onPressed: _submitData, // Panggil method _submitData
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('SIMPAN TRANSAKSI'),
            ),
          ],
        ),
      ),
    );
  }

  // 4. PINDAHKAN LOGIKA VALIDASI KE METHOD SENDIRI
  void _submitData() {
    final String description = _descriptionController.text;
    final double? amount = double.tryParse(_amountController.text);

    if (description.isEmpty || amount == null || amount <= 0) {
      // Tampilkan pesan error jika form tidak valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keterangan dan jumlah tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // --- BAGIAN PENTING: VALIDASI SALDO ---
    // Cek hanya jika ini adalah pengeluaran
    if (_selectedType == TransactionType.pengeluaran && amount > widget.currentBalance) {
      // Tampilkan pesan error jika saldo tidak cukup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi untuk transaksi ini!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Hentikan proses
    }

    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      description: description,
      amount: amount,
      type: _selectedType,
      date: DateTime.now(),
    );

    Navigator.pop(context, newTransaction);
  }
}