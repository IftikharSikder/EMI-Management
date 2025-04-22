import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final String stepTitle;
  final double progressValue;

  const ProgressStepper({
    super.key,
    required this.completedSteps,
    required this.totalSteps,
    required this.stepTitle,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext  context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Step $completedSteps of $totalSteps',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Text(
              stepTitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey.shade300,
          color: Colors.blue,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}