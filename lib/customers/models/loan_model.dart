import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String id;
  final String customerId;
  final String loanType;
  final double totalAmount;
  final int totalMonths;
  final DateTime loanCreateDate;
  final List<DateTime> transactionHistory;

  LoanModel({
    required this.id,
    required this.customerId,
    required this.loanType,
    required this.totalAmount,
    required this.totalMonths,
    required this.loanCreateDate,
    required this.transactionHistory,
  });

  double get monthlyEMI => totalAmount / totalMonths;

  int get remainingPayments => totalMonths - transactionHistory.length;

  double get remainingAmount => monthlyEMI * remainingPayments;

  bool isMonthPaid(int monthIndex) {
    DateTime dueDate = getDueDate(monthIndex);
    bool paid = transactionHistory.any((date) =>
    date.month == dueDate.month && date.year == dueDate.year);
    return paid;
  }

  DateTime getDueDate(int monthIndex) {
    int yearsToAdd = (loanCreateDate.month + monthIndex - 1) ~/ 12;
    int newMonth = (loanCreateDate.month + monthIndex - 1) % 12 + 1;

    return DateTime(
      loanCreateDate.year + yearsToAdd,
      newMonth,
      loanCreateDate.day,
    );
  }

  String getLoanStatus() {
    if (remainingPayments <= 0) {
      return 'Paid';
    }

    final now = DateTime.now();
    final currentMonthIndex = (now.year - loanCreateDate.year) * 12 +
        now.month - loanCreateDate.month;

    if (currentMonthIndex < totalMonths && !isMonthPaid(currentMonthIndex) &&
        now.isAfter(getDueDate(currentMonthIndex))) {
      return 'Overdue';
    }

    return 'Active';
  }

  factory LoanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<DateTime> transactions = [];
    if (data['transaction_history'] != null) {
      transactions = (data['transaction_history'] as List)
          .map((timestamp) => (timestamp as Timestamp).toDate())
          .toList();
    }

    return LoanModel(
      id: doc.id,
      customerId: data['customer_id'] ?? '',
      loanType: data['device_name'] ?? '',
      totalAmount: (data['total_amount'] as num).toDouble(),
      totalMonths: data['total_month'] as int,
      loanCreateDate: (data['purchase_date'] as Timestamp).toDate(),
      transactionHistory: transactions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'device_name': loanType,
      'total_amount': totalAmount,
      'total_month': totalMonths,
      'purchase_date': Timestamp.fromDate(loanCreateDate),
      'transaction_history': transactionHistory.map((date) => Timestamp.fromDate(date)).toList(),
    };
  }
}