import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

class ExpandedPrediction extends StatefulWidget {
  final Widget choice;
  const ExpandedPrediction({super.key, required this.choice});

  @override
  State<ExpandedPrediction> createState() => _ExpandedPredictionState();
}

class _ExpandedPredictionState extends State<ExpandedPrediction> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.border, height: 1),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'YOUR PREDICTION',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.35)),
            ),
            child: widget.choice,
          ),
        ],
      ),
    );
  }
}
