import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emi_management/utils/widgets/log_out_widget.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class EMIDetailsPage extends StatelessWidget {
  final Map<String, dynamic> loan;

  EMIDetailsPage({required this.loan});

  @override
  Widget build(BuildContext context) {
    // Calculate EMI details
    final totalAmount = loan['totalAmount'] as double;
    final totalMonths = loan['totalMonths'] as int;
    final monthlyEMI = totalAmount / totalMonths;

    // Get transaction history from the loan data
    // Handle transaction_history as an array instead of map
    final List<dynamic> transactionHistory = loan['transactionHistory'] is List
        ? loan['transactionHistory']
        : [];

    final int paidEMIs = transactionHistory.length;
    final int remainingEMIs = totalMonths - paidEMIs;
    final double paidAmount = paidEMIs * monthlyEMI;
    final double remainingAmount = totalAmount - paidAmount;

    final purchaseDate = loan['purchaseDate'] as DateTime;
    final formattedPurchaseDate = DateFormat('dd MMM, yyyy').format(purchaseDate);

    // Sort transactions by date for payment history (newest first)
    final List<Map<String, dynamic>> sortedTransactions = [];

    // Convert the array of timestamps to a structured list with needed information
    for (int i = 0; i < transactionHistory.length; i++) {
      if (transactionHistory[i] is Timestamp) {
        final DateTime paymentDate = (transactionHistory[i] as Timestamp).toDate();
        sortedTransactions.add({
          'installmentNumber': i + 1,
          'date': paymentDate,
          'amount': monthlyEMI, // Since we don't have specific amounts, use the monthly EMI
          'status': 'Completed'
        });
      }
    }

    // Sort by date descending
    sortedTransactions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('EMI Details',style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () => Get.back(),
        ),
        actions: [
          logOutWidget()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device details section
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loan['deviceName'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(loan['status']).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          loan['status'],
                          style: TextStyle(
                            color: _getStatusColor(loan['status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Purchase Date', formattedPurchaseDate),
                  _buildInfoRow('Device Price', '\$${totalAmount.toStringAsFixed(0)}'),
                ],
              ),
            ),

            Divider(),

            // Customer details section
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: loan['customerProfileImage'] != null && loan['customerProfileImage'].isNotEmpty
                            ? NetworkImage(loan['customerProfileImage'])
                            : null,
                        child: loan['customerProfileImage'] == null || loan['customerProfileImage'].isEmpty
                            ? Text(loan['customerName'][0].toUpperCase())
                            : null,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan['customerName'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text('Customer ID: ${loan['customerId'].substring(0, 8)}'),
                          if (loan['customerPhone'] != null)
                            Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(loan['customerPhone']),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(),

            // EMI Status section
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EMI Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total EMIs'),
                      Text('$totalMonths months'),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: paidEMIs / totalMonths,
                      minHeight: 12,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Paid: $paidEMIs'),
                      Text('Remaining: $remainingEMIs'),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Monthly EMI Amount', '\₹${monthlyEMI.toStringAsFixed(2)}'),
                  _buildInfoRow('Total Paid Amount', '\₹${paidAmount.toStringAsFixed(2)}', textColor: Colors.green),
                  _buildInfoRow('Remaining Amount', '\₹${remainingAmount.toStringAsFixed(2)}', textColor: Colors.red),
                ],
              ),
            ),

            Divider(),

            // Payment History section
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Dynamic payment history items from transaction history
                  ...sortedTransactions.map((transaction) {
                    final int installmentNumber = transaction['installmentNumber'] as int;
                    final DateTime paymentDate = transaction['date'] as DateTime;
                    final String formattedDate = DateFormat('dd MMM, yyyy').format(paymentDate);
                    final double amount = transaction['amount'] as double;
                    final String status = transaction['status'] as String;

                    return _buildPaymentHistoryItem(
                        installmentNumber,
                        formattedDate,
                        amount,
                        status
                    );
                  }).toList(),

                  // Show message if no transactions
                  if (sortedTransactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No payment history available'),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 80), // Extra space for the bottom button
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () {
             // Get.to(() => AddNewCustomer());
            },
            label: Text('Confirm Payment', style: TextStyle(color: Colors.white, fontSize: 18)),
            backgroundColor: loan['status']=="Active"?Colors.blue:loan['status']=="Overdue"?Colors.blue:Colors.grey,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem(int installmentNumber, String date, double amount, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$installmentNumber',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Installment $installmentNumber',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                status,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Overdue':
        return Colors.red;
      case 'Paid Off':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}