import 'package:device_policy_controller/device_policy_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/customers/controllers/emi_controller.dart';
import 'package:untitled/customers/screens/profile_page.dart';
import 'package:untitled/customers/screens/upcoming_emi.dart';

import 'emi_details_screen.dart';

class EMIReminderScreen extends StatefulWidget {
  const EMIReminderScreen({super.key});

  @override
  State<EMIReminderScreen> createState() => _EMIReminderScreenState();
}

class _EMIReminderScreenState extends State<EMIReminderScreen> with WidgetsBindingObserver {
  final EMIController emiController = Get.put(EMIController());

  final RxBool notificationAlertEnabled = true.obs;
  final RxBool emailAlertEnabled = false.obs;

  // Lock screen related variables
  bool isDeviceLocked = false;
  OverlayEntry? _lockOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedPreferences();

    // React to changes in the EMI list
    ever(emiController.emiList, (_) {
      _checkForOverdueEMIs();
    });

    // Listen for app lifecycle changes (foreground/background)
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.resumed.toString()) {
        // Check if device should still be locked when app resumes
        _checkAndEnforceLockStatus();
      }
      return null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkAndEnforceLockStatus();
    }
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    notificationAlertEnabled.value = prefs.getBool('notificationAlertEnabled') ?? true;
    emailAlertEnabled.value = prefs.getBool('emailAlertEnabled') ?? false;
  }

  void _checkForOverdueEMIs() {
    if (emiController.emiList.isNotEmpty) {
      final hasOverdueEmi = emiController.emiList.any((emi) => emi['status'] == 'Overdue');

      if (hasOverdueEmi && !isDeviceLocked) {
        // Lock the device if there are overdue EMIs
        _lockDevice();
      } else if (!hasOverdueEmi && isDeviceLocked) {
        // Unlock the device if no overdue EMIs
        _unlockDevice();
      }
    }
  }

  // Lock the device when overdue EMIs are found
  void _lockDevice() {
    setState(() {
      isDeviceLocked = true;
    });
    _showLockScreen();
    DevicePolicyController.instance.lockApp();
    print('Device locked due to overdue EMIs');
  }

  // Unlock the device when no overdue EMIs
  void _unlockDevice() {
    setState(() {
      isDeviceLocked = false;
    });
    _removeLockScreen();
    DevicePolicyController.instance.unlockApp();
    print('Device unlocked - no overdue EMIs');
  }

  // Enforce lock based on current lock status
  void _checkAndEnforceLockStatus() async {
    if (isDeviceLocked) {
      _showLockScreen();
      DevicePolicyController.instance.lockApp();
    }
  }

  // Show our custom lock screen overlay that can't be bypassed
  void _showLockScreen() {
    if (_lockOverlay != null) {
      _removeLockScreen();
    }

    _lockOverlay = OverlayEntry(
      builder: (context) => Positioned.fill(child: _buildLockScreenOverlay()),
    );

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Overlay.of(context).insert(_lockOverlay!);
      });
    }
  }

  // Remove the lock screen overlay
  void _removeLockScreen() {
    _lockOverlay?.remove();
    _lockOverlay = null;
  }

  // Build an overlay that prevents navigation out of the app
  Widget _buildLockScreenOverlay() {
    return PopScope(
      canPop: false, // Prevent back navigation
      onPopInvoked: (didPop) {
        // Immediately re-enforce lock when back navigation is attempted
        if (!didPop) {
          _checkAndEnforceLockStatus();
        }
      },
      child: GestureDetector(
        // Intercept all gestures to prevent navigation
        onHorizontalDragEnd: (_) => _checkAndEnforceLockStatus(),
        onVerticalDragEnd: (_) => _checkAndEnforceLockStatus(),
        behavior: HitTestBehavior.opaque,
        child: Material(
          color: Colors.black.withValues(alpha: 0.9),
          child: Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              // Handle all key events including back button
              _checkAndEnforceLockStatus();
              return KeyEventResult.handled; // Consume the event
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 100, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Device Locked',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your device is locked due to overdue EMI payments.\nPlease clear your overdue payments to unlock.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh EMI data to check if overdue status has changed
                      _refreshEMIStatus();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Check Payment Status'),
                  ),
                  const SizedBox(height: 20),
                  // Show overdue EMI details
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Overdue EMIs:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...emiController.emiList
                            .where((emi) => emi['status'] == 'Overdue')
                            .map(
                              (emi) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        emi['device_name'],
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      '₹${emi['amount'].toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Refresh EMI status to check if overdue payments have been cleared
  Future<void> _refreshEMIStatus() async {
    try {
      await emiController.refreshData();

      // Check if there are still overdue EMIs
      final hasOverdueEmi = emiController.emiList.any((emi) => emi['status'] == 'Overdue');

      if (!hasOverdueEmi) {
        _unlockDevice();
        Get.snackbar(
          'Device Unlocked',
          'All overdue payments have been cleared!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Still Overdue',
          'Please clear all overdue payments to unlock the device.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error refreshing EMI status: $e');
      Get.snackbar(
        'Error',
        'Failed to refresh payment status. Please try again.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _savePreferences(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeLockScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          'EMI Reminders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ClipOval(
                child: Image.network(
                  "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            onTap: () {
              Get.to(() => const ProfilePage());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Manual refresh
          await emiController.refreshData();
        },
        child: Obx(() {
          if (emiController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show lock warning if device is locked
                if (isDeviceLocked)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Device is locked due to overdue EMI payments!',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "This Month's Summary",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            emiController.currentMonth.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Total Due Card
                        Expanded(
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Total Due',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${emiController.totalDueAmount.value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Pending EMIs Card
                        Expanded(
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: Colors.orange[700],
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Pending EMIs',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${emiController.pendingEMIs.value}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: emiController.pendingEMIs.value > 3
                                        ? Colors.red[400]
                                        : Colors.green[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      ' Upcoming EMIs',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => UpcomingEmi());
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: emiController.emiList.isEmpty
                      ? const Center(child: Text('No EMIs due this month'))
                      : ListView.builder(
                          itemCount: emiController.emiList.length > 2
                              ? 2
                              : emiController.emiList.length,
                          itemBuilder: (context, index) {
                            final emi = emiController.emiList[index];
                            final daysText = emi['days_remaining'] < 0
                                ? '${-emi['days_remaining']} days ago'
                                : emi['days_remaining'] == 0
                                ? 'Today'
                                : '${emi['days_remaining']} days left';

                            Color statusColor;
                            if (emi['status'] == 'Overdue') {
                              statusColor = Colors.red[100]!;
                            } else if (emi['status'] == 'Due Today') {
                              statusColor = Colors.orange[100]!;
                            } else {
                              statusColor = Colors.green[100]!;
                            }

                            return Card(
                              color: Colors.white,
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.to(
                                    () => EmiDetailsScreen(),
                                    arguments: {
                                      'loan_id': emi['loan_id'],
                                      'device_name': emi['device_name'],
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${emi['device_name']}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                // Show lock icon for overdue EMIs
                                                if (emi['status'] == 'Overdue')
                                                  Icon(
                                                    Icons.lock,
                                                    color: Colors.red[700],
                                                    size: 20,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              emi['bank_name'],
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              '₹${emi['amount'].toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              emi['status'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: emi['status'] == 'Overdue'
                                                    ? Colors.red[800]
                                                    : emi['status'] == 'Due Today'
                                                    ? Colors.orange[800]
                                                    : Colors.green[800],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Due Date',
                                            style: TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            daysText,
                                            style: TextStyle(
                                              color: emi['status'] == 'Overdue'
                                                  ? Colors.red[800]
                                                  : emi['status'] == 'Due Today'
                                                  ? Colors.orange[800]
                                                  : Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),
                const Text(
                  ' Reminder Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active, color: Colors.blue),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Notification Alert',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Obx(
                              () => Switch(
                                value: notificationAlertEnabled.value,
                                onChanged: (value) {
                                  notificationAlertEnabled.value = value;
                                  _savePreferences('notificationAlertEnabled', value);
                                },
                                activeColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, color: Colors.blue),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Email Alert',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Obx(
                              () => Switch(
                                value: emailAlertEnabled.value,
                                onChanged: (value) {
                                  emailAlertEnabled.value = value;
                                  _savePreferences('emailAlertEnabled', value);
                                },
                                activeColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
