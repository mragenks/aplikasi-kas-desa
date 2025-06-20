// Enum untuk mendefinisikan jenis transaksi. Ini lebih aman daripada menggunakan String.
enum TransactionType {
  pemasukan,
  pengeluaran,
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  // Method untuk mengubah objek Transaction menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.toString(),
      'date': date.toIso8601String(),
    };
  }
}
