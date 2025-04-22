import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emi_management/customers/models/customer_model.dart';
import 'package:emi_management/customers/models/loan_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoanDetailsController extends GetxController {
  final Rx<LoanModel?> loan = Rx<LoanModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString nextDueDate = ''.obs;
  final RxDouble emiAmount = 0.0.obs;
  final RxInt paidEMIs = 0.obs;
  final RxDouble paidAmount = 0.0.obs;
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxString customerName = ''.obs;
  final RxString customerEmail = ''.obs;

   fetchLoanDetails(String loanId) async {
    isLoading.value = true;

    try {
      final DocumentSnapshot loanDoc = await FirebaseFirestore.instance
          .collection('loans')
          .doc(loanId)
          .get();

      if (loanDoc.exists) {
        LoanModel loanModel = LoanModel.fromFirestore(loanDoc);
        loan.value = loanModel;

        await fetchCustomerName(loanModel.customerId);

        final now = DateTime.now();
        int currentMonthIndex = (now.year - loanModel.loanCreateDate.year) * 12 +
            now.month - loanModel.loanCreateDate.month;

        int nextUnpaidMonth = 1;
        for (int i = 1; i <= loanModel.totalMonths; i++) {
          if (!loanModel.isMonthPaid(i)) {
            nextUnpaidMonth = i;
            break;
          }
        }

        DateTime nextDueDateTime = loanModel.getDueDate(nextUnpaidMonth);
        nextDueDate.value = DateFormat('dd MMM, yyyy').format(nextDueDateTime);

        emiAmount.value = loanModel.monthlyEMI;

        paidEMIs.value = loanModel.transactionHistory.length;
        paidAmount.value = paidEMIs.value * loanModel.monthlyEMI;

        List<Map<String, dynamic>> formattedTransactions = [];
        for (DateTime date in loanModel.transactionHistory) {
          formattedTransactions.add({
            'type': 'EMI Payment',
            'date': DateFormat('dd MMM, yyyy').format(date),
            'amount': loanModel.monthlyEMI
          });
        }

        transactions.value = formattedTransactions;
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomerName(String customerId) async {
    try {
      final DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .get();

      if (customerDoc.exists) {
        UserModel user = UserModel.fromJson(customerDoc.data() as Map<String, dynamic>);
        customerName.value = user.name;
        customerEmail.value = user.email ?? '';
      } else {
        customerName.value = "User";
      }
    } catch (e) {
      customerName.value = "User";
    }
  }
}