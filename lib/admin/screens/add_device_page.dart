import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/admin/controllers/add_device_controller.dart';
import 'package:untitled/admin/controllers/device_controller.dart';

class AddDevicePage extends StatefulWidget {
  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final AddDeviceController deviceController = Get.find<AddDeviceController>();
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  String? deviceNameError;
  bool isValidating = false;

  // Add this property to track overall form submission state
  final RxBool isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    deviceNameController.addListener(_validateDeviceNameDebounced);
    // Add listeners for other text fields to update button state
    priceController.addListener(_updateFormState);
    unitsController.addListener(_updateFormState);
    imageUrlController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    deviceNameController.removeListener(_validateDeviceNameDebounced);
    priceController.removeListener(_updateFormState);
    unitsController.removeListener(_updateFormState);
    imageUrlController.removeListener(_updateFormState);
    deviceNameController.dispose();
    priceController.dispose();
    unitsController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  // Simple method to force a rebuild when any field changes
  void _updateFormState() {
    setState(() {
      // This will trigger a rebuild with the updated field values
    });
  }

  // Track the timer for debouncing
  Future<void>? _debounceTimer;

  void _validateDeviceNameDebounced() {
    // Cancel previous timer if exists
    _debounceTimer?.ignore();

    final name = deviceNameController.text.trim();

    // Clear error if empty
    if (name.isEmpty) {
      setState(() {
        deviceNameError = null;
        isValidating = false;
      });
      return;
    }

    // Set validating state
    setState(() {
      isValidating = true;
    });

    // Debounce for 500ms
    _debounceTimer = Future.delayed(Duration(milliseconds: 500), () async {
      bool isUnique = await deviceController.isDeviceNameUnique(name);

      if (mounted) {
        setState(() {
          deviceNameError = isUnique ? null : 'A device with this name already exists';
          isValidating = false;
        });
      }
    });
  }

  bool get isFormValid {
    return deviceNameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        unitsController.text.isNotEmpty &&
        deviceNameError == null &&
        !isValidating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Add New Device', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Name Field
                  Text(
                    'Device Model Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: deviceNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter device model name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      errorText: deviceNameError,
                      suffixIcon: isValidating
                          ? Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Price Field
                  Text(
                    'Price Per Unit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text('\₹', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24),

                  // Units Field
                  Text(
                    'Total Units Available',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: unitsController,
                    decoration: InputDecoration(
                      hintText: 'Enter total unites',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24),

                  // Image URL Field
                  Text('Image URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      hintText: 'Enter image URL',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Full screen loading overlay
          Obx(
            () => isSubmitting.value
                ? Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 30, top: 10),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (isFormValid && !isSubmitting.value)
                ? () async {
                    isSubmitting.value = true;

                    try {
                      final double price = double.parse(priceController.text);
                      final int units = int.parse(unitsController.text);

                      final success = await deviceController.addDevice(
                        deviceNameController.text,
                        units,
                        price,
                        imageUrlController.text,
                      );

                      isSubmitting.value = false;

                      if (success) {
                        if (Get.isRegistered<DeviceController>()) {
                          final mainDeviceController = Get.find<DeviceController>();
                          mainDeviceController.refreshData();
                        }

                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Device added successfully',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      }
                    } catch (e) {
                      isSubmitting.value = false;

                      Get.snackbar(
                        'Error',
                        'Invalid input. Please check your values',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  }
                : null, // Disable button when form is invalid or submitting
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Add Device',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
