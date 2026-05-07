import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:untitled/admin/controllers/customer_controller.dart';
import 'package:untitled/admin/controllers/device_controller.dart';
import 'package:untitled/utils/widgets/log_out_widget.dart';

import 'customers.dart';
import 'devices_screen.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final CustomerController customerController = Get.put(CustomerController());
    final DeviceController deviceController = Get.put(DeviceController());

    // Create a new controller class for dashboard state management
    final DashboardController dashboardController = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [logOutWidget()],
      ),
      body: GetX<CustomerController>(
        builder: (controller) {
          // Show loading state while data is being fetched
          if (controller.isLoading.value || deviceController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Calculate EMI statistics from customer loans
          final emiStats = _calculateEMIStatistics(controller.customerLoans);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSummaryCard(
                      'Total EMIs',
                      '₹${NumberFormat('#,##0').format(emiStats['total'])}',
                      Colors.blue[100]!,
                      Icons.account_balance,
                      Colors.blue,
                    ),
                    _buildSummaryCard(
                      'Paid',
                      '₹${NumberFormat('#,##0').format(emiStats['paid'])}',
                      Colors.green[100]!,
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildSummaryCard(
                      'Unpaid',
                      '₹${NumberFormat('#,##0').format(emiStats['unpaid'])}',
                      Colors.orange[100]!,
                      Icons.access_time,
                      Colors.orange,
                    ),
                    _buildSummaryCard(
                      'Overdue',
                      '₹${NumberFormat('#,##0').format(emiStats['overdue'])}',
                      Colors.red[100]!,
                      Icons.warning,
                      Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Revenue Overview Section
                _buildRevenueOverview(controller.customerLoans, dashboardController),

                const SizedBox(height: 28),

                // Stats Tiles with fixed height for lower tiles to prevent overflow
                SizedBox(
                  height: 205, // Fixed height to contain all tiles
                  child: Column(
                    children: [
                      // Upper stats: Total Users & Devices
                      Expanded(
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          childAspectRatio: 2.0,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            GestureDetector(
                              child: _buildNavButton(
                                '${deviceController.devices.length} Devices',
                                Colors.blue[100]!,
                                Icons.phone_android,
                                Colors.purple,
                              ),
                              onTap: () {
                                Get.to(() => DevicesPage());
                              },
                            ),
                            GestureDetector(
                              child: _buildNavButton(
                                '${controller.customers.length} Customers',
                                Colors.green[100]!,
                                Icons.people,
                                Colors.blue,
                              ),
                              onTap: () {
                                Get.to(() => CustomersScreen());
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build Revenue Overview with Chart - Updated for more professional styling
  Widget _buildRevenueOverview(
    Map<String, List<Map<String, dynamic>>> customerLoans,
    DashboardController dashboardController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Revenue Overview Title with time period selector
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Revenue Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF394456),
                ),
              ),
              // Compact dropdown for time period selector
              Obx(
                () => DropdownButton<String>(
                  value: dashboardController.selectedTimePeriod.value,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isDense: true,
                  underline: Container(height: 0),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      dashboardController.selectedTimePeriod.value = newValue;
                    }
                  },
                  items: <String>['Daily', 'Weekly', 'Monthly', 'Yearly']
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF394456)),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // Chart container with improved professional styling
        Container(
          height: 250,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Obx(() {
            // Generate revenue data based on current time period
            final List<Map<String, dynamic>> revenueData = _calculateRevenueData(
              customerLoans,
              dashboardController.selectedTimePeriod.value,
            );

            // If there's no data, show a placeholder message
            if (revenueData.isEmpty) {
              return const Center(
                child: Text(
                  'No revenue data available for this period',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(revenueData),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipMargin: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    /*tooltipRoundedRadius: 8,*/
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipBorder: BorderSide.none,
                    getTooltipColor: (group) => const Color(0xFF3E5CB8).withValues(alpha: 0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '₹${NumberFormat('#,##0').format(rod.toY)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < revenueData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              revenueData[value.toInt()]['label'],
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          '₹${NumberFormat.compact().format(value)}',
                          style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxY(revenueData) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: const Color(0xFFEAECF0), strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Color(0xFFD0D5DD)),
                    bottom: BorderSide(color: Color(0xFFD0D5DD)),
                  ),
                ),
                barGroups: _createBarGroups(revenueData),
              ),
            );
          }),
        ),

        // Revenue summary section
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Obx(() {
            final revenueData = _calculateRevenueData(
              customerLoans,
              dashboardController.selectedTimePeriod.value,
            );
            final double totalRevenue = _calculateTotalRevenue(revenueData);

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Color(0xFF12B76A)),
                  const SizedBox(width: 8),
                  Text(
                    'Total Revenue: ₹${NumberFormat('#,##0').format(totalRevenue)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF344054),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // Calculate EMI statistics from customer loans
  Map<String, double> _calculateEMIStatistics(
    Map<String, List<Map<String, dynamic>>> customerLoans,
  ) {
    double totalEMIAmount = 0;
    double paidEMIAmount = 0;
    double unpaidEMIAmount = 0;
    double overdueEMIAmount = 0;

    // Process all loans from all customers
    customerLoans.forEach((customerId, loans) {
      for (var loan in loans) {
        final double loanAmount = loan['totalAmount'] ?? 0.0;
        final int totalMonths = loan['totalMonths'] ?? 12;
        final List<Map<String, dynamic>> transactions = loan['transactions'] ?? [];

        // Calculate total EMI amount
        totalEMIAmount += loanAmount;

        // Calculate paid amount (sum of all transactions)
        double paidAmount = 0;
        for (var transaction in transactions) {
          paidAmount += transaction['amount'] ?? 0.0;
        }
        paidEMIAmount += paidAmount;

        // Calculate unpaid amount (remaining installments)
        if (loan['status'] == 'Active') {
          unpaidEMIAmount += (loanAmount - paidAmount);
        }

        // Calculate overdue amount
        if (loan['status'] == 'Overdue') {
          overdueEMIAmount += (loanAmount - paidAmount);
        }
      }
    });

    return {
      'total': totalEMIAmount,
      'paid': paidEMIAmount,
      'unpaid': unpaidEMIAmount,
      'overdue': overdueEMIAmount,
    };
  }

  // Calculate revenue data based on the selected time period
  List<Map<String, dynamic>> _calculateRevenueData(
    Map<String, List<Map<String, dynamic>>> customerLoans,
    String timePeriod,
  ) {
    // Initialize data structure based on time period
    Map<String, double> revenueByPeriod = {};

    // Get current date for reference
    final now = DateTime.now();

    // Process all transactions
    customerLoans.forEach((customerId, loans) {
      for (var loan in loans) {
        final List<Map<String, dynamic>> transactions = loan['transactions'] ?? [];

        for (var transaction in transactions) {
          DateTime transactionDate = transaction['date'];
          double amount = transaction['amount'] ?? 0.0;
          String periodKey = '';

          if (timePeriod == 'Daily') {
            // For last 7 days
            if (now.difference(transactionDate).inDays <= 7) {
              periodKey = DateFormat('E').format(transactionDate); // Day name
            }
          } else if (timePeriod == 'Weekly') {
            // For last 8 weeks
            if (now.difference(transactionDate).inDays <= 56) {
              final weekNumber = (now.difference(transactionDate).inDays / 7).ceil();
              periodKey = 'W-$weekNumber';
            }
          } else if (timePeriod == 'Monthly') {
            // For last 6 months
            if (now.difference(transactionDate).inDays <= 180) {
              periodKey = DateFormat('MMM').format(transactionDate); // Month name
            }
          } else if (timePeriod == 'Yearly') {
            // For last 5 years
            if (now.year - transactionDate.year <= 5) {
              periodKey = transactionDate.year.toString();
            }
          }

          if (periodKey.isNotEmpty) {
            revenueByPeriod[periodKey] = (revenueByPeriod[periodKey] ?? 0) + amount;
          }
        }
      }
    });

    // Prepare data for chart
    List<Map<String, dynamic>> result = [];

    if (timePeriod == 'Daily') {
      // Get the last 7 days in order
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayName = DateFormat('E').format(day);
        result.add({'label': dayName, 'value': revenueByPeriod[dayName] ?? 0.0});
      }
    } else if (timePeriod == 'Weekly') {
      // Get the last 8 weeks in order
      for (int i = 7; i >= 0; i--) {
        final weekKey = 'W-$i';
        result.add({'label': 'W${i + 1}', 'value': revenueByPeriod[weekKey] ?? 0.0});
      }
    } else if (timePeriod == 'Monthly') {
      // Get the last 6 months in order
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthName = DateFormat('MMM').format(month);
        result.add({'label': monthName, 'value': revenueByPeriod[monthName] ?? 0.0});
      }
    } else if (timePeriod == 'Yearly') {
      // Get the last 5 years in order
      for (int i = 4; i >= 0; i--) {
        final year = now.year - i;
        final yearStr = year.toString();
        result.add({'label': yearStr, 'value': revenueByPeriod[yearStr] ?? 0.0});
      }
    }

    return result;
  }

  // Calculate total revenue from data
  double _calculateTotalRevenue(List<Map<String, dynamic>> revenueData) {
    double total = 0;
    for (var data in revenueData) {
      total += data['value'] as double;
    }
    return total;
  }

  // Create bar groups from revenue data with professional color scheme
  List<BarChartGroupData> _createBarGroups(List<Map<String, dynamic>> revenueData) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < revenueData.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: revenueData[i]['value'],
              color: const Color(0xFF3E5CB8),
              width: 22,
              gradient: const LinearGradient(
                colors: [Color(0xFF5879E9), Color(0xFF3E5CB8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  // Calculate the maximum Y value for the chart
  double _getMaxY(List<Map<String, dynamic>> revenueData) {
    double maxValue = 0;
    for (var data in revenueData) {
      if (data['value'] > maxValue) {
        maxValue = data['value'];
      }
    }
    // Return a slightly higher value to provide some padding
    return maxValue > 0 ? maxValue * 1.2 : 20;
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData iconData,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData iconData,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(iconData, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, Color color, IconData iconData, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// New controller class for dashboard state management
class DashboardController extends GetxController {
  // Observable variable for time period selection
  final Rx<String> selectedTimePeriod = 'Daily'.obs;
}
