import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:untitled/customers/services/auth_services.dart';
import 'package:untitled/utils/static_strings.dart';
import 'package:untitled/utils/widgets/custom_button.dart';
import 'package:untitled/utils/widgets/custom_text_field.dart';
import 'package:untitled/utils/widgets/progress_stepper.dart';

class SignupScreen extends StatelessWidget {
  final SignupController controller = Get.put(SignupController());

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff9fbfd),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.createAccount,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => ProgressStepper(
                      completedSteps: controller.completedStepsCount,
                      totalSteps: 4,
                      stepTitle: controller.currentStepName.value,
                      progressValue: controller.progressValue,
                    ),
                  ),
                  SizedBox(height: 24),

                  Obx(
                    () => CustomTextField(
                      label: AppStrings.fullName,
                      hint: AppStrings.fullNameHint,
                      controller: controller.fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.nameValidateErrorText;
                        }
                        return null;
                      },
                      suffixIcon: controller.nameValid.value
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),

                  Obx(
                    () => CustomTextField(
                      label: AppStrings.enterEmail,
                      hint: AppStrings.emailHint,
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.emailValidateErrorText;
                        }
                        if (!GetUtils.isEmail(value)) {
                          return AppStrings.validEmailMessage;
                        }
                        return null;
                      },
                      suffixIcon: controller.emailValid.value
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.phoneNumber,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Obx(
                        () => IntlPhoneField(
                          controller: controller.phoneController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.withValues(alpha: .2)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: AppStrings.phoneHint,
                            errorText: null,
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            suffixIcon: controller.phoneValid.value
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                          ),
                          initialCountryCode: 'IN',
                          invalidNumberMessage: AppStrings.phoneValidateErrorText,
                          onChanged: (phone) {
                            controller.updatePhoneValidation(phone.number);
                            controller.fullPhoneNumber = '${phone.countryCode}${phone.number}';
                          },
                          onCountryChanged: (country) {
                            controller.phoneValid.value = false;
                          },
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.createPassword,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Obx(
                        () => TextFormField(
                          controller: controller.passwordController,
                          obscureText: !controller.showPassword.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.passwordValidateErrorText;
                            }
                            if (value.length < 8) {
                              return AppStrings.passwordStatusMessage;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            controller.updatePasswordStrength(value);
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.withValues(alpha: .2)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: AppStrings.strongPasswordHint,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (controller.passwordValid.value)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.check_circle, size: 20, color: Colors.green),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    controller.showPassword.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: controller.passwordStrengthValue.value,
                              backgroundColor: Colors.grey.shade300,
                              color: controller.getPasswordStrengthColor(),
                            ),
                            if (controller.passwordController.text.isNotEmpty)
                              Text(
                                '${AppStrings.passwordStrength}: ${controller.passwordStrength.value}',
                                style: TextStyle(
                                  color: controller.getPasswordStrengthColor(),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Terms and Conditions
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.termsAndConditionAgreementMessage,
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Continue Button
                  Obx(
                    () => CustomButton(
                      text: AppStrings.continueText,
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        if (controller.formKey.currentState!.validate() &&
                            controller.phoneValid.value) {
                          controller.createAccount();
                        }
                      },
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
}
