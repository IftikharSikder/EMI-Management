import 'package:emi_management/admin/controllers/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfileScreen extends StatelessWidget {
  final String customerId;
  final CustomerController customerController = Get.find<CustomerController>();

  CustomerProfileScreen({required this.customerId});

  @override
  Widget build(BuildContext context) {
    final customer = customerController.customers.firstWhere(
          (c) => c['id'] == customerId,
      orElse: () => {'id': '', 'name': 'Unknown', 'email': '', 'phone': ''},
    );

    final loans = customerController.getLoansForCustomer(customerId);
    final statusCounts = customerController.getEmiStatusCounts(customerId);

    final totalDevices = loans.length;
    final activeEMIs = statusCounts['Active'] ?? 0;
    final overdueEMIs = statusCounts['Overdue'] ?? 0;

    // Calculate total EMIs and paid EMIs
    int totalEMIs = 0;
    int paidEMIs = 0;
    DateTime? nextDueDate;

    for (final loan in loans) {
      totalEMIs += loan['totalMonths'] as int;
      paidEMIs += (loan['transactions'] as List).length;

      // Find the nearest upcoming due date among all loans
      if (loan['status'] != 'Paid Off') {
        final loanNextDueDate = getNextDueDateAsDateTime(
            loan['purchaseDate'],
            loan['transactions'] as List<Map<String, dynamic>>,
            loan['totalMonths'] as int
        );

        if (loanNextDueDate != null) {
          if (nextDueDate == null || loanNextDueDate.isBefore(nextDueDate)) {
            nextDueDate = loanNextDueDate;
          }
        }
      }
    }

    String nextDueDateText = nextDueDate != null
        ? "${_getMonthAbbreviation(nextDueDate.month)} ${nextDueDate.day}, ${nextDueDate.year}"
        : "No upcoming due";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () => Get.back(),
        ),
        title: Text('Customer Profile',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: customer['profileImage'] != null
                            ? NetworkImage(customer['profileImage'])
                            : null,
                        child: customer['profileImage'] == null
                            ? Text(
                            customer['name'] != null && customer['name'].toString().isNotEmpty
                                ? customer['name'][0]
                                : '?',
                            style: TextStyle(fontSize: 24))
                            : null,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer['name'] ?? 'Unknown Customer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (customer['phone'] != null && customer['phone'].toString().isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 16),
                                  SizedBox(width: 4),
                                  Text(customer['phone']),
                                ],
                              ),
                            if (customer['email'] != null && customer['email'].toString().isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.email, size: 16),
                                  SizedBox(width: 4),
                                  Text(customer['email']),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    '$totalDevices',
                    'Total\nDevices',
                    Colors.blue.shade100,
                  ),
                  _buildStatCard(
                    '$activeEMIs',
                    'Active\nEMIs',
                    Colors.green.shade100,
                  ),
                  _buildStatCard(
                    '$overdueEMIs',
                    'Overdue',
                    Colors.red.shade100,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Purchased Devices
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Purchased Devices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // List of devices
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];
                final status = loan['status'];
                Color statusColor;

                switch (status) {
                  case 'Active':
                    statusColor = Colors.green;
                    break;
                  case 'Overdue':
                    statusColor = Colors.red;
                    break;
                  case 'Paid Off':
                    statusColor = Colors.blue;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                // Calculate monthly EMI
                final totalAmount = loan['totalAmount'] as double;
                final totalMonths = loan['totalMonths'] as int;
                final monthlyEMI = totalAmount / totalMonths;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan['deviceName'] ?? 'Unknown Device',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('EMI: \₹${monthlyEMI.toStringAsFixed(0)}/month'),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: statusColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 16),

            // EMI Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EMI Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildEmiDetailCard('Total EMIs', '$totalEMIs', Colors.grey.shade200),
                      _buildEmiDetailCard('Paid EMIs', '$paidEMIs', Colors.grey.shade200),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildEmiDetailCard('Upcoming Due', nextDueDateText, Colors.grey.shade200),
                      _buildEmiDetailCard('Overdue', '$overdueEMIs', Colors.red.shade100),
                    ],
                  ),
                ],
              ),
            ),

            // Device EMI Table
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        children: [
                          _buildTableCell('Device', isHeader: true),
                          _buildTableCell('Amount', isHeader: true),
                          _buildTableCell('Due Date', isHeader: true),
                          _buildTableCell('Status', isHeader: true),
                        ],
                      ),
                      ...loans.map((loan) {
                        // Calculate the next due date
                        final dueDate = loan['status'] == 'Paid Off'
                            ? '-'
                            : calculateNextDueDate(
                            loan['purchaseDate'],
                            loan['transactions'] as List<Map<String, dynamic>>,
                            loan['totalMonths'] as int
                        );

                        final totalAmount = loan['totalAmount'] as double;
                        final totalMonths = loan['totalMonths'] as int;
                        final monthlyEMI = totalAmount / totalMonths;

                        return TableRow(
                          children: [
                            _buildTableCell(loan['deviceName'] ?? 'Unknown Device'),
                            _buildTableCell('\₹${monthlyEMI.toStringAsFixed(0)}'),
                            _buildTableCell(dueDate),
                            _buildTableCell(
                              loan['status'],
                              textColor: loan['status'] == 'Overdue'
                                  ? Colors.red
                                  : loan['status'] == 'Active'
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.notifications_active),
            label: Text('Send Reminder'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              // Handle send reminder
              _showReminderSentDialog(context);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      width: 80,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiDetailCard(String label, String value, Color color) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Calculate next due date based on purchase date and transactions
  String calculateNextDueDate(dynamic purchaseDate, List<Map<String, dynamic>> transactions, int totalMonths) {
    if (transactions.length >= totalMonths) {
      return '-'; // No more payments needed
    }

    DateTime? nextPaymentDate = getNextDueDateAsDateTime(purchaseDate, transactions, totalMonths);

    if (nextPaymentDate == null) {
      return '-';
    }

    // Format the date as "MMM dd, yyyy"
    return "${_getMonthAbbreviation(nextPaymentDate.month)} ${nextPaymentDate.day}, ${nextPaymentDate.year}";
  }

  // Helper to get next due date as DateTime object (used for both formatting and comparisons)
  DateTime? getNextDueDateAsDateTime(dynamic purchaseDate, List<Map<String, dynamic>> transactions, int totalMonths) {
    if (transactions.length >= totalMonths) {
      return null; // No more payments needed
    }

    DateTime baseDate;

    if (transactions.isEmpty) {
      // If no transactions, next payment is one month after purchase
      if (purchaseDate is Timestamp) {
        baseDate = purchaseDate.toDate();
      } else if (purchaseDate is DateTime) {
        baseDate = purchaseDate;
      } else {
        return null; // Unable to determine base date
      }
    } else {
      // Sort transactions by date
      transactions.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

      // Next payment is one month after the last payment
      baseDate = transactions.last['date'] as DateTime;
    }

    // Calculate next payment date
    DateTime nextPaymentDate = DateTime(
      baseDate.year,
      baseDate.month + 1,
      baseDate.day,
    );

    return nextPaymentDate;
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: isHeader ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  void _showReminderSentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reminder Sent'),
          content: Text('Payment reminder has been sent to the customer.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}