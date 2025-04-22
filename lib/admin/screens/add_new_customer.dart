import 'package:emi_management/admin/controllers/sell_new_device_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get/get.dart';


class AddNewCustomer extends StatelessWidget {
  const AddNewCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with unique tag and true for fenix to ensure proper lifecycle management
    final controller = Get.put(SellNewDeviceController(), tag: 'sell_new_device_controller');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
            // Delete controller when navigating away
            Get.delete<SellNewDeviceController>(tag: 'sell_new_device_controller');
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Obx(()=>Form(
            key: controller.formKey,
            autovalidateMode: controller.showValidation.value
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information Section
                const Text(
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number Field
                IntlPhoneField(
                  controller: controller.phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    controller.updatePhoneInfo(phone.completeNumber, phone.countryCode);
                    controller.checkCustomerByPhone(phone.completeNumber);
                  },
                  onSubmitted: (value) {},
                  onCountryChanged: (country) {},
                  validator: (phone) {
                    if (controller.showValidation.value && (phone == null || phone.number.isEmpty)) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Customer Name Field
                Obx(() => TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter Customer Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabled: !controller.isExistingCustomer.value,
                  ),
                  validator: (value) {
                    if (controller.showValidation.value && (value == null || value.isEmpty)) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),

                Obx(() => TextFormField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabled: !controller.isExistingCustomer.value,
                    errorText: controller.isEmailExist.value
                        ? 'Email already exists'
                        : controller.isEmailInvalid.value
                        ? 'Invalid email format'
                        : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) async {
                    if (!controller.isExistingCustomer.value) {
                      // First check format
                      bool isValid = controller.isValidEmail(value);
                      controller.updateEmailInvalidStatus(!isValid);

                      // If format is valid and not empty, check if it exists
                      if (isValid && value.isNotEmpty) {
                        bool exists = await controller.checkEmailExists(value);
                        controller.updateEmailExistStatus(exists);
                      } else {
                        controller.updateEmailExistStatus(false);
                      }
                    } else {
                      controller.updateEmailExistStatus(false);
                      controller.updateEmailInvalidStatus(false);
                    }
                  },
                  validator: (value) {
                    if (!controller.showValidation.value) {
                      return null;
                    }

                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }

                    if (!controller.isValidEmail(value)) {
                      return 'Enter a valid email';
                    }

                    if (controller.isEmailExist.value) {
                      return 'Email already exists';
                    }

                    return null;
                  },
                )),
                const SizedBox(height: 16),

                // Password Field with Generate Button
                Obx(() => Row(
                  children: [
                    Expanded(
                     child: TextFormField(
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          labelText: 'Enter Password',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabled: !controller.isExistingCustomer.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showPassword.value ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => controller.showPassword.value = !controller.showPassword.value,
                          ),
                        ),
                        obscureText: !controller.showPassword.value,  // Toggle based on showPassword value
                        validator: (value) {
                          if (controller.showValidation.value && (value == null || value.isEmpty)) {
                            return 'Please enter or generate password';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (!controller.isExistingCustomer.value) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: controller.isGeneratingPassword.value || controller.passwordGenerated.value
                              ? null
                              : controller.generatePassword,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isGeneratingPassword.value
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Generate',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ],
                )),

                const Divider(height: 32, thickness: 1),

                // Device Selection Section
                const Text(
                  'Select Device',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Devices Grid
                Obx(() => controller.devicesList.isEmpty
                    ? const Center(
                  child: Text('No devices available'),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.devicesList.length,
                  itemBuilder: (context, index) {
                    final device = controller.devicesList[index];
                    return Obx(() {
                      final bool isSelected = controller.selectedDeviceId.value == device['id'];
                      return GestureDetector(
                        onTap: () => controller.selectDevice(device),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(9),
                                    topRight: Radius.circular(9),
                                  ),
                                  child: Image.network(
                                    device['img_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      device['device_name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${device['unit_price']}',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Available: ${device['available_quantity']}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                )),

                const SizedBox(height: 24),

                // Selected Device Details
                Obx(() => controller.selectedDevice.value != null
                    ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Device Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text('Device Name:'),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              controller.selectedDevice.value!['device_name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text('Unit Price:'),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '₹${controller.selectedDevice.value!['unit_price']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.totalMonthController,
                        decoration: InputDecoration(
                          labelText: 'Total Months for EMI',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (!controller.showValidation.value) {
                            return null;
                          }

                          if (value == null || value.isEmpty) {
                            return 'Please enter total months';
                          }
                          try {
                            int months = int.parse(value);
                            if (months <= 0) {
                              return 'Months must be greater than 0';
                            }
                          } catch (e) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                )
                    : SizedBox()),

                const SizedBox(height: 40),

              ],
            ),
          ),)
      )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 15.0,right: 15,bottom: 30, top: 10),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.resetForm,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.handleSubmit,
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}